-- Hourly
CREATE MATERIALIZED VIEW office_hourly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 hour', time, 'America/Los_Angeles') as period_start,

    MIN(temp2f) as temp_min,
    MAX(temp2f) as temp_max,
    AVG(temp2f) as temp_avg,

    AVG(humidity2) as humidity_avg,

    COUNT(*) as observations_count

FROM office_obs
GROUP BY period_start
WITH NO DATA;


-- Hourly: runs at :03
SELECT add_continuous_aggregate_policy('office_hourly_aggs',
    start_offset      => INTERVAL '3 hours',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 hour',
    initial_start     => '2026-10-26 00:03:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');


-- Daily
CREATE MATERIALIZED VIEW office_daily_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 day', time, 'America/Los_Angeles') as period_start,

    MIN(temp2f) as temp_min,
    MAX(temp2f) as temp_max,
    AVG(temp2f) as temp_avg,

    AVG(humidity2) as humidity_avg,

    COUNT(*) as observations_count

FROM office_obs
GROUP BY period_start
WITH NO DATA;


-- Daily: runs at :06
SELECT add_continuous_aggregate_policy('office_daily_aggs',
    start_offset      => INTERVAL '3 days',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 hour',
    initial_start     => '2026-10-25 17:06:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');


-- Weekly
CREATE MATERIALIZED VIEW office_weekly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 week', time, 'America/Los_Angeles', "offset" => INTERVAL '-1 day') as period_start,

    MIN(temp2f) as temp_min,
    MAX(temp2f) as temp_max,
    AVG(temp2f) as temp_avg,

    AVG(humidity2) as humidity_avg,

    COUNT(*) as observations_count

FROM office_obs
GROUP BY period_start
WITH NO DATA;


-- Weekly: runs at :09
SELECT add_continuous_aggregate_policy('office_weekly_aggs',
    start_offset      => INTERVAL '3 weeks',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 day',
    initial_start     => '2026-10-26 00:09:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');


-- Monthly
CREATE MATERIALIZED VIEW office_monthly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 month', time, 'America/Los_Angeles') as period_start,

    MIN(temp2f) as temp_min,
    MAX(temp2f) as temp_max,
    AVG(temp2f) as temp_avg,

    AVG(humidity2) as humidity_avg,

    COUNT(*) as observations_count

FROM office_obs
GROUP BY period_start
WITH NO DATA;


-- Monthly: runs daily at 00:12 local
SELECT add_continuous_aggregate_policy('office_monthly_aggs',
    start_offset      => INTERVAL '3 months',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 day',
    initial_start     => '2026-10-26 00:12:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');


-- Yearly
CREATE MATERIALIZED VIEW office_yearly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 year', time) as period_start,

    MIN(temp2f) as temp_min,
    MAX(temp2f) as temp_max,
    AVG(temp2f) as temp_avg,

    AVG(humidity2) as humidity_avg,

    COUNT(*) as observations_count

FROM office_obs
GROUP BY period_start
WITH NO DATA;


-- Yearly: runs daily at 00:15 local
SELECT add_continuous_aggregate_policy('office_yearly_aggs',
    start_offset      => INTERVAL '3 years',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 day',
    initial_start     => '2026-10-26 00:15:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');

