select * from (
select cast(now() as date) as metric_date
union
select cast(now() - interval '5' day as date) as metric_date
union
select cast(now() - interval '10' day as date) as metric_date
union
select cast(now() - interval '15' day as date) as metric_date
union
select cast(now() - interval '20' day as date) as metric_date
union
select cast(now() - interval '25' day as date) as metric_date
union
select cast(now() - interval '30' day as date) as metric_date) a
order by metric_date;
