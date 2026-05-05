CREATE MATERIALIZED VIEW weather_hourly_winddir
WITH (timescaledb.continuous) AS 
SELECT
    time_bucket('1 hour', time) as period_start,

    -- Circular mean
    CASE
        WHEN DEGREES(ATAN2(
            AVG(SIN(RADIANS(winddir))),
            AVG(COS(RADIANS(winddir)))
            )) < 0
        THEN DEGREES(ATAN2(
            AVG(SIN(RADIANS(winddir))),
            AVG(COS(RADIANS(winddir)))
            )) + 360
        ELSE DEGREES(ATAN2(
            AVG(SIN(RADIANS(winddir))),
            AVG(COS(RADIANS(winddir)))
            ))
    END AS winddir_mean,

    -- Vector magnitude (tells you how consistent direction was)
    SQRT(
        POWER(AVG(COS(RADIANS(winddir))), 2) +
        POWER(AVG(COS(RADIANS(winddir))), 2)
    ) AS winddir_consistency,

    COUNT(*) as observations_count

FROM ws_observations
GROUP BY period_start;


SELECT add_continuous_aggregate_policy(
    'weather_hourly_winddir',
    start_offset => INTERVAL '3 hours',
    end_offset => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '5 minutes'
);

