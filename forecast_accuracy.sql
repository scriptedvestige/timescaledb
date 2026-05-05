-- Create daily view
CREATE MATERIALIZED VIEW forecast_accuracy AS
SELECT
    fc.starttime,
    EXTRACT(MONTH FROM fc.starttime) AS month,

    fc.temp AS forecast_temp,
    obs.temp_avg AS observed_temp,
    obs.temp_avg - fc.temp AS temp_delta,

    fc.windspeed AS forecast_wind,
    obs.windspeed_avg AS observed_wind,
    obs.windspeed_avg - fc.windspeed AS wind_delta,

    fc.humidity AS forecast_humidity,
    obs.humidity_avg AS observed_humidity,
    obs.humidity_avg - fc.humidity AS humidity_delta
FROM (
    SELECT DISTINCT ON (starttime) *
    FROM home_forecast
    ORDER BY starttime, updated DESC
) fc
JOIN weather_hourly_aggs obs ON obs.period_start = fc.starttime
WHERE obs.period_start < NOW();

-- Create daily procedure
CREATE OR REPLACE PROCEDURE refresh_forecast_accuracy(jobid int, config jsonb)
LANGUAGE SQL AS $$
    REFRESH MATERIALIZED VIEW forecast_accuracy;
$$;

-- Create daily job
SELECT add_job('refresh_forecast_accuracy', '1 hour');

-- Create summary view
CREATE VIEW forecast_accuracy_monthly AS
SELECT
    EXTRACT(YEAR FROM starttime) as year,
    month,
    ROUND(AVG(temp_delta)::numeric, 2) AS avg_temp_delta,
    ROUND(AVG(wind_delta)::numeric, 2) AS avg_wind_delta,
    ROUND(AVG(humidity_delta)::numeric, 2) AS avg_humidity_delta,
    COUNT(*) AS sample_count
FROM forecast_accuracy
GROUP BY year, month
ORDER BY year, month;

-- How often does it rain when NWS calls for rain?
CREATE MATERIALIZED VIEW precip_accuracy AS
SELECT
    fc.starttime,
    EXTRACT(YEAR FROM fc.starttime) AS year,
    EXTRACT(MONTH FROM fc.starttime) AS month,
    fc.precip as forecast_pop,
    CASE
        WHEN fc.precip BETWEEN 1 AND 25 THEN '1-25%'
        WHEN fc.precip BETWEEN 26 AND 50 THEN '26-50%'
        WHEN fc.precip BETWEEN 51 AND 75 THEN '51-75%'
        WHEN fc.precip BETWEEN 76 AND 100 THEN '76-100%'
    END AS pop_bucket,
    obs.rain_total_hour AS observed_precip,
    CASE WHEN obs.rain_total_hour > 0 THEN true ELSE false END AS did_rain
FROM (
    SELECT DISTINCT ON (starttime) *
    FROM home_forecast
    ORDER BY starttime, updated DESC
) fc
JOIN weather_hourly_aggs obs ON obs.period_start = fc.starttime
WHERE fc.precip > 0
AND obs.period_start < NOW();

-- Procedure to refresh
CREATE OR REPLACE PROCEDURE refresh_precip_accuracy(jobid int, config jsonb)
    LANGUAGE SQL AS $$
        REFRESH MATERIALIZED VIEW precip_accuracy;
    $$;

-- Create job to run proc
SELECT add_job('refresh_precip_accuracy', '1 hour');

-- Monthly summary
CREATE VIEW precip_accuracy_summary AS
SELECT
    year,
    month,
    pop_bucket,
    COUNT(*) as total_hours,
    SUM(CASE WHEN did_rain THEN 1 ELSE 0 END) AS hours_rained,
    ROUND((SUM(CASE WHEN did_rain THEN 1 ELSE 0 END)::numeric / COUNT(*)) * 100, 1) AS pct_accurate
FROM precip_accuracy
GROUP BY year, month, pop_bucket
ORDER BY year, month, pop_bucket;

-- How often does it rain when NWS doesn't call for it?
CREATE VIEW precip_surprise AS
SELECT
    fc.starttime,
    EXTRACT(YEAR FROM fc.starttime) AS year,
    EXTRACT(MONTH FROM fc.starttime) AS month,
    obs.rain_total_hour AS observed_precip
FROM (
    SELECT DISTINCT ON (starttime) *
    FROM home_forecast
    ORDER BY starttime, updated DESC
) fc
JOIN weather_hourly_aggs obs ON obs.period_start = fc.starttime
WHERE fc.precip = 0
AND obs.rain_total_hour > 0
AND obs.period_start < NOW();