-- First raw query
-- This measures most recent versus oldest where the values are flipped from what I wanted (larger numbers as T-x reduces)
-- This also shows values for every single timestamp
SELECT
    starttime,
    updated,
    temp,
    temp - FIRST_VALUE(temp) OVER (
        PARTITION BY starttime
        ORDER BY updated
    ) AS temp_drift_from_first,
    windspeed - FIRST_VALUE(windspeed) OVER (
        PARTITION BY starttime
        ORDER BY updated
    ) as wind_drift_from_first,
    precip - FIRST_VALUE(precip) OVER (
        PARTITION BY starttime
        ORDER BY updated
    ) AS precip_drift_from_first,
    COUNT(*) OVER (PARTITION BY starttime) AS snapshot_count,
    updated - starttime AS hours_until_event
FROM home_forecast
WHERE starttime >= NOW() - INTERVAL '30 days'
ORDER BY starttime, updated;


-- Second raw query
-- This flips the query to what I want old minus new and shows averages for given hours out
WITH drift AS(
    SELECT
        starttime,
        updated,
        ROUND(EXTRACT(EPOCH FROM (starttime - updated)) / 3600) AS hours_out,
        ABS(temp - LAST_VALUE(temp) OVER (
            PARTITION BY starttime ORDER BY updated
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )) as temp_drift,
        ABS(windspeed - LAST_VALUE(windspeed) OVER (
            PARTITION BY starttime ORDER BY updated
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )) as wind_drift,
        ABS(precip - LAST_VALUE(precip) OVER (
            PARTITION BY starttime ORDER BY updated
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )) as precip_drift
    FROM home_forecast
    WHERE starttime >= NOW() - INTERVAL '30 days'
        AND starttime > updated
)
SELECT 
    hours_out,
    ROUND(AVG(temp_drift)::numeric, 2) AS avg_temp_drift,
    ROUND(AVG(wind_drift)::numeric, 2) AS avg_wind_drift,
    ROUND(AVG(precip_drift)::numeric, 2) AS avg_precip_drift,
    COUNT(*) AS sample_count
FROM drift
GROUP BY hours_out
ORDER BY hours_out DESC;


-- Now we want to take the raw query, make a view with it, then schedule a cron job to refresh it
CREATE MATERIALIZED VIEW home_forecast_drift AS
WITH drift AS(
    SELECT
        starttime,
        updated,
        ROUND(EXTRACT(EPOCH FROM (starttime - updated)) / 3600) AS hours_out,
        ABS(temp - LAST_VALUE(temp) OVER (
            PARTITION BY starttime ORDER BY updated
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )) as temp_drift,
        ABS(windspeed - LAST_VALUE(windspeed) OVER (
            PARTITION BY starttime ORDER BY updated
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )) as wind_drift,
        ABS(precip - LAST_VALUE(precip) OVER (
            PARTITION BY starttime ORDER BY updated
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )) as precip_drift
    FROM home_forecast
    WHERE starttime > updated
)
SELECT 
    hours_out AS "Hours Out",
    ROUND(AVG(temp_drift)::numeric, 2) AS "Avg Temp Drift",
    ROUND(AVG(wind_drift)::numeric, 2) AS "Avg Wind Drift",
    ROUND(AVG(precip_drift)::numeric, 2) AS "Avg Precip Drift",
    COUNT(*) AS "Sample Count"
FROM drift
GROUP BY "Hours Out"
ORDER BY "Hours Out" DESC;


CREATE MATERIALIZED VIEW work_forecast_drift AS
WITH drift AS(
    SELECT
        starttime,
        updated,
        ROUND(EXTRACT(EPOCH FROM (starttime - updated)) / 3600) AS hours_out,
        ABS(temp - LAST_VALUE(temp) OVER (
            PARTITION BY starttime ORDER BY updated
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )) as temp_drift,
        ABS(windspeed - LAST_VALUE(windspeed) OVER (
            PARTITION BY starttime ORDER BY updated
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )) as wind_drift,
        ABS(precip - LAST_VALUE(precip) OVER (
            PARTITION BY starttime ORDER BY updated
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )) as precip_drift
    FROM work_forecast
    WHERE starttime > updated
)
SELECT 
    hours_out as "Hours Out",
    ROUND(AVG(temp_drift)::numeric, 2) AS "Avg Temp Drift",
    ROUND(AVG(wind_drift)::numeric, 2) AS "Avg Wind Drift",
    ROUND(AVG(precip_drift)::numeric, 2) AS "Avg Precip Drift",
    COUNT(*) AS "Sample Count"
FROM drift
GROUP BY "Hours Out"
ORDER BY "Hours Out" DESC;


SELECT cron.schedule('refresh-home-forecast-drift', '0 */6 * * *',
    'REFRESH MATERIALIZED VIEW home_forecast_drift;');

-- My Timescale image doesn't support pg_cron, so I'll need to schedule a cron job from the Pi
-- to refresh the views.  Created bash script to refresh all views in one shot using PSQL command.
-- This required setting the credentials in a ~/.pgpass file so the script wouldn't be prompted for
-- credentials when running.  Logging to log file in directory with logrotate configured.  Cron tab 
-- entry made to run every six hours.  Once the views were created and the cron job configured,
-- I created a dashboard in Grafana with panels for each view to display the analysis data.
