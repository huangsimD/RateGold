const path = require('path');
const express = require('express');
const cors = require('cors');

const { createStore } = require('./db');

function createApp() {
  // Load .env only for local runs (optional).
  try {
    require('dotenv').config({ path: path.join(__dirname, '..', '.env') });
  } catch (_) {
    // ignore
  }

  const ADMIN_USER = process.env.OPS_ADMIN_USER || 'admin';
  const ADMIN_PASS = process.env.OPS_ADMIN_PASS || 'change-me';
  const INGEST_TOKEN = process.env.OPS_INGEST_TOKEN || '';
  const store = createStore();

  const app = express();
  app.use(cors());
  app.use(express.json({ limit: '256kb' }));

  function requireIngestToken(req, res, next) {
    if (!INGEST_TOKEN) return next();
    const header = req.get('x-ops-token') || '';
    const auth = req.get('authorization') || '';
    const bearer = auth.startsWith('Bearer ') ? auth.slice(7) : '';
    if (header === INGEST_TOKEN || bearer === INGEST_TOKEN) return next();
    return res.status(401).json({ error: 'invalid ingest token' });
  }

  function requireAdmin(req, res, next) {
    const header = req.get('authorization') || '';
    if (!header.startsWith('Basic ')) {
      res.set('WWW-Authenticate', 'Basic realm="RateGold Ops"');
      return res.status(401).json({ error: 'auth required' });
    }
    const decoded = Buffer.from(header.slice(6), 'base64').toString('utf8');
    const sep = decoded.indexOf(':');
    const user = sep >= 0 ? decoded.slice(0, sep) : '';
    const pass = sep >= 0 ? decoded.slice(sep + 1) : '';
    if (user === ADMIN_USER && pass === ADMIN_PASS) return next();
    res.set('WWW-Authenticate', 'Basic realm="RateGold Ops"');
    return res.status(401).json({ error: 'invalid credentials' });
  }

  app.get('/health', (_req, res) => {
    res.json({
      ok: true,
      service: 'rategold-ops',
      storage: store.mode,
    });
  });

  app.post('/v1/events', requireIngestToken, async (req, res) => {
    const body = req.body;
    let items = [];
    if (Array.isArray(body)) {
      items = body;
    } else if (body && Array.isArray(body.events)) {
      items = body.events;
    } else if (body && body.install_id && body.event) {
      items = [body];
    } else {
      return res.status(400).json({ error: 'expected event object or { events: [] }' });
    }
    if (items.length > 50) {
      return res.status(400).json({ error: 'max 50 events per request' });
    }
    try {
      const accepted = await store.ingestEvents(items);
      return res.json({ ok: true, accepted });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'ingest failed' });
    }
  });

  app.get('/v1/dashboard', requireAdmin, async (_req, res) => {
    try {
      res.json(await store.dashboardStats());
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'dashboard failed' });
    }
  });

  app.get('/v1/users', requireAdmin, async (req, res) => {
    try {
      res.json(
        await store.listUsers({
          limit: req.query.limit,
          offset: req.query.offset,
          q: req.query.q,
        }),
      );
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'users failed' });
    }
  });

  app.use(express.static(path.join(__dirname, '..', 'public')));

  return app;
}

module.exports = { createApp };
