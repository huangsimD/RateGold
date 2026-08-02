/**
 * Play Console install / active metrics.
 *
 * Sources (priority):
 * 1) Live Google Play Developer Reporting API — if GOOGLE_PLAY_SERVICE_ACCOUNT_JSON is set
 * 2) Manual snapshot saved in ops storage (CSV / JSON pasted in admin UI)
 */

const PACKAGE_NAME = process.env.GOOGLE_PLAY_PACKAGE_NAME || 'com.rategold.app';

function isApiConfigured() {
  const raw = process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON || '';
  return raw.trim().length > 2;
}

function daysAgoUtc(n) {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() - n);
  return d.toISOString().slice(0, 10);
}

function todayUtc() {
  return new Date().toISOString().slice(0, 10);
}

function summarizeDaily(daily) {
  const rows = Array.isArray(daily) ? [...daily] : [];
  rows.sort((a, b) => String(a.date).localeCompare(String(b.date)));
  const last = rows[rows.length - 1] || null;
  const last7 = rows.filter((r) => r.date >= daysAgoUtc(6));
  const sum = (key) => last7.reduce((acc, r) => acc + (Number(r[key]) || 0), 0);
  return {
    latest_day: last?.date || null,
    installs_latest: last?.installs ?? null,
    uninstalls_latest: last?.uninstalls ?? null,
    active_device_installs: last?.active_device_installs ?? null,
    dau_latest: last?.dau ?? null,
    installs_7d: sum('installs'),
    uninstalls_7d: sum('uninstalls'),
    row_count: rows.length,
  };
}

function parseCsv(text) {
  const lines = String(text || '')
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter(Boolean);
  if (lines.length === 0) return [];

  let start = 0;
  let headers = ['date', 'installs', 'uninstalls', 'active_device_installs', 'dau'];
  const first = lines[0].toLowerCase();
  if (first.includes('date') || first.includes('日期')) {
    headers = lines[0].split(/[,;\t]/).map((h) => h.trim().toLowerCase());
    start = 1;
  }

  const mapKey = (h) => {
    if (['date', '日期', 'day'].includes(h)) return 'date';
    if (['installs', 'install', '新增安装', 'user installs', 'user_installs'].includes(h)) {
      return 'installs';
    }
    if (['uninstalls', 'uninstall', '卸载'].includes(h)) return 'uninstalls';
    if (
      ['active_device_installs', 'active installs', 'active_installs', '设备安装量', 'active'].includes(
        h,
      )
    ) {
      return 'active_device_installs';
    }
    if (['dau', 'daily active users', '日活', '活跃用户'].includes(h)) return 'dau';
    return h;
  };
  const keys = headers.map(mapKey);

  const daily = [];
  for (let i = start; i < lines.length; i += 1) {
    const cols = lines[i].split(/[,;\t]/).map((c) => c.trim());
    const row = {};
    keys.forEach((k, idx) => {
      row[k] = cols[idx];
    });
    if (!row.date) continue;
    daily.push({
      date: String(row.date).slice(0, 10),
      installs: Number(row.installs) || 0,
      uninstalls: Number(row.uninstalls) || 0,
      active_device_installs:
        row.active_device_installs === undefined || row.active_device_installs === ''
          ? null
          : Number(row.active_device_installs),
      dau: row.dau === undefined || row.dau === '' ? null : Number(row.dau),
    });
  }
  return daily;
}

function normalizeSnapshot(body) {
  let daily = [];
  if (typeof body?.csv === 'string' && body.csv.trim()) {
    daily = parseCsv(body.csv);
  } else if (Array.isArray(body?.daily)) {
    daily = body.daily.map((r) => ({
      date: String(r.date || '').slice(0, 10),
      installs: Number(r.installs) || 0,
      uninstalls: Number(r.uninstalls) || 0,
      active_device_installs:
        r.active_device_installs === undefined || r.active_device_installs === null
          ? null
          : Number(r.active_device_installs),
      dau: r.dau === undefined || r.dau === null ? null : Number(r.dau),
    }));
  }
  daily = daily.filter((r) => r.date).sort((a, b) => a.date.localeCompare(b.date));
  return {
    package_name: body?.package_name || PACKAGE_NAME,
    note: body?.note ? String(body.note).slice(0, 500) : '',
    updated_at: new Date().toISOString(),
    source: 'manual',
    daily,
    summary: summarizeDaily(daily),
  };
}

async function getAccessToken() {
  let credentials;
  try {
    credentials = JSON.parse(process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON);
  } catch {
    throw new Error('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON is not valid JSON');
  }
  let GoogleAuth;
  try {
    ({ GoogleAuth } = require('google-auth-library'));
  } catch {
    throw new Error('google-auth-library not installed');
  }
  const auth = new GoogleAuth({
    credentials,
    scopes: ['https://www.googleapis.com/auth/playdeveloperreporting'],
  });
  const client = await auth.getClient();
  const token = await client.getAccessToken();
  if (!token?.token) throw new Error('failed to obtain Google access token');
  return token.token;
}

function calendarDate(isoDay) {
  const [y, m, d] = isoDay.split('-').map(Number);
  return { year: y, month: m, day: d };
}

