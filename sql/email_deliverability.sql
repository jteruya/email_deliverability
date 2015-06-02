drop table if exists jt.email_deliverability_metrics;

create table jt.email_deliverability_metrics (
      metric_desc text
      , metric_val_30 decimal
      , metric_val_25 decimal
      , metric_val_20 decimal
      , metric_val_15 decimal
      , metric_val_10 decimal
      , metric_val_5 decimal
      , metric_val_0 decimal
      , primary key (metric_desc)
);

insert into jt.email_deliverability_metrics
select * from jt.fn_emaildeliveredpct();

insert into jt.email_deliverability_metrics
select * from jt.fn_emailopenedpct();

insert into jt.email_deliverability_metrics
select * from jt.fn_emailclickedpct();

insert into jt.email_deliverability_metrics
select * from jt.fn_emailunsubscribedpct();

insert into jt.email_deliverability_metrics
select * from jt.fn_emailstoredpct();

insert into jt.email_deliverability_metrics
select * from jt.fn_emailcomplainedpct();
