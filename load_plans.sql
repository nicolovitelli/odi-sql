/*
  extracts all load plans available in ODI.
*/
with slp as (select * from snp_load_plan with read only)
select
	slp.i_load_plan as lp_no
	,slp.load_plan_name as lp_name
	,to_char(slp.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(slp.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from slp
;