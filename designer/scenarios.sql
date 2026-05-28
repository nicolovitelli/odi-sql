with ss as (select * from snp_scen with read only)
select
	ss.scen_no
	,ss.scen_name
	,coalesce(ss.i_package,0) as pkg_no
	,to_char(ss.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(ss.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from ss
;