-- Hourly
CREATE MATERIALIZED VIEW console_hourly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 hour', time, 'America/Los_Angeles') as period_start,

    MIN(tempinf) as temp_min,
    MAX(tempinf) as temp_max,
    AVG(tempinf) as temp_avg,

    AVG(humidityin) as humidity_avg,

    COUNT(*) as observations_count

FROM console_obs
GROUP BY period_start
WITH NO DATA;


-- Hourly: runs at :02
SELECT add_continuous_aggregate_policy('console_hourly_aggs',
    start_offset      => INTERVAL '3 hours',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 hour',
    initial_start     => '2026-10-26 00:02:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');


-- Daily
CREATE MATERIALIZED VIEW console_daily_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 day', time, 'America/Los_Angeles') as period_start,

    MIN(tempinf) as temp_min,
    MAX(tempinf) as temp_max,
    AVG(tempinf) as temp_avg,

    AVG(humidityin) as humidity_avg,

    COUNT(*) as observations_count

FROM console_obs
GROUP BY period_start
WITH NO DATA;


-- Daily: runs at :05
SELECT add_continuous_aggregate_policy('console_daily_aggs',
    start_offset      => INTERVAL '3 days',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 hour',
    initial_start     => '2026-10-25 17:05:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');


-- Weekly
CREATE MATERIALIZED VIEW console_weekly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 week', time, 'America/Los_Angeles', "offset" => INTERVAL '-1 day') as period_start,

    MIN(tempinf) as temp_min,
    MAX(tempinf) as temp_max,
    AVG(tempinf) as temp_avg,

    AVG(humidityin) as humidity_avg,

    COUNT(*) as observations_count

FROM console_obs
GROUP BY period_start
WITH NO DATA;


-- Weekly: runs at :08
SELECT add_continuous_aggregate_policy('console_weekly_aggs',
    start_offset      => INTERVAL '3 weeks',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 day',
    initial_start     => '2026-10-26 00:08:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');


-- Monthly
CREATE MATERIALIZED VIEW console_monthly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 month', time, 'America/Los_Angeles') as period_start,

    MIN(tempinf) as temp_min,
    MAX(tempinf) as temp_max,
    AVG(tempinf) as temp_avg,

    AVG(humidityin) as humidity_avg,

    COUNT(*) as observations_count

FROM console_obs
GROUP BY period_start
WITH NO DATA;


-- Monthly: runs daily at 00:11 local
SELECT add_continuous_aggregate_policy('console_monthly_aggs',
    start_offset      => INTERVAL '3 months',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 day',
    initial_start     => '2026-10-26 00:11:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');


-- Yearly
CREATE MATERIALIZED VIEW console_yearly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 year', time, 'America/Los_Angeles') as period_start,

    MIN(tempinf) as temp_min,
    MAX(tempinf) as temp_max,
    AVG(tempinf) as temp_avg,

    AVG(humidityin) as humidity_avg,

    COUNT(*) as observations_count

FROM console_obs
GROUP BY period_start
WITH NO DATA;


-- Yearly: runs daily at 00:14 local
SELECT add_continuous_aggregate_policy('console_yearly_aggs',
    start_offset      => INTERVAL '3 years',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 day',
    initial_start     => '2026-10-26 00:14:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');

