with slv0 as (select * from snp_lp_var with read only)
,slp as (select * from snp_load_plan with read only)
,sv as (select * from snp_var with read only)
,sp as (select * from snp_project with read only)
,slv as (
	select slp.load_plan_name as lp_name
		,coalesce(sv.var_name,substr(slv0.var_name, instr(slv0.var_name, '.') + 1)) as var_name
		,coalesce(sp.project_name,substr(slv0.var_name, 1, instr(slv0.var_name, '.') - 1)) as var_prj_name
		,decode(
			slv0.var_datatype
			,'T'
			,'Text'
			,'D'
			,'Datetime'
			,'A'
			,'Alphanumeric'
			,'N'
			,'Numeric'
			,slv0.var_datatype
		) as var_datatype
	from slv0
		inner join slp
			on slv0.i_load_plan = slp.i_load_plan
		left join sp
			on substr(slv0.var_name, 1, instr(slv0.var_name, '.') - 1) = sp.project_name
		left join sv
			on sp.i_project = sv.i_project
			and substr(slv0.var_name, instr(slv0.var_name, '.') + 1) = sv.var_name
)
select *
from slv
;