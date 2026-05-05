-- Hourly
CREATE MATERIALIZED VIEW console_hourly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 hour', time) as period_start,

    MIN(tempinf) as temp_min,
    MAX(tempinf) as temp_max,
    AVG(tempinf) as temp_avg,

    AVG(humidityin) as humidity_avg,

    COUNT(*) as observations_count

FROM console_obs
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'console_hourly_aggs',
    start_offset => INTERVAL '3 hours',
    end_offset => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '5 minutes'
);


-- Daily
CREATE MATERIALIZED VIEW console_daily_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 day', time) as period_start,

    MIN(tempinf) as temp_min,
    MAX(tempinf) as temp_max,
    AVG(tempinf) as temp_avg,

    AVG(humidityin) as humidity_avg,

    COUNT(*) as observations_count

FROM console_obs
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'console_daily_aggs',
    start_offset => INTERVAL '3 days',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour'
);


-- Weekly
CREATE MATERIALIZED VIEW console_weekly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 week', time) as period_start,

    MIN(tempinf) as temp_min,
    MAX(tempinf) as temp_max,
    AVG(tempinf) as temp_avg,

    AVG(humidityin) as humidity_avg,

    COUNT(*) as observations_count

FROM console_obs
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'console_weekly_aggs',
    start_offset => INTERVAL '21 days',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day'
);


-- Monthly
CREATE MATERIALIZED VIEW console_monthly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 month', time) as period_start,

    MIN(tempinf) as temp_min,
    MAX(tempinf) as temp_max,
    AVG(tempinf) as temp_avg,

    AVG(humidityin) as humidity_avg,

    COUNT(*) as observations_count

FROM console_obs
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'console_monthly_aggs',
    start_offset => INTERVAL '3 months',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day'
);


-- Yearly
CREATE MATERIALIZED VIEW console_yearly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 year', time) as period_start,

    MIN(tempinf) as temp_min,
    MAX(tempinf) as temp_max,
    AVG(tempinf) as temp_avg,

    AVG(humidityin) as humidity_avg,

    COUNT(*) as observations_count

FROM console_obs
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'console_yearly_aggs',
    start_offset => NULL,
    end_offset => NULL,
    schedule_interval => INTERVAL '1 week'
);

