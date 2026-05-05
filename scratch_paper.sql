select
    date(starttime) as forecast_day,
    count(*) as hours_in_day
from home_forecast
where updated = (
    select max(updated)
    from home_forecast
)
group by date(starttime)
order by forecast_day;



select
    max(updated) as latest_scrape,
    min(starttime) filter (where updated = max_updated) as min_start,
    max(starttime) filter (where updated = max_updated) as max_start
from (
    select *,
        max(updated) over () as max_updated
    from home_forecast
) t;



-- Weather station aggs Grafana Query
select
  to_char(period_start, 'YYYY-MM-DD') as "Week Start",
  temp_min as "Low Temp",
  temp_avg as "Avg Temp",
  temp_max as "High Temp",
  windspeed_avg as "Avg Wind",
  windgust_max as "Max Gust",
  humidity_avg as "Avg Humidity",
  uv_max as "Max UV"
from weather_weekly_aggs 
order by period_start desc;


-- Office/Console aggs Grafana Query
select
  to_char(period_start, 'YYYY-MM-DD') as "Week Start",
  temp_min as "Low Temp",
  temp_avg as "Avg Temp",
  temp_max as "High Temp",
  humidity_avg as "Avg Humidity"
from office_weekly_aggs 
order by period_start desc;



SELECT 
  DATE_TRUNC('day', starttime) AS "Day",
  forecast_pop AS "Forecast %",
  pop_bucket AS "Bucket",
  observed_precip AS "Observed"
FROM precip_accuracy
WHERE $__timeFilter(starttime)
GROUP BY DATE_TRUNC('day', starttime)
ORDER BY "Day" DESC; 



select period_start, vpd_avg from weather_hourly_aggs order by period_start asc; 


