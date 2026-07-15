-- D1 schema for scan leads (doosdossier-leads)
CREATE TABLE IF NOT EXISTS leads (
  email      TEXT PRIMARY KEY,
  answers    TEXT NOT NULL DEFAULT '{}',
  statuses   TEXT NOT NULL DEFAULT '{}',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_leads_created ON leads(created_at);