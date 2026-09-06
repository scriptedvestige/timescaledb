DROP MATERIALIZED VIEW IF EXISTS rain_totals_monthly;

CREATE MATERIALIZED VIEW rain_totals_monthly
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 month', time, 'America/Los_Angeles') AS month,
  EXTRACT(YEAR FROM (time_bucket('1 month', time, 'America/Los_Angeles') AT TIME ZONE 'America/Los_Angeles'))::int AS year,
  EXTRACT(MONTH FROM (time_bucket('1 month', time, 'America/Los_Angeles') AT TIME ZONE 'America/Los_Angeles'))::int AS month_num,
  MAX(monthlyrainin) AS total_rainfall_in
FROM rain_totals
GROUP BY 1;

SELECT add_continuous_aggregate_policy('rain_totals_monthly',
  start_offset => INTERVAL '3 months',
  end_offset => INTERVAL '1 day',
  schedule_interval => INTERVAL '1 day');
