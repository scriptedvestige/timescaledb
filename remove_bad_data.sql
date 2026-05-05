-- Verify invalid data
SELECT 'ws_observations' AS table_name, COUNT(*) FROM public.ws_observations
WHERE time >= '2024-01-01' and time <= '2025-01-01'
UNION ALL
SELECT 'office_obs' AS table_name, COUNT(*) FROM public.office_obs
WHERE time >= '2024-01-01' and time <= '2025-01-01'
UNION ALL
SELECT 'console_obs' AS table_name, COUNT(*) FROM public.console_obs
WHERE time >= '2024-01-01' and time <= '2025-01-01'
UNION ALL
SELECT 'rain_totals' AS table_name, COUNT(*) FROM public.rain_totals
WHERE time >= '2024-01-01' and time <= '2025-01-01';

SELECT 'manual.snow_events' as table_name, COUNT(*) FROM manual.snow_events
WHERE notes LIKE '%TEST%';

-- Delete invalid data
BEGIN;
DELETE FROM public.ws_observations
WHERE time >= '2024-01-01' and time <= '2025-01-01';
DELETE FROM public.office_obs
WHERE time >= '2024-01-01' and time <= '2025-01-01';
DELETE FROM public.console_obs
WHERE time >= '2024-01-01' and time <= '2025-01-01';
DELETE FROM public.rain_totals
WHERE time >= '2024-01-01' and time <= '2025-01-01';
COMMIT;

DELETE FROM manual.snow_events
WHERE notes LIKE '%TEST%';

-- Vacuum
VACUUM ANALYZE public.ws_observations;
VACUUM ANALYZE public.office_obs;
VACUUM ANALYZE public.console_obs;
VACUUM ANALYZE public.rain_totals;
VACUUM ANALYZE manual.snow_events;

-- Refresh aggregates
CALL refresh_continuous_aggregate('console_hourly_aggs', '2024-01-01', now());
CALL refresh_continuous_aggregate('office_hourly_aggs', '2024-01-01', now());
CALL refresh_continuous_aggregate('weather_hourly_aggs', '2024-01-01', now());
CALL refresh_continuous_aggregate('weather_hourly_winddir', '2024-01-01', now());

CALL refresh_continuous_aggregate('console_daily_aggs', '2024-01-01', now());
CALL refresh_continuous_aggregate('office_daily_aggs', '2024-01-01', now());
CALL refresh_continuous_aggregate('weather_daily_aggs', '2024-01-01', now());

CALL refresh_continuous_aggregate('console_weekly_aggs', '2024-01-01', now());
CALL refresh_continuous_aggregate('office_weekly_aggs', '2024-01-01', now());
CALL refresh_continuous_aggregate('weather_weekly_aggs', '2024-01-01', now());

CALL refresh_continuous_aggregate('console_monthly_aggs', '2024-01-01', now());
CALL refresh_continuous_aggregate('office_monthly_aggs', '2024-01-01', now());
CALL refresh_continuous_aggregate('weather_monthly_aggs', '2024-01-01', now());

CALL refresh_continuous_aggregate('console_yearly_aggs', '2024-01-01', now());
CALL refresh_continuous_aggregate('office_yearly_aggs', '2024-01-01', now());
CALL refresh_continuous_aggregate('weather_yearly_aggs', '2024-01-01', now());