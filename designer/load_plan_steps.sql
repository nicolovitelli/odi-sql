with sls as (select * from snp_lp_step with read only)
,ss as (select * from snp_scen with read only)
,slp as (select * from snp_load_plan with read only)
select
	slp.i_load_plan as lp_no
	,ss.scen_no
	,case when sls.ind_enabled = 1 then 'Y' else 'N' end
		as is_enabled
from sls
	inner join ss
		on sls.scen_name = ss.scen_name
	inner join slp
		on sls.i_load_plan = slp.i_load_plan
order by slp.i_load_plan, ss.scen_no
;