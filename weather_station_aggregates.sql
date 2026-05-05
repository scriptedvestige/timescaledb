-- Hourly
CREATE MATERIALIZED VIEW weather_hourly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 hour', time) AS period_start,

    MIN(tempf) as temp_min,
    MAX(tempf) as temp_max,
    AVG(tempf) as temp_avg,

    AVG(humidity) as humidity_avg,

    AVG(baromabsin) as pressure_avg,

    AVG(windspeedmph) as windspeed_avg,
    MAX(windspeedmph) as windspeed_max,
    MAX(windgustmph) as windgust_max,

    AVG(solarradiation) as solar_avg,
    MAX(solarradiation) as solar_max,

    AVG(uv) as uv_avg,
    MAX(uv) as uv_max,

    AVG(eventrainin) as rain_rate_avg,
    MAX(eventrainin) as rain_rate_max,

    MAX(eventrainin) - MIN(eventrainin) as rain_total_hour,

    AVG(vpd) as vpd_avg,

    COUNT(*) as observations_count

FROM ws_observations
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'weather_hourly_aggs',
    start_offset => INTERVAL '3 hours',
    end_offset => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '5 minutes'
);


-- Daily
CREATE MATERIALIZED VIEW weather_daily_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 day', time) AS period_start,

    MIN(tempf) as temp_min,
    MAX(tempf) as temp_max,
    AVG(tempf) as temp_avg,

    AVG(humidity) as humidity_avg,

    AVG(baromabsin) as pressure_avg,

    AVG(windspeedmph) as windspeed_avg,
    MAX(windspeedmph) as windspeed_max,
    MAX(windgustmph) as windgust_max,

    AVG(solarradiation) as solar_avg,
    MAX(solarradiation) as solar_max,

    AVG(uv) as uv_avg,
    MAX(uv) as uv_max,

    COUNT(*) as observations_count

FROM ws_observations
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'weather_daily_aggs',
    start_offset => INTERVAL '3 days',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour'
);


-- Weekly
CREATE MATERIALIZED VIEW weather_weekly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 week', time) AS period_start,

    MIN(tempf) as temp_min,
    MAX(tempf) as temp_max,
    AVG(tempf) as temp_avg,

    AVG(humidity) as humidity_avg,

    AVG(baromabsin) as pressure_avg,

    AVG(windspeedmph) as windspeed_avg,
    MAX(windspeedmph) as windspeed_max,
    MAX(windgustmph) as windgust_max,

    AVG(solarradiation) as solar_avg,
    MAX(solarradiation) as solar_max,

    AVG(uv) as uv_avg,
    MAX(uv) as uv_max,

    COUNT(*) as observations_count

FROM ws_observations
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'weather_weekly_aggs',
    start_offset => INTERVAL '21 days',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day'
);


-- Monthly
CREATE MATERIALIZED VIEW weather_monthly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 month', time) AS period_start,

    MIN(tempf) as temp_min,
    MAX(tempf) as temp_max,
    AVG(tempf) as temp_avg,

    AVG(humidity) as humidity_avg,

    AVG(baromabsin) as pressure_avg,

    AVG(windspeedmph) as windspeed_avg,
    MAX(windspeedmph) as windspeed_max,
    MAX(windgustmph) as windgust_max,

    AVG(solarradiation) as solar_avg,
    MAX(solarradiation) as solar_max,

    AVG(uv) as uv_avg,
    MAX(uv) as uv_max,

    COUNT(*) as observations_count

FROM ws_observations
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'weather_monthly_aggs',
    start_offset => INTERVAL '3 months',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day'
);


-- Yearly
CREATE MATERIALIZED VIEW weather_yearly_aggs
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 year', time) AS period_start,

    MIN(tempf) as temp_min,
    MAX(tempf) as temp_max,
    AVG(tempf) as temp_avg,

    AVG(humidity) as humidity_avg,

    AVG(baromabsin) as pressure_avg,

    AVG(windspeedmph) as windspeed_avg,
    MAX(windspeedmph) as windspeed_max,
    MAX(windgustmph) as windgust_max,

    AVG(solarradiation) as solar_avg,
    MAX(solarradiation) as solar_max,

    AVG(uv) as uv_avg,
    MAX(uv) as uv_max,

    COUNT(*) as observations_count

FROM ws_observations
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'weather_yearly_aggs',
    start_offset => NULL,
    end_offset => NULL,
    schedule_interval => INTERVAL '1 week'
);


-- Troubleshooting
SELECT pg_get_viewdef('weather_yearly_aggs', true);
SELECT pg_get_viewdef('weather_monthly_aggs', true);

SELECT * FROM timescaledb_information.continuous_aggregates
WHERE view_name IN ('weather_yearly_aggs', 'weather_monthly_aggs');

SELECT * FROM timescaledb_information.chunks
WHERE hypertable_name = '_materialized_hypertable_22'
ORDER BY range_start DESC
LIMIT 5;

CALL refresh_continuous_aggregate('weather_yearly_aggs', '2024-01-01', now());

CALL timescaledb_experimental.refresh_continuous_aggregate_with_no_max_invalidation_lag(
    'weather_yearly_aggs', '2024-01-01', now()
);

CALL refresh_continuous_aggregate('weather_yearly_aggs', NULL, NULL);