ALTER TABLE asset_prices SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'ticker'
);

ALTER TABLE market_ticks SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'symbol'
);

ALTER TABLE macro_ticks SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'symbol'
);

SELECT add_compression_policy('asset_prices', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('market_ticks', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('macro_ticks', INTERVAL '7 days', if_not_exists => TRUE);

SELECT add_retention_policy('asset_prices', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('market_ticks', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('macro_ticks', INTERVAL '2 years', if_not_exists => TRUE);
