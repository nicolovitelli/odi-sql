/*
  extracts all contexts available in ODI.
*/
with sc as (select * from snp_context with read only)
select
	sc.i_context as cont_no
	,context_name as context_name
	,context_code
	,to_char(first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from sc
;