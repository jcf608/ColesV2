-- Carina Database Schema

-- Actions Table
CREATE TABLE IF NOT EXISTS actions (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  priority TEXT CHECK(priority IN ('critical', 'high', 'normal')),
  status TEXT CHECK(status IN ('pending', 'in_progress', 'completed', 'failed')),
  type TEXT NOT NULL,
  store_id TEXT,
  financial_impact_usd DECIMAL(10,2),
  approval_level TEXT,
  approval_token TEXT,
  approver_id TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  approved_at TIMESTAMP,
  executed_at TIMESTAMP,
  completed_at TIMESTAMP,
  execution_params JSON,
  outcome JSON,
  audit_trail JSON
);

CREATE INDEX idx_actions_status ON actions(status);
CREATE INDEX idx_actions_priority ON actions(priority);
CREATE INDEX idx_actions_store ON actions(store_id);

-- Alerts Table
CREATE TABLE IF NOT EXISTS alerts (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  priority TEXT CHECK(priority IN ('critical', 'actionable', 'informational')),
  status TEXT CHECK(status IN ('active', 'in_progress', 'resolved', 'dismissed')),
  source TEXT NOT NULL,
  affected_scope JSON,
  action_items JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP,
  dismissed_at TIMESTAMP,
  resolution_type TEXT,
  resolution_notes TEXT,
  notifications_sent JSON
);

CREATE INDEX idx_alerts_status ON alerts(status);
CREATE INDEX idx_alerts_priority ON alerts(priority);
CREATE INDEX idx_alerts_created ON alerts(created_at);

-- Conversations Table
CREATE TABLE IF NOT EXISTS conversations (
  id TEXT PRIMARY KEY,
  mode TEXT CHECK(mode IN ('ask', 'act', 'alert')),
  user_id TEXT NOT NULL,
  store_id TEXT,
  messages JSON,
  tool_calls JSON,
  context JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conversations_user ON conversations(user_id);
CREATE INDEX idx_conversations_mode ON conversations(mode);

-- Audit Log Table
CREATE TABLE IF NOT EXISTS audit_log (
  id TEXT PRIMARY KEY,
  event_type TEXT NOT NULL,
  entity_type TEXT,
  entity_id TEXT,
  user_id TEXT,
  action TEXT,
  changes JSON,
  metadata JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_created ON audit_log(created_at);
