-- Home
CREATE or replace VIEW home_forecast_daily_aggs AS 
WITH latest_scrape as (
    select *
    from home_forecast 
    where updated = (
        select max(updated) from home_forecast
    )
)
SELECT 
    date(starttime) as forecast_day,
    MIN(temp) as temp_min,
    MAX(temp) as temp_max,
    MAX(precip) as precip_max,
    MAX(windspeed) as windspeed_max,
    MAX(humidity) as humidity
FROM latest_scrape
GROUP BY date(starttime)
ORDER BY forecast_day DESC;

-- Grafana home query
select 
  forecast_day as "Date",
  temp_min as "Low Temp",
  temp_max as "High Temp",
  precip_max as "Precip",
  windspeed_max as "Wind",
  humidity as "Humidity"
from home_forecast_daily_aggs
where forecast_day >= CURRENT_DATE
and forecast_day < CURRENT_DATE + INTERVAL '7 days'
order by "Date" asc;


-- Work
CREATE VIEW work_forecast_daily_aggs AS 
WITH latest_scrape AS (
    SELECT *
    FROM work_forecast
    WHERE updated = (select max(updated) from work_forecast)
)
SELECT 
    date(starttime) as forecast_day,
    MIN(temp) as temp_min,
    MAX(temp) as temp_max,
    MAX(precip) as precip_max,
    MAX(windspeed) as windspeed_max,
    MAX(humidity) as humidity
FROM latest_scrape
GROUP BY date(starttime)
ORDER BY forecast_day DESC;


-- Grafana work query
select 
  forecast_day as "Date",
  temp_min as "Low Temp",
  temp_max as "High Temp",
  precip_max as "Precip",
  windspeed_max as "Wind",
  humidity as "Humidity"
from work_forecast_daily_aggs
where forecast_day >= CURRENT_DATE
and forecast_day < CURRENT_DATE + INTERVAL '7 days'
order by "Date" asc;

