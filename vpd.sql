-- Daily tracking
CREATE MATERIALIZED VIEW vpd_daily_stats
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 day', time) AS day,
    -- Hours in ideal range (each 5-min interval = 1/12 hour)
    COUNT(*) FILTER (WHERE vpd >= 0.4 AND vpd <= 1.2) / 12.0 AS hours_in_range,
    -- Total observations for coverage check
    COUNT(*) AS total_obs,
    -- Min/max for context
    MIN(vpd) AS vpd_min,
    MAX(vpd) AS vpd_max,
    AVG(vpd) AS vpd_avg
FROM ws_observations
WHERE vpd IS NOT NULL
GROUP BY time_bucket('1 day', time)
WITH NO DATA;

-- Set policy to refresh
SELECT add_continuous_aggregate_policy('vpd_daily_stats',
    start_offset => INTERVAL '3 days',
    end_offset   => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour');

-- Backfill data from date VPD was added to table
CALL refresh_continuous_aggregate('vpd_daily_stats', '2026-04-10', NULL);

-- See the data
SELECT 
    day::date,
    ROUND(hours_in_range::numeric, 2) AS hours_in_range,
    total_obs,
    vpd_min,
    vpd_max,
    ROUND(vpd_avg::numeric, 2) AS vpd_avg
FROM vpd_daily_stats
ORDER BY day;


-- Gaps and Islands View
CREATE VIEW vpd_daily_longest_window AS
WITH flagged AS (
    SELECT
        time,
        DATE_TRUNC('day', time) AS day,
        CASE WHEN vpd >= 0.4 AND vpd <= 1.2 THEN 1 ELSE 0 END AS in_range
    FROM ws_observations
    WHERE vpd IS NOT NULL
),
islands AS (
    SELECT
        day,
        in_range,
        time,
        ROW_NUMBER() OVER (PARTITION BY day ORDER BY time) -
        ROW_NUMBER() OVER (PARTITION BY day, in_range ORDER BY time) AS grp
    FROM flagged
),
island_lengths AS (
    SELECT
        day,
        in_range,
        grp,
        COUNT(*) / 12.0 AS window_hours
    FROM islands
    GROUP BY day, in_range, grp
)
SELECT
    day,
    COALESCE(MAX(window_hours) FILTER (WHERE in_range = 1), 0) AS longest_window_hours
FROM island_lengths
GROUP BY day;

-- See the data
SELECT 
    day::date,
    ROUND(longest_window_hours::numeric, 2) AS longest_window_hours
FROM vpd_daily_longest_window
ORDER BY day;

-- Compare longest stretch to total hours per day in ideal VPD range
SELECT
    s.day::date AS "Date",
    ROUND(s.hours_in_range::numeric, 2) AS "Hours In Range",
    ROUND(w.longest_window_hours::numeric, 2) AS "Longest Window",
    ROUND(s.vpd_min::numeric, 2) AS "VPD Min",
    ROUND(s.vpd_avg::numeric, 2) AS "VPD Avg",
    ROUND(s.vpd_max::numeric, 2) AS "VPD Max"
FROM vpd_daily_stats s
JOIN vpd_daily_longest_window w ON w.day = s.day
ORDER BY s.day desc;


-- Monthly Total Days With Ideal VPD
CREATE VIEW vpd_monthly_stats AS
SELECT
    DATE_TRUNC('month', day) AS month,
    COUNT(*) FILTER (WHERE hours_in_range > 0) AS days_hitting_range,
    COUNT(*) AS total_days,
    ROUND(AVG(hours_in_range)::numeric, 2) AS avg_hours_in_range,
    ROUND(MAX(hours_in_range)::numeric, 2) AS best_day_hours
FROM vpd_daily_stats
GROUP BY DATE_TRUNC('month', day)
ORDER BY month;
