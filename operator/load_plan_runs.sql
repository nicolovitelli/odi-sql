with slr0 as (select * from snp_lpi_run with read only)
,sli as (select * from snp_lp_inst with read only)
,slp as (select * from snp_load_plan with read only)
,slr as (
	select
		slr0.i_lp_inst as lp_exec_no
		,slp.i_load_plan as lp_no
		,slp.load_plan_name as lp_name
		,slr0.user_name as executed_by
		,to_char(slr0.start_date,'yyyy-mm-dd hh24:mi:ss') as start_ts
		,to_char(slr0.end_date,'yyyy-mm-dd hh24:mi:ss') as end_ts
		,lpad(floor(round(slr0.duration) / 3600), 2, '0')
			    || ':' ||
			    lpad(floor(mod(round(slr0.duration), 3600) / 60), 2, '0')
			    || ':' ||
			    lpad(mod(round(slr0.duration), 60), 2, '0') as duration_hhmmss
		,round(slr0.duration) as duration_sec
		,decode(slr0.status
				,'D'
				,'Done'
				,'M'
				,'Warning'
				,'Q'
				,'Queued'
				,'W'
				,'Waiting'
				,'R'
				,'Running'
				,'E'
				,'Error'
				,slr0.status
			) as status
		,slr0.return_code
		,slr0.pagent_name
		,slr0.error_message as error_msg
	from slr0
		inner join sli
			on slr0.i_lp_inst = sli.i_lp_inst
		inner join slp
			on sli.i_load_plan = slp.i_load_plan
)
select *
from slr
order by end_ts desc
;