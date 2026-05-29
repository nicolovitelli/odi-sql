with slp as (select * from snp_load_plan with read only)
,slr as (select * from snp_lpi_run with read only)
,sli as (select * from snp_lp_inst with read only)
select slp.i_load_plan as lp_no
	,slp.load_plan_name
	,slp.first_date
	,slp.last_date
from slp
	left join sli
		on slp.i_load_plan = sli.i_load_plan
	left join slr
		on sli.i_lp_inst = slr.i_lp_inst
where 1=1
	and slr.i_lp_inst is null
order by lp_no
;