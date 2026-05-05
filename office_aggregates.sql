-- Hourly
CREATE MATERIALIZED VIEW office_hourly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 hour', time) as period_start,

    MIN(temp2f) as temp_min,
    MAX(temp2f) as temp_max,
    AVG(temp2f) as temp_avg,

    AVG(humidity2) as humidity_avg,

    COUNT(*) as observations_count

FROM office_obs
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'office_hourly_aggs',
    start_offset => INTERVAL '3 hours',
    end_offset => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '5 minutes'
);


-- Daily
CREATE MATERIALIZED VIEW office_daily_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 day', time) as period_start,

    MIN(temp2f) as temp_min,
    MAX(temp2f) as temp_max,
    AVG(temp2f) as temp_avg,

    AVG(humidity2) as humidity_avg,

    COUNT(*) as observations_count

FROM office_obs
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'office_daily_aggs',
    start_offset => INTERVAL '3 days',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour'
);


-- Weekly
CREATE MATERIALIZED VIEW office_weekly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 week', time) as period_start,

    MIN(temp2f) as temp_min,
    MAX(temp2f) as temp_max,
    AVG(temp2f) as temp_avg,

    AVG(humidity2) as humidity_avg,

    COUNT(*) as observations_count

FROM office_obs
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'office_weekly_aggs',
    start_offset => INTERVAL '21 days',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day'
);


-- Monthly
CREATE MATERIALIZED VIEW office_monthly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 month', time) as period_start,

    MIN(temp2f) as temp_min,
    MAX(temp2f) as temp_max,
    AVG(temp2f) as temp_avg,

    AVG(humidity2) as humidity_avg,

    COUNT(*) as observations_count

FROM office_obs
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'office_monthly_aggs',
    start_offset => INTERVAL '3 months',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day'
);


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
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'office_yearly_aggs',
    start_offset => NULL,
    end_offset => NULL,
    schedule_interval => INTERVAL '1 week'
);