async function queryMetric(accessToken, pathSuffix, body) {
  const url = `https://playdeveloperreporting.googleapis.com/v1beta1/apps/${PACKAGE_NAME}/${pathSuffix}`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  let json;
  try {
    json = JSON.parse(text);
  } catch {
    json = { raw: text };
  }
  if (!res.ok) {
    const msg = json?.error?.message || text || `HTTP ${res.status}`;
    throw new Error(msg);
  }
  return json;
}

function rowsFromUserCounts(resp) {
  const byDay = new Map();
  for (const row of resp.rows || []) {
    const start = row.startTime;
    if (!start?.year) continue;
    const date = `${start.year}-${String(start.month).padStart(2, '0')}-${String(start.day).padStart(2, '0')}`;
    const metrics = row.metrics || [];
    const get = (name) => {
      const m = metrics.find((x) => x.metric === name);
      return m?.decimalValue?.value != null
        ? Number(m.decimalValue.value)
        : m?.int64Value != null
          ? Number(m.int64Value)
          : null;
    };
    byDay.set(date, {
      date,
      installs: 0,
      uninstalls: 0,
      active_device_installs: null,
      dau: get('DAU'),
      wau: get('WAU'),
      mau: get('MAU'),
    });
  }
  return byDay;
}

function mergeStorePerformance(byDay, resp) {
  for (const row of resp.rows || []) {
    const start = row.startTime;
    if (!start?.year) continue;
    const date = `${start.year}-${String(start.month).padStart(2, '0')}-${String(start.day).padStart(2, '0')}`;
    const cur = byDay.get(date) || {
      date,
      installs: 0,
      uninstalls: 0,
      active_device_installs: null,
      dau: null,
    };
    const metrics = row.metrics || [];
    const get = (name) => {
      const m = metrics.find((x) => x.metric === name);
      return m?.decimalValue?.value != null
        ? Number(m.decimalValue.value)
        : m?.int64Value != null
          ? Number(m.int64Value)
          : null;
    };
    // STORE_LISTING_ACQUISITIONS ≈ 商店获取/安装意向流量，作为安装代理指标
    const acquisitions = get('STORE_LISTING_ACQUISITIONS');
    if (acquisitions != null) cur.installs = Math.round(acquisitions);
    byDay.set(date, cur);
  }
}

async function fetchLivePlayConsole() {
  const accessToken = await getAccessToken();
  const start = daysAgoUtc(28);
  const end = todayUtc();
  const timelineSpec = {
    aggregationPeriod: 'DAILY',
    startTime: calendarDate(start),
    endTime: calendarDate(end),
  };

  const byDay = new Map();
  const errors = [];

  try {
    const userCounts = await queryMetric(accessToken, 'userCountsMetrics:query', {
      timelineSpec,
      metrics: ['DAU', 'WAU', 'MAU'],
    });
    for (const [k, v] of rowsFromUserCounts(userCounts)) byDay.set(k, v);
  } catch (e) {
    errors.push(`userCounts: ${e.message}`);
  }

  try {
    const store = await queryMetric(accessToken, 'storePerformanceMetrics:query', {
      timelineSpec,
      metrics: ['STORE_LISTING_ACQUISITIONS', 'STORE_LISTING_VISITORS'],
    });
    mergeStorePerformance(byDay, store);
  } catch (e) {
    errors.push(`storePerformance: ${e.message}`);
  }

  const daily = [...byDay.values()].sort((a, b) => a.date.localeCompare(b.date));
  if (daily.length === 0 && errors.length) {
    throw new Error(errors.join(' | '));
  }

  return {
    package_name: PACKAGE_NAME,
    note: errors.length ? `Partial data. ${errors.join(' | ')}` : 'Live Play Developer Reporting API',
    updated_at: new Date().toISOString(),
    source: 'play-api',
    daily,
    summary: summarizeDaily(daily),
    api_errors: errors,
  };
}

function statusPayload(snapshot) {
  return {
    package_name: PACKAGE_NAME,
    api_configured: isApiConfigured(),
    has_snapshot: Boolean(snapshot && Array.isArray(snapshot.daily) && snapshot.daily.length),
    snapshot,
    as_of: new Date().toISOString(),
    setup: {
      manual:
        '在本页粘贴 Play Console → 统计信息 导出的 CSV（含 date/installs 列），或填写每日安装/活跃后保存。',
      api: [
        'Google Cloud 启用 “Google Play Developer Reporting API”',
        '创建服务账号并下载 JSON，整段放入 Vercel 环境变量 GOOGLE_PLAY_SERVICE_ACCOUNT_JSON',
        'Play Console → 用户和权限 → 邀请该服务账号邮箱（至少查看权限）',
        '设置 GOOGLE_PLAY_PACKAGE_NAME=com.rategold.app（可选，默认已是）',
      ],
    },
  };
}

module.exports = {
  isApiConfigured,
  normalizeSnapshot,
  parseCsv,
  summarizeDaily,
  fetchLivePlayConsole,
  statusPayload,
  PACKAGE_NAME,
};
