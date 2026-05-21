/*
  extracts all load plan executions after a given date.
*/
with slr as (select * from snp_lpi_run with read only)
,sli as (select * from snp_lp_inst with read only)
,slp as (select * from snp_load_plan with read only)
select
	slr.i_lp_inst as lp_exec_no
	,slp.i_load_plan as lp_no
	,slp.load_plan_name as lp_name
	,to_char(slr.start_date,'yyyy-mm-dd hh24:mi:ss') as start_ts
	,to_char(slr.end_date,'yyyy-mm-dd hh24:mi:ss') as end_ts
	,round(slr.duration) as duration_sec
	,slr.status as status
	,slr.error_message as error_msg
from slr
	inner join sli
		on slr.i_lp_inst = sli.i_lp_inst
	inner join slp
		on sli.i_load_plan = slp.i_load_plan
where slr.start_date > to_date(:bvDate,'yyyy-mm-dd hh24:mi:ss')
;