CREATE MATERIALIZED VIEW IF NOT EXISTS asset_prices_daily
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 day', time) AS day,
  asset_id,
  ticker,
  first(price, time) AS open_price,
  max(price) AS high_price,
  min(price) AS low_price,
  last(price, time) AS close_price,
  avg(price) AS avg_price,
  avg(volume) AS avg_volume
FROM asset_prices
GROUP BY day, asset_id, ticker
WITH NO DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS market_ticks_daily
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 day', time) AS day,
  symbol,
  first(price, time) AS open_price,
  max(price) AS high_price,
  min(price) AS low_price,
  last(price, time) AS close_price,
  avg(volume) AS avg_volume
FROM market_ticks
GROUP BY day, symbol
WITH NO DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS macro_ticks_daily
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 day', time) AS day,
  symbol,
  avg(value) AS avg_value,
  max(value) AS max_value,
  min(value) AS min_value
FROM macro_ticks
GROUP BY day, symbol
WITH NO DATA;

SELECT add_continuous_aggregate_policy(
  'asset_prices_daily',
  start_offset => INTERVAL '30 days',
  end_offset => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 hour',
  if_not_exists => TRUE
);

SELECT add_continuous_aggregate_policy(
  'market_ticks_daily',
  start_offset => INTERVAL '30 days',
  end_offset => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 hour',
  if_not_exists => TRUE
);

SELECT add_continuous_aggregate_policy(
  'macro_ticks_daily',
  start_offset => INTERVAL '30 days',
  end_offset => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 hour',
  if_not_exists => TRUE
);
