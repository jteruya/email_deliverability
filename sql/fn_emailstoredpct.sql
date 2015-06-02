drop function if exists jt.fn_emailstoredpct();

create function jt.fn_emailstoredpct()
returns table (  metric_desc varchar
               , metric_val_30 decimal(15,4)
               , metric_val_25 decimal(15,4)
               , metric_val_20 decimal(15,4)
               , metric_val_15 decimal(15,4)
               , metric_val_10 decimal(15,4)
               , metric_val_5 decimal(15,4)
               , metric_val_0 decimal(15,4)) as $$
        select cast('stored:' as varchar) || emailsubjectcatg || ':' || eventtype as metric_desc
             , case
                 when sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -30 as date) then count else 0 end) > 0 then cast(cast(sum(case when eventstatus = 'stored' and mailgundate < cast(now() + interval '1' day * -30 as date) then count else 0 end) as decimal(15,4))/cast(sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -30 as date) then count else 0 end) as decimal(15,4)) as decimal(15,4)) * 100
                 else null
               end as metric_val_30
             , case
                 when sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -25 as date) then count else 0 end) > 0 then cast(cast(sum(case when eventstatus = 'stored' and mailgundate < cast(now() + interval '1' day * -25 as date) then count else 0 end) as decimal(15,4))/cast(sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -25 as date) then count else 0 end) as decimal(15,4)) as decimal(15,4)) * 100
                 else null
               end as metric_val_25
             , case
                 when sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -20 as date) then count else 0 end) > 0 then cast(cast(sum(case when eventstatus = 'stored' and mailgundate < cast(now() + interval '1' day * -20 as date) then count else 0 end) as decimal(15,4))/cast(sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -20 as date) then count else 0 end) as decimal(15,4)) as decimal(15,4)) * 100
                 else null
               end as metric_val_20
             , case
                 when sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -15 as date) then count else 0 end) > 0 then cast(cast(sum(case when eventstatus = 'stored' and mailgundate < cast(now() + interval '1' day * -15 as date) then count else 0 end) as decimal(15,4))/cast(sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -15 as date) then count else 0 end) as decimal(15,4)) as decimal(15,4)) * 100
                 else null
               end as metric_val_15
             , case
                 when sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -10 as date) then count else 0 end) > 0 then cast(cast(sum(case when eventstatus = 'stored' and mailgundate < cast(now() + interval '1' day * -10 as date) then count else 0 end) as decimal(15,4))/cast(sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -10 as date) then count else 0 end) as decimal(15,4)) as decimal(15,4)) * 100
                 else null
               end as metric_val_10
             , case
                 when sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -5 as date) then count else 0 end) > 0 then cast(cast(sum(case when eventstatus = 'stored' and mailgundate < cast(now() + interval '1' day * -5 as date) then count else 0 end) as decimal(15,4))/cast(sum(case when eventstatus = 'delivered' and mailgundate < cast(now() + interval '1' day * -5 as date) then count else 0 end) as decimal(15,4)) as decimal(15,4)) * 100
                 else null
               end as metric_val_5
             , case
                 when sum(case when eventstatus = 'delivered' and mailgundate < cast(now() as date) then count else 0 end) > 0 then cast(cast(sum(case when eventstatus = 'stored' and mailgundate < cast(now() as date) then count else 0 end) as decimal(15,4))/cast(sum(case when eventstatus = 'delivered' and mailgundate < cast(now() as date) then count else 0 end) as decimal(15,4)) as decimal(15,4)) * 100
                 else null
               end as metric_val_0
        from jt.mailgun_events_aggregate_delivered
        group by eventtype, emailsubjectcatg
$$ language sql;
