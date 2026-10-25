-- VPD (dependent view first)
DROP VIEW vpd_monthly_stats;
DROP VIEW vpd_daily_longest_window;
DROP MATERIALIZED VIEW vpd_daily_stats;

-- Rain
DROP MATERIALIZED VIEW rain_totals_monthly;

-- Weather
DROP MATERIALIZED VIEW weather_daily_aggs;
DROP MATERIALIZED VIEW weather_weekly_aggs;
DROP MATERIALIZED VIEW weather_monthly_aggs;
DROP MATERIALIZED VIEW weather_yearly_aggs;

-- Console
DROP MATERIALIZED VIEW console_daily_aggs;
DROP MATERIALIZED VIEW console_weekly_aggs;
DROP MATERIALIZED VIEW console_monthly_aggs;
DROP MATERIALIZED VIEW console_yearly_aggs;

-- Office
DROP MATERIALIZED VIEW office_daily_aggs;
DROP MATERIALIZED VIEW office_weekly_aggs;
DROP MATERIALIZED VIEW office_monthly_aggs;
DROP MATERIALIZED VIEW office_yearly_aggs;

-- Hourly weather (takes the 5 forecast/precip objects with it)
DROP MATERIALIZED VIEW weather_hourly_aggs CASCADE;




SELECT remove_continuous_aggregate_policy('weather_hourly_aggs');
SELECT add_continuous_aggregate_policy('weather_hourly_aggs',
    start_offset      => INTERVAL '3 hours',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 hour',
    initial_start     => '2026-10-25 16:01:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');

SELECT remove_continuous_aggregate_policy('console_hourly_aggs');
SELECT add_continuous_aggregate_policy('console_hourly_aggs',
    start_offset      => INTERVAL '3 hours',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 hour',
    initial_start     => '2026-10-25 16:02:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');

SELECT remove_continuous_aggregate_policy('office_hourly_aggs');
SELECT add_continuous_aggregate_policy('office_hourly_aggs',
    start_offset      => INTERVAL '3 hours',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 hour',
    initial_start     => '2026-10-25 16:03:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');

    ALTER MATERIALIZED VIEW weather_hourly_winddir SET (timescaledb.materialized_only = false);

SELECT add_continuous_aggregate_policy('weather_hourly_winddir',
    start_offset      => INTERVAL '3 hours',
    end_offset        => INTERVAL '0 minutes',
    schedule_interval => INTERVAL '1 hour',
    initial_start     => '2026-10-25 17:00:00-07'::timestamptz,
    timezone          => 'America/Los_Angeles');