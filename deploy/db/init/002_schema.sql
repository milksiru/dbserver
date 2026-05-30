CREATE TABLE IF NOT EXISTS assets (
  id BIGSERIAL PRIMARY KEY,
  ticker TEXT NOT NULL,
  name TEXT NOT NULL,
  asset_class TEXT NOT NULL,
  market TEXT,
  sector TEXT,
  currency TEXT,
  is_etf BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(ticker, market)
);

CREATE TABLE IF NOT EXISTS watchlists (
  id BIGSERIAL PRIMARY KEY,
  asset_id BIGINT REFERENCES assets(id),
  category TEXT,
  memo TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS dc_portfolios (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  risk_type TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS dc_portfolio_items (
  id BIGSERIAL PRIMARY KEY,
  portfolio_id BIGINT REFERENCES dc_portfolios(id),
  asset_id BIGINT REFERENCES assets(id),
  target_weight NUMERIC(8,4),
  current_weight NUMERIC(8,4),
  current_amount NUMERIC(18,2),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reports (
  id BIGSERIAL PRIMARY KEY,
  report_type TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  summary TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS alerts (
  id BIGSERIAL PRIMARY KEY,
  alert_type TEXT NOT NULL,
  severity TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT DEFAULT 'OPEN',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS notification_channels (
  id BIGSERIAL PRIMARY KEY,
  channel_type TEXT NOT NULL UNIQUE,
  provider TEXT NOT NULL,
  enabled BOOLEAN DEFAULT false,
  sender TEXT,
  recipient TEXT,
  config_json JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS notification_logs (
  id BIGSERIAL PRIMARY KEY,
  channel_type TEXT NOT NULL,
  report_type TEXT,
  provider TEXT,
  recipient TEXT,
  title TEXT,
  message TEXT,
  status TEXT NOT NULL,
  error_message TEXT,
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS report_subscriptions (
  id BIGSERIAL PRIMARY KEY,
  report_type TEXT NOT NULL,
  channel_type TEXT NOT NULL,
  recipient TEXT NOT NULL,
  enabled BOOLEAN DEFAULT true,
  send_time TEXT,
  timezone TEXT DEFAULT 'Asia/Seoul',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value JSONB,
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS analysis_runs (
  id BIGSERIAL PRIMARY KEY,
  run_type TEXT NOT NULL,
  status TEXT NOT NULL,
  started_at TIMESTAMPTZ DEFAULT now(),
  finished_at TIMESTAMPTZ,
  error_message TEXT
);

CREATE TABLE IF NOT EXISTS market_ticks (
  time TIMESTAMPTZ NOT NULL,
  symbol TEXT NOT NULL,
  name TEXT,
  market TEXT,
  price NUMERIC(18,6),
  change_rate NUMERIC(10,4),
  volume NUMERIC(24,4),
  source TEXT,
  PRIMARY KEY(time, symbol)
);

CREATE TABLE IF NOT EXISTS asset_prices (
  time TIMESTAMPTZ NOT NULL,
  asset_id BIGINT NOT NULL REFERENCES assets(id),
  ticker TEXT NOT NULL,
  price NUMERIC(18,6),
  change_rate NUMERIC(10,4),
  volume NUMERIC(24,4),
  ma20 NUMERIC(18,6),
  ma60 NUMERIC(18,6),
  ma120 NUMERIC(18,6),
  rsi NUMERIC(10,4),
  volatility NUMERIC(10,4),
  source TEXT,
  PRIMARY KEY(time, asset_id)
);

CREATE TABLE IF NOT EXISTS macro_ticks (
  time TIMESTAMPTZ NOT NULL,
  symbol TEXT NOT NULL,
  name TEXT,
  value NUMERIC(18,6),
  change_rate NUMERIC(10,4),
  source TEXT,
  PRIMARY KEY(time, symbol)
);

CREATE TABLE IF NOT EXISTS market_scores (
  time TIMESTAMPTZ NOT NULL,
  score_date TEXT,
  market_mood TEXT NOT NULL,
  risk_level TEXT NOT NULL,
  risk_score NUMERIC(8,4),
  summary TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY(time)
);

CREATE TABLE IF NOT EXISTS risk_scores (
  time TIMESTAMPTZ NOT NULL,
  risk_key TEXT NOT NULL,
  risk_level TEXT NOT NULL,
  risk_score NUMERIC(8,4),
  reason TEXT,
  PRIMARY KEY(time, risk_key)
);

CREATE TABLE IF NOT EXISTS asset_signals (
  id BIGSERIAL PRIMARY KEY,
  asset_id TEXT NOT NULL,
  signal_type TEXT NOT NULL,
  score INTEGER NOT NULL,
  severity TEXT NOT NULL,
  reason TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS daily_reports (
  id BIGSERIAL PRIMARY KEY,
  report_date TEXT NOT NULL,
  title TEXT NOT NULL,
  market_mood TEXT NOT NULL,
  risk_level TEXT NOT NULL,
  summary TEXT NOT NULL,
  dc_comment TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

SELECT create_hypertable('market_ticks', 'time', if_not_exists => TRUE);
SELECT create_hypertable('asset_prices', 'time', if_not_exists => TRUE);
SELECT create_hypertable('macro_ticks', 'time', if_not_exists => TRUE);
SELECT create_hypertable('market_scores', 'time', if_not_exists => TRUE);
SELECT create_hypertable('risk_scores', 'time', if_not_exists => TRUE);

CREATE INDEX IF NOT EXISTS idx_market_ticks_symbol_time ON market_ticks(symbol, time DESC);
CREATE INDEX IF NOT EXISTS idx_asset_prices_ticker_time ON asset_prices(ticker, time DESC);
CREATE INDEX IF NOT EXISTS idx_macro_ticks_symbol_time ON macro_ticks(symbol, time DESC);
CREATE INDEX IF NOT EXISTS idx_market_scores_time ON market_scores(time DESC);
CREATE INDEX IF NOT EXISTS idx_risk_scores_key_time ON risk_scores(risk_key, time DESC);
