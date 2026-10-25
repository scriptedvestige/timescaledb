-- 1. Daily stats (local days, live current day)
CREATE MATERIALIZED VIEW vpd_daily_stats
WITH (timescaledb.continuous, timescaledb.materialized_only = false) AS
SELECT
    time_bucket('1 day', time, 'America/Los_Angeles') AS day,
    -- Hours in ideal range (each 5-min interval = 1/12 hour)
    COUNT(*) FILTER (WHERE vpd >= 0.4 AND vpd <= 1.6) / 12.0 AS hours_in_range,
    -- Total observations for coverage check
    COUNT(*) AS total_obs,
    -- Min/max for context
    MIN(vpd) AS vpd_min,
    MAX(vpd) AS vpd_max,
    AVG(vpd) AS vpd_avg
FROM ws_observations
WHERE vpd IS NOT NULL
GROUP BY day
WITH NO DATA;

-- Policy: runs daily at 00:16 local
SELECT add_continuous_aggregate_policy('vpd_daily_stats',
    start_offset      => INTERVAL '3 days',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 hour',
    initial_start     => '2026-10-25 17:16:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');

-- Backfill (run by itself)
CALL refresh_continuous_aggregate('vpd_daily_stats', NULL, NULL);


-- VPD Episodes
CREATE VIEW vpd_episodes AS
WITH base AS (
    SELECT time,
           (vpd >= 0.4 AND vpd <= 1.6) AS in_range,
           lag(time) OVER w AS prev_time,
           lag(vpd >= 0.4 AND vpd <= 1.6) OVER w AS prev_in
    FROM ws_observations
    WHERE vpd IS NOT NULL
    WINDOW w AS (ORDER BY time)
),
marked AS (
    SELECT *,
           CASE WHEN prev_time IS NULL
                  OR time - prev_time > INTERVAL '15 minutes'
                  OR in_range IS DISTINCT FROM prev_in
                THEN 1 ELSE 0 END AS new_run
    FROM base
),
runs AS (
    SELECT *, SUM(new_run) OVER (ORDER BY time) AS run_id
    FROM marked
)
SELECT run_id,
       MIN(time) AS entered_at,
       MAX(time) + INTERVAL '5 minutes' AS exited_at,
       ROUND(EXTRACT(EPOCH FROM (MAX(time) - MIN(time) + INTERVAL '5 minutes')) / 3600.0, 2) AS duration_hours,
       (MIN(time) AT TIME ZONE 'America/Los_Angeles')::date AS start_day,
       (MIN(time) AT TIME ZONE 'America/Los_Angeles')::time AS entered_local,
       (MAX(time) AT TIME ZONE 'America/Los_Angeles')::time AS exited_local
FROM runs
WHERE in_range
GROUP BY run_id;


-- 3. Monthly (local months)
CREATE VIEW vpd_monthly_stats AS
SELECT
    time_bucket('1 month', day, 'America/Los_Angeles') AS month,
    COUNT(*) FILTER (WHERE hours_in_range > 0) AS days_hitting_range,
    COUNT(*) AS total_days,
    ROUND(AVG(hours_in_range)::numeric, 2) AS avg_hours_in_range,
    ROUND(MAX(hours_in_range)::numeric, 2) AS best_day_hours
FROM vpd_daily_stats
GROUP BY 1
ORDER BY 1;


-- Troubleshooting
CALL refresh_continuous_aggregate('vpd_daily_stats', NULL, NULL);


DROP VIEW vpd_monthly_stats;
DROP MATERIALIZED VIEW vpd_daily_stats;





SELECT
    s.day::date AS "Date",
    ROUND(s.hours_in_range::numeric, 2) AS "Hours In Range",
    ROUND(COALESCE(MAX(e.duration_hours), 0)::numeric, 2) AS "Longest Episode",
    ROUND(s.vpd_min::numeric, 2) AS "VPD Min",
    ROUND(s.vpd_avg::numeric, 2) AS "VPD Avg",
    ROUND(s.vpd_max::numeric, 2) AS "VPD Max"
FROM vpd_daily_stats s
LEFT JOIN vpd_episodes e
  ON e.start_day = (s.day AT TIME ZONE 'America/Los_Angeles')::date
GROUP BY s.day, s.hours_in_range, s.vpd_min, s.vpd_avg, s.vpd_max
ORDER BY s.day DESC;