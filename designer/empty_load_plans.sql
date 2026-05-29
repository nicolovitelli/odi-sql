with slp as (select * from snp_load_plan with read only)
,step0 as (select * from snp_lp_step with read only)
,step as (select * from step0 where lp_step_name <> 'root_step')
select slp.i_load_plan as lp_no
	,slp.load_plan_name
	,slp.first_date
	,slp.last_date
from slp
	left join step
		on slp.i_load_plan = step.i_load_plan
where 1=1
	and step.i_lp_step is null
order by lp_no
;