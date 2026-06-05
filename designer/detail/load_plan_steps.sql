with sls0 as (select * from snp_lp_step with read only)
,ss as (select * from snp_scen with read only)
,slp as (select * from snp_load_plan with read only)
,sls as (
	select
		slp.i_load_plan as lp_no
		,slp.load_plan_name as lp_name
		,ss.scen_no
		,ss.scen_name
		,case when sls0.ind_enabled = 1 then 'Y' else 'N' end
			as is_enabled
	from sls0
		inner join ss
			on sls0.scen_name = ss.scen_name
		inner join slp
			on sls0.i_load_plan = slp.i_load_plan
)
select *
from sls
order by lp_no, scen_no
;