with slsv0 as (select * from snp_lpi_step_var with read only)
,sls as (select * from snp_lpi_step with read only)
,sli as (select * from snp_lp_inst with read only)
,slsv as (
	select slsv0.i_lp_inst as lp_exec_no
		,slsv0.i_lp_step as lp_step_no
		,sli.load_plan_name as lp_name
		,sls.lp_step_name
		,slsv0.var_name
		,coalesce(slsv0.var_value, dbms_lob.substr(slsv0.var_long_value, 4000, 1)) as var_value
	from slsv0
		inner join sls
			on slsv0.i_lp_inst = sls.i_lp_inst
			and slsv0.i_lp_step = sls.i_lp_step
		inner join sli
			on slsv0.i_lp_inst = sli.i_lp_inst
)
select *
from slsv
order by lp_exec_no, lp_step_no
;