const fs = require('fs');
const path = require('path');

/**
 * Dual storage:
 * - Local: JSON file (dev)
 * - Production: private GitHub Gist (OPS_GIST_ID + OPS_GITHUB_TOKEN)
 */

function todayUtc() {
  return new Date().toISOString().slice(0, 10);
}

function daysAgoUtc(n) {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() - n);
  return d.toISOString().slice(0, 10);
}

function createStore(options = {}) {
  const gistId = options.gistId || process.env.OPS_GIST_ID || '';
  const githubToken = options.githubToken || process.env.OPS_GITHUB_TOKEN || '';
  let dbPath = options.dbPath || process.env.OPS_DB_PATH || '';
  if (!dbPath) {
    dbPath = path.join(__dirname, '..', 'data', 'ops.json');
  } else {
    dbPath = path.resolve(dbPath);
  }
  if (dbPath.endsWith('.sqlite')) {
    dbPath = dbPath.replace(/\.sqlite$/i, '.json');
  }

  const useGist = Boolean(gistId && githubToken);
  const state = { users: {}, events: [], play_console: null, loaded: false };
  let chain = Promise.resolve();

  function withLock(fn) {
    const run = chain.then(fn, fn);
    chain = run.catch(() => {});
    return run;
  }

  async function loadFromGist() {
    const res = await fetch(`https://api.github.com/gists/${gistId}`, {
      headers: {
        Authorization: `Bearer ${githubToken}`,
        Accept: 'application/vnd.github+json',
        'User-Agent': 'rategold-ops',
      },
    });
    if (!res.ok) {
      throw new Error(`gist load failed: HTTP ${res.status}`);
    }
    const gist = await res.json();
    const file = gist.files && (gist.files['ops.json'] || Object.values(gist.files)[0]);
    if (!file || !file.content) {
      state.users = {};
      state.events = [];
      state.play_console = null;
      return;
    }
    const raw = JSON.parse(file.content);
    state.users = raw.users || {};
    state.events = Array.isArray(raw.events) ? raw.events : [];
    state.play_console = raw.play_console || null;
  }

  function loadFromFile() {
    const dir = path.dirname(dbPath);
    fs.mkdirSync(dir, { recursive: true });
    if (!fs.existsSync(dbPath)) {
      state.users = {};
      state.events = [];
      state.play_console = null;
      return;
    }
    const raw = JSON.parse(fs.readFileSync(dbPath, 'utf8'));
    state.users = raw.users || {};
    state.events = Array.isArray(raw.events) ? raw.events : [];
    state.play_console = raw.play_console || null;
  }

  async function ensureLoaded() {
    if (state.loaded) return;
    if (useGist) {
      await loadFromGist();
    } else {
      loadFromFile();
    }
    state.loaded = true;
  }

  async function persist() {
    const payload = JSON.stringify({
      users: state.users,
      events: state.events,
      play_console: state.play_console,
    });
    if (useGist) {
      const res = await fetch(`https://api.github.com/gists/${gistId}`, {
        method: 'PATCH',
        headers: {
          Authorization: `Bearer ${githubToken}`,
          Accept: 'application/vnd.github+json',
          'Content-Type': 'application/json',
          'User-Agent': 'rategold-ops',
        },
        body: JSON.stringify({
          files: {
            'ops.json': { content: payload },
          },
        }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(`gist save failed: HTTP ${res.status} ${text}`);
      }
      return;
    }
    const dir = path.dirname(dbPath);
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(dbPath, payload, 'utf8');
  }

  async function ingestEvents(items) {
    return withLock(async () => {
      await ensureLoaded();
      const now = new Date().toISOString();
      const day = now.slice(0, 10);
      let accepted = 0;

      for (const raw of items) {
        const installId = String(raw.install_id || '').trim();
        const event = String(raw.event || '').trim();
        if (!installId || !event) continue;
        if (!['first_open', 'app_open', 'screen_view'].includes(event)) continue;

        const screen = raw.screen ? String(raw.screen).slice(0, 64) : null;
        const appVersion = raw.app_version ? String(raw.app_version).slice(0, 32) : null;
        const locale = raw.locale ? String(raw.locale).slice(0, 16) : null;
        const clientTs = raw.ts ? String(raw.ts).slice(0, 40) : null;

        state.events.push({
          id: state.events.length + 1,
          install_id: installId,
          event,
          screen,
          app_version: appVersion,
          locale,
          client_ts: clientTs,
          server_ts: now,
          day,
        });

        const openDelta = event === 'app_open' || event === 'first_open' ? 1 : 0;
        const existing = state.users[installId];
        if (!existing) {
          state.users[installId] = {
            install_id: installId,
            first_seen_at: now,
            last_seen_at: now,
            open_count: openDelta || 1,
            last_screen: screen,
            app_version: appVersion,
            locale,
          };
        } else {
          existing.last_seen_at = now;
          existing.open_count = (existing.open_count || 0) + openDelta;
          if (screen) existing.last_screen = screen;
          if (appVersion) existing.app_version = appVersion;
          if (locale) existing.locale = locale;
        }
        accepted += 1;
      }

      await persist();
      return accepted;
    });
  }

  function retentionRates() {
    const users = Object.values(state.users);

    function rate(cohortDay, returnDay) {
      const cohort = users.filter((u) => (u.first_seen_at || '').slice(0, 10) === cohortDay);
      if (cohort.length === 0) return null;
      const ids = new Set(cohort.map((u) => u.install_id));
      const returned = new Set(
        state.events
          .filter((e) => e.day === returnDay && ids.has(e.install_id))
          .map((e) => e.install_id),
      );
      return Math.round((returned.size / cohort.length) * 1000) / 10;
    }

    return {
      d1: rate(daysAgoUtc(1), todayUtc()),
      d7: rate(daysAgoUtc(7), todayUtc()),
    };
  }

  async function dashboardStats() {
    return withLock(async () => {
      await ensureLoaded();
      const today = todayUtc();
      const weekStart = daysAgoUtc(6);
      const users = Object.values(state.users);

      const totalUsers = users.length;
      const newUsersToday = users.filter(
        (u) => (u.first_seen_at || '').slice(0, 10) === today,
      ).length;
      const pageViewsToday = state.events.filter(
        (e) => e.event === 'screen_view' && e.day === today,
      ).length;
      const dau = new Set(state.events.filter((e) => e.day === today).map((e) => e.install_id))
        .size;
      const wau = new Set(
        state.events.filter((e) => e.day >= weekStart).map((e) => e.install_id),
      ).size;

      const retention = retentionRates();
      const byDay = new Map();
      for (let i = 6; i >= 0; i -= 1) {
        const d = daysAgoUtc(i);
        byDay.set(d, { day: d, dau: 0, new_users: 0 });
      }
      for (const [d, row] of byDay) {
        row.dau = new Set(state.events.filter((e) => e.day === d).map((e) => e.install_id)).size;
        row.new_users = users.filter((u) => (u.first_seen_at || '').slice(0, 10) === d).length;
      }

      return {
        total_users: totalUsers,
        new_users_today: newUsersToday,
        page_views_today: pageViewsToday,
        dau,
        wau,
        retention_d1: retention.d1,
        retention_d7: retention.d7,
        trend_7d: [...byDay.values()],
        as_of: new Date().toISOString(),
        storage: useGist ? 'github-gist' : 'local-file',
      };
    });
  }

  async function listUsers({ limit = 50, offset = 0, q = '' } = {}) {
    return withLock(async () => {
      await ensureLoaded();
      const lim = Math.min(Math.max(Number(limit) || 50, 1), 200);
      const off = Math.max(Number(offset) || 0, 0);
      const query = String(q || '').trim().toLowerCase();

      let rows = Object.values(state.users).sort((a, b) =>
        String(b.last_seen_at).localeCompare(String(a.last_seen_at)),
      );
      if (query) {
        rows = rows.filter((u) => {
          const hay = `${u.install_id} ${u.locale || ''} ${u.app_version || ''}`.toLowerCase();
          return hay.includes(query);
        });
      }
      const total = rows.length;
      return { total, limit: lim, offset: off, users: rows.slice(off, off + lim) };
    });
  }

  async function getPlayConsoleSnapshot() {
    return withLock(async () => {
      await ensureLoaded();
      return state.play_console;
    });
  }

  async function savePlayConsoleSnapshot(snapshot) {
    return withLock(async () => {
      await ensureLoaded();
      state.play_console = snapshot;
      await persist();
      return state.play_console;
    });
  }

  return {
    mode: useGist ? 'github-gist' : 'local-file',
    path: useGist ? `gist:${gistId}` : dbPath,
    ingestEvents,
    dashboardStats,
    listUsers,
    getPlayConsoleSnapshot,
    savePlayConsoleSnapshot,
  };
}

module.exports = {
  createStore,
};
