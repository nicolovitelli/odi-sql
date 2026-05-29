with slp as (select * from snp_lp_step with read only)
,ss as (select * from snp_scen with read only)
,src as (
	select 
	    i_load_plan as lp_no
	    ,lpad(' ', (level - 1) * 4, ' ') || lp_step_name as step_name
	    ,decode(lp_step_type
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
			,lp_step_type
		) as step_type
		,scen_name
		,scen_version
	from slp
	start with par_i_lp_step is null
	connect by 
	    prior i_lp_step = par_i_lp_step
	    and prior i_load_plan = i_load_plan
	order siblings by 
	    i_load_plan, 
	    step_order
)
select src.lp_no
	,src.step_name
	,src.step_type
	,coalesce(ss.scen_no,0) as scen_no
from src
	left join ss
		on src.scen_name = ss.scen_name
		and src.scen_version = ss.scen_version
;