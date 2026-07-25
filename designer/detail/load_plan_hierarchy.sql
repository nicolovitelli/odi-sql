with sls0 as (select * from snp_lp_step with read only)
,ss as (select * from snp_scen with read only)
,slp as (select * from snp_load_plan with read only)
,sls as (
	select sls0.i_load_plan as lp_no
	    ,lpad(' ', (level - 1) * 4, ' ') || sls0.lp_step_name as step_name
	    ,decode(sls0.lp_step_type
		    ,'RS'
		    ,'Run Scenario From Step'
			,'SF'
			,'Serial Step From Failure'
			,'SC'
			,'Serial Step All Children'
			,'PA'
			,'Parallel Step All Children'
			,'RN'
			,'Run Scenario New Session'
			,'RT'
			,'Run Scenario From Task'
			,'PF'
			,'Parallel Step Failed Children'
			,'SE'
			,'Root Step'
			,sls0.lp_step_type
		) as step_type
		,case when sls0.ind_enabled = 1 then 'Y' else 'N' end
			as is_enabled
		,sls0.scen_name
		,sls0.scen_version
	from sls0
	start with sls0.par_i_lp_step is null
	connect by 
	    prior sls0.i_lp_step = sls0.par_i_lp_step
	    and prior sls0.i_load_plan = sls0.i_load_plan
	order siblings by 
	    sls0.i_load_plan, 
	    sls0.step_order
)
,src as (
	select sls.lp_no
		,slp.load_plan_name as lp_name
		,sls.step_name
		,sls.step_type
		,sls.is_enabled
		,coalesce(ss.scen_no,0) as scen_no
	from sls
		left join ss
			on sls.scen_name = ss.scen_name
			and sls.scen_version = ss.scen_version
		inner join slp
			on sls.lp_no = slp.i_load_plan
)
select *
from src
order by lp_no
;