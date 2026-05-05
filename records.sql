-- Record values for given columns pulled from multiple tables to join and create one table
CREATE OR REPLACE VIEW weather_records AS

SELECT * FROM (
    SELECT 1 AS sort_order, 'High Temp' AS record,
           t.tempf::text AS value, 'degF' AS unit, t.time AS occurred
    FROM ws_observations t
    WHERE t.tempf = (SELECT MAX(tempf) FROM ws_observations)
    ORDER BY t.time DESC LIMIT 1
) ht

UNION ALL

SELECT * FROM (
    SELECT 2, 'Low Temp',
           t.tempf::text, 'degF', t.time
    FROM ws_observations t
    WHERE t.tempf = (SELECT MIN(tempf) FROM ws_observations)
    ORDER BY t.time DESC LIMIT 1
) lt

UNION ALL

SELECT * FROM (
    SELECT 3, 'High Wind Speed',
           t.windspeedmph::text, 'mph', t.time
    FROM ws_observations t
    WHERE t.windspeedmph = (SELECT MAX(windspeedmph) FROM ws_observations)
    ORDER BY t.time DESC LIMIT 1
) hws

UNION ALL

SELECT * FROM (
    SELECT 4, 'High Wind Gust',
           t.windgustmph::text, 'mph', t.time
    FROM ws_observations t
    WHERE t.windgustmph = (SELECT MAX(windgustmph) FROM ws_observations)
    ORDER BY t.time DESC LIMIT 1
) hwg

UNION ALL

SELECT * FROM (
    SELECT 5, 'High VPD',
           t.vpd::text, 'kPa', t.time
    FROM ws_observations t
    WHERE t.vpd = (SELECT MAX(vpd) FROM ws_observations WHERE vpd IS NOT NULL)
    AND t.vpd IS NOT NULL
    ORDER BY t.time DESC LIMIT 1
) hvpd

UNION ALL

SELECT * FROM (
    SELECT 6, 'Max Rain Rate',
           t.rainratein::text, 'in/h', t.time
    FROM ws_observations t
    WHERE t.rainratein = (SELECT MAX(rainratein) FROM ws_observations)
    ORDER BY t.time DESC LIMIT 1
) mrr

UNION ALL

SELECT * FROM (
    SELECT 7, 'Max Daily Rain',
           t.dailyrainin::text, 'in', t.time
    FROM rain_totals t
    WHERE t.dailyrainin = (SELECT MAX(dailyrainin) FROM rain_totals)
    ORDER BY t.time DESC LIMIT 1
) mdr

UNION ALL

SELECT * FROM (
    SELECT 8, 'Max Weekly Rain',
           t.weeklyrainin::text, 'in', t.time
    FROM rain_totals t
    WHERE t.weeklyrainin = (SELECT MAX(weeklyrainin) FROM rain_totals)
    ORDER BY t.time DESC LIMIT 1
) mwr

UNION ALL

SELECT * FROM (
    SELECT 9, 'Max Monthly Rain',
           t.monthlyrainin::text, 'in', t.time
    FROM rain_totals t
    WHERE t.monthlyrainin = (SELECT MAX(monthlyrainin) FROM rain_totals)
    ORDER BY t.time DESC LIMIT 1
) mmr

UNION ALL

SELECT * FROM (
    SELECT 10, 'Max Yearly Rain',
           t.yearlyrainin::text, 'in', t.time
    FROM rain_totals t
    WHERE t.yearlyrainin = (SELECT MAX(yearlyrainin) FROM rain_totals)
    ORDER BY t.time DESC LIMIT 1
) myr

UNION ALL

SELECT 11, 'Most Strikes in a Day',
       d.daily_total::text, 'strikes', d.day::timestamptz
FROM (
    SELECT DATE(time) AS day, MAX(lightning_num) AS daily_total
    FROM lightning_events
    GROUP BY DATE(time)
    ORDER BY daily_total DESC
    LIMIT 1
) d

UNION ALL

SELECT * FROM (
    SELECT 12, 'Closest Strike',
           t.lightning_mi::text, 'mi', t.time
    FROM lightning_events t
    WHERE t.lightning_mi = (SELECT MIN(lightning_mi) FROM lightning_events)
    ORDER BY t.time DESC LIMIT 1
) cs

UNION ALL

SELECT * FROM (
    SELECT 13, 'Max Snow Depth',
           t.depth_in::text, 'in', t.time
    FROM manual.snow_events t
    WHERE t.depth_in = (SELECT MAX(depth_in) FROM manual.snow_events WHERE event_type = 'fresh_snow')
    AND t.event_type = 'fresh_snow'
    ORDER BY t.time DESC LIMIT 1
) msd;
