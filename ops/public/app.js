(() => {
  const state = {
    view: 'dashboard',
    offset: 0,
    limit: 50,
    q: '',
  };

  const $ = (id) => document.getElementById(id);
  const errorEl = $('error');

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

  async function api(path) {
    const res = await fetch(path, { headers: { ...authHeader() } });
    if (res.status === 401) {
      const user = window.prompt('Ops 用户名');
      const pass = window.prompt('Ops 密码');
      if (user == null || pass == null) throw new Error('需要登录');
      sessionStorage.setItem('ops_basic', btoa(`${user}:${pass}`));
      return api(path);
    }
    if (!res.ok) {
      const body = await res.json().catch(() => ({}));
      throw new Error(body.error || `HTTP ${res.status}`);
    }
    return res.json();
  }

  function fmtPct(v) {
    if (v == null) return '—';
    return `${v}%`;
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

  async function refresh() {
    try {
      if (state.view === 'dashboard') await loadDashboard();
      else await loadUsers();
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
    $('page-title').textContent = view === 'dashboard' ? '分析看板' : '用户列表';
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

  setView('dashboard');
})();
