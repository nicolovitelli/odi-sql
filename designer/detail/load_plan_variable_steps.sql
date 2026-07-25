with slsv0 as (select * from snp_lp_step_var with read only)
,slp as (select * from snp_load_plan with read only)
,sls as (select * from snp_lp_step with read only)
,sv as (select * from snp_var with read only)
,sp as (select * from snp_project with read only)
,slsv as (
	select slp.load_plan_name as lp_name
		,sls.i_lp_step as lp_step_no
		,sls.lp_step_name
		,decode(sls.lp_step_type
			,'RS'
			,'Run Scenario Step'
			,'CE'
			,'Case Else Branch'
			,'CW'
			,'Case When Branch'
			,'PA'
			,'Parallel Step'
			,'CS'
			,'Case Step'
			,'SE'
			,'Serial Step'
			,'EX'
			,'Exception Step'
			,sls.lp_step_type
		) as lp_step_type
		,coalesce(sv.var_name,substr(slsv0.var_name, instr(slsv0.var_name, '.') + 1)) as var_name
		,coalesce(sp.project_name,substr(slsv0.var_name, 1, instr(slsv0.var_name, '.') - 1)) as var_prj_name
		,coalesce(to_clob(slsv0.var_value),slsv0.var_long_value) as var_value
	from slsv0
		inner join slp
			on slsv0.i_load_plan = slp.i_load_plan
		inner join sls
			on slsv0.i_lp_step = sls.i_lp_step
		left join sp
			on substr(slsv0.var_name, 1, instr(slsv0.var_name, '.') - 1) = sp.project_name
		left join sv
			on sp.i_project = sv.i_project
			and substr(slsv0.var_name, instr(slsv0.var_name, '.') + 1) = sv.var_name
)
select *
from slsv
order by lp_name, lp_step_name
;