with slvl0 as (select * from snp_lpi_var_log with read only)
,sls as (select * from snp_lpi_step with read only)
,sli as (select * from snp_lp_inst with read only)
,slvl as (
	select slvl0.i_lp_inst as lp_exec_no
		,slvl0.i_lp_step as lp_step_no
		,sli.load_plan_name as lp_name
		,sls.lp_step_name
		,slvl0.var_name
		,coalesce(slvl0.var_value,dbms_lob.substr(slvl0.var_long_value,4000,1)) as var_value
		,to_char(slvl0.start_date, 'yyyy-mm-dd hh24:mi:ss') as start_ts
		,to_char(slvl0.end_date, 'yyyy-mm-dd hh24:mi:ss') as end_ts
		,lpad(floor(round(slvl0.duration) / 3600), 2, '0')
		    || ':' ||
		    lpad(floor(mod(round(slvl0.duration), 3600) / 60), 2, '0')
		    || ':' ||
		    lpad(mod(round(slvl0.duration), 60), 2, '0') as duration_hhmmss
		,round(slvl0.duration) as duration_sec
		,decode(slvl0.status
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
			,slvl0.status
		) as status
		,slvl0.return_code
		,slvl0.error_message as error_msg
	from slvl0
		inner join sls
			on slvl0.i_lp_step = sls.i_lp_step
			and slvl0.i_lp_inst = sls.i_lp_inst
		inner join sli
			on slvl0.i_lp_inst = sli.i_lp_inst
)
select *
from slvl
order by end_ts desc, lp_exec_no, lp_step_no
;