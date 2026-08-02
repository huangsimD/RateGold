(() => {
  const state = {
    view: 'dashboard',
    offset: 0,
    limit: 50,
    q: '',
  };

  const $ = (id) => document.getElementById(id);
  const errorEl = $('error');
  const titles = {
    dashboard: '分析看板',
    users: '用户列表',
    play: 'Play 商店',
  };

  function authHeader() {
    const raw = sessionStorage.getItem('ops_basic');
    return raw ? { Authorization: `Basic ${raw}` } : {};
  }

  function setError(msg) {
    if (!msg) {
      errorEl.classList.add('hidden');
      errorEl.textContent = '';
      return;
    }
    errorEl.textContent = msg;
    errorEl.classList.remove('hidden');
  }

  async function api(path, options = {}) {
    const res = await fetch(path, {
      ...options,
      headers: {
        ...authHeader(),
        ...(options.body ? { 'Content-Type': 'application/json' } : {}),
        ...(options.headers || {}),
      },
    });
    if (res.status === 401) {
      const user = window.prompt('Ops 用户名');
      const pass = window.prompt('Ops 密码');
      if (user == null || pass == null) throw new Error('需要登录');
      sessionStorage.setItem('ops_basic', btoa(`${user}:${pass}`));
      return api(path, options);
    }
    const body = await res.json().catch(() => ({}));
    if (!res.ok) {
      throw new Error(body.error || `HTTP ${res.status}`);
    }
    return body;
  }

  function fmtPct(v) {
    if (v == null) return '—';
    return `${v}%`;
  }

  function fmtNum(v) {
    if (v == null || Number.isNaN(v)) return '—';
    return v;
  }

  function renderMetrics(d) {
    const cards = [
      ['总用户数', d.total_users],
      ['今天新增', d.new_users_today],
      ['今天浏览', d.page_views_today],
      ['今日活跃 DAU', d.dau],
      ['近7日活跃 WAU', d.wau],
      ['留存 D1', fmtPct(d.retention_d1)],
      ['留存 D7', fmtPct(d.retention_d7)],
    ];
    $('metric-cards').innerHTML = cards
      .map(
        ([label, value]) =>
          `<div class="card"><div class="label">${label}</div><div class="value">${value}</div></div>`,
      )
      .join('');
    $('as-of').textContent = d.as_of ? `更新于 ${d.as_of}` : '';
    $('trend-body').innerHTML = (d.trend_7d || [])
      .map(
        (r) =>
          `<tr><td>${r.day}</td><td>${r.new_users}</td><td>${r.dau}</td></tr>`,
      )
      .join('');
  }

  function renderUsers(data) {
    $('users-body').innerHTML = (data.users || [])
      .map(
        (u) => `<tr>
        <td class="mono">${u.install_id}</td>
        <td>${u.first_seen_at || ''}</td>
        <td>${u.last_seen_at || ''}</td>
        <td>${u.open_count ?? 0}</td>
        <td>${u.last_screen || '—'}</td>
        <td>${u.app_version || '—'}</td>
        <td>${u.locale || '—'}</td>
      </tr>`,
      )
      .join('');
    const total = data.total || 0;
    const start = total === 0 ? 0 : data.offset + 1;
    const end = Math.min(data.offset + data.limit, total);
    $('page-info').textContent = `${start}-${end} / ${total}`;
    $('prev-page').disabled = data.offset <= 0;
    $('next-page').disabled = data.offset + data.limit >= total;
  }

  function renderPlay(data) {
    const snap = data.snapshot;
    const summary = snap?.summary || {};
    const apiTag = data.api_configured ? '已配置 Play API' : '未配置 Play API（可用手动 CSV）';
    const source = snap?.source ? `来源: ${snap.source}` : '尚无快照';
    const setupApi = (data.setup?.api || []).map((x) => `<li>${x}</li>`).join('');

    $('play-status').innerHTML = `
      <div><strong>${apiTag}</strong> · 包名 <code>${data.package_name || ''}</code></div>
      <div class="muted">${source}${snap?.updated_at ? ` · 更新于 ${snap.updated_at}` : ''}</div>
      <div class="muted" style="margin-top:0.5rem">${data.setup?.manual || ''}</div>
      <ul>${setupApi}</ul>
      ${data.error ? `<div class="error" style="margin-top:0.75rem">${data.error}</div>` : ''}
    `;

    const cards = [
      ['最近一日安装/获取', fmtNum(summary.installs_latest)],
      ['最近一日卸载', fmtNum(summary.uninstalls_latest)],
      ['设备安装量', fmtNum(summary.active_device_installs)],
      ['最近一日 DAU', fmtNum(summary.dau_latest)],
      ['近7日安装合计', fmtNum(summary.installs_7d)],
      ['近7日卸载合计', fmtNum(summary.uninstalls_7d)],
    ];
    $('play-cards').innerHTML = cards
      .map(
        ([label, value]) =>
          `<div class="card"><div class="label">${label}</div><div class="value">${value}</div></div>`,
      )
      .join('');

    const daily = [...(snap?.daily || [])].sort((a, b) => String(b.date).localeCompare(String(a.date)));
    $('play-trend-body').innerHTML = daily.length
      ? daily
          .map(
            (r) => `<tr>
          <td>${r.date}</td>
          <td>${fmtNum(r.installs)}</td>
          <td>${fmtNum(r.uninstalls)}</td>
          <td>${fmtNum(r.active_device_installs)}</td>
          <td>${fmtNum(r.dau)}</td>
        </tr>`,
          )
          .join('')
      : '<tr><td colspan="5" class="muted">暂无 Play 数据。请粘贴 CSV 保存，或配置 API 后刷新。</td></tr>';

    $('as-of').textContent = data.as_of ? `更新于 ${data.as_of}` : '';
    $('play-refresh-api-btn').disabled = !data.api_configured;
  }

  async function loadDashboard() {
    setError('');
    const data = await api('/v1/dashboard');
    renderMetrics(data);
  }

  async function loadUsers() {
    setError('');
    const params = new URLSearchParams({
      limit: String(state.limit),
      offset: String(state.offset),
    });
    if (state.q) params.set('q', state.q);
    const data = await api(`/v1/users?${params}`);
    renderUsers(data);
  }

  async function loadPlay(refreshApi = false) {
    setError('');
    const path = refreshApi ? '/v1/play-console?refresh=1' : '/v1/play-console';
    const data = await api(path);
    renderPlay(data);
  }

  async function savePlayCsv() {
    setError('');
    const csv = $('play-csv').value;
    const data = await api('/v1/play-console/snapshot', {
      method: 'POST',
      body: JSON.stringify({ csv, note: 'manual CSV from Play Console UI' }),
    });
    renderPlay(data);
  }

  async function refresh() {
    try {
      if (state.view === 'dashboard') await loadDashboard();
      else if (state.view === 'users') await loadUsers();
      else await loadPlay(false);
    } catch (e) {
      setError(e.message || String(e));
    }
  }

  function setView(view) {
    state.view = view;
    document.querySelectorAll('.nav-btn').forEach((btn) => {
      btn.classList.toggle('active', btn.dataset.view === view);
    });
    $('view-dashboard').classList.toggle('hidden', view !== 'dashboard');
    $('view-users').classList.toggle('hidden', view !== 'users');
    $('view-play').classList.toggle('hidden', view !== 'play');
    $('page-title').textContent = titles[view] || view;
    refresh();
  }

  document.querySelectorAll('.nav-btn').forEach((btn) => {
    btn.addEventListener('click', () => setView(btn.dataset.view));
  });
  $('refresh-btn').addEventListener('click', refresh);
  $('user-search-btn').addEventListener('click', () => {
    state.q = $('user-q').value.trim();
    state.offset = 0;
    refresh();
  });
  $('user-q').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      state.q = $('user-q').value.trim();
      state.offset = 0;
      refresh();
    }
  });
  $('prev-page').addEventListener('click', () => {
    state.offset = Math.max(0, state.offset - state.limit);
    refresh();
  });
  $('next-page').addEventListener('click', () => {
    state.offset += state.limit;
    refresh();
  });
  $('play-save-btn').addEventListener('click', () => {
    savePlayCsv().catch((e) => setError(e.message || String(e)));
  });
  $('play-refresh-api-btn').addEventListener('click', () => {
    loadPlay(true).catch((e) => setError(e.message || String(e)));
  });

  setView('dashboard');
})();
