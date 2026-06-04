with slp0 as (select * from snp_lp_step with read only)
,ss as (select * from snp_scen with read only)
,slp as (
	select slp0.i_load_plan as lp_no
	    ,lpad(' ', (level - 1) * 4, ' ') || slp0.lp_step_name as step_name
	    ,decode(slp0.lp_step_type
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
			,slp0.lp_step_type
		) as step_type
		,slp0.scen_name
		,slp0.scen_version
	from slp0
	start with slp0.par_i_lp_step is null
	connect by 
	    prior slp0.i_lp_step = slp0.par_i_lp_step
	    and prior slp0.i_load_plan = slp0.i_load_plan
	order siblings by 
	    slp0.i_load_plan, 
	    slp0.step_order
)
,src as (
	select slp.lp_no
		,slp.step_name
		,slp.step_type
		,coalesce(ss.scen_no,0) as scen_no
	from slp
		left join ss
			on slp.scen_name = ss.scen_name
			and slp.scen_version = ss.scen_version
)
select *
from src
;