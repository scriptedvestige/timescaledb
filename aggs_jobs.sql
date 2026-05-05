-- View all jobs
select
    job_id,
    hypertable_name,
    schedule_interval,
    next_start
from timescaledb_information.jobs
order by next_start asc;


-- Alter job runtime in UTC timezone
select alter_job(
    [id],
    next_start => '2026-02-22 00:00:00'
);


-- Example
select alter_job(
    1027,
    next_start => '2026-02-23 08:08:00'
);


-- Check real-time aggregates enabled
select view_name, materialized_only
from timescaledb_information.continuous_aggregates;


-- Enable real-time aggregates
alter materialized view [your_view_name]
set (timescaledb.materialized_only = false);


alter materialized view office_daily_aggs
set (timescaledb.materialized_only = false);


-- Check last successful refresh
SELECT  js.* FROM
   timescaledb_information.job_stats js, 
   timescaledb_information.continuous_aggregates cagg
WHERE cagg.view_name = 'weather_daily_aggs' 
  and cagg.materialization_hypertable_name = js.hypertable_name;
