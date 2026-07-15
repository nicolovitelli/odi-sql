with sls0 as (select * from snp_lpi_step with read only)
,slsl as (select * from snp_lpi_step_log with read only)
,sli as (select * from snp_lp_inst with read only)
,sls00 as (
	select sls0.i_lp_step
		,sls0.lp_step_name
		,row_number() over (partition by sls0.i_lp_step order by sls0.i_lp_inst) as rn
	from sls0
)
,sls as (
	select sls0.i_lp_inst as lp_exec_no
		,sls0.i_lp_step as lp_step_no
		,sli.load_plan_name as lp_name
		,sls0.lp_step_name
		,to_char(slsl.start_date, 'yyyy-mm-dd hh24:mi:ss') as start_ts
		,to_char(slsl.end_date, 'yyyy-mm-dd hh24:mi:ss') as end_ts
		,lpad(floor(round((slsl.end_date - slsl.start_date) * 86400) / 3600), 2, '0')
		    || ':' ||
		    lpad(floor(mod(round((slsl.end_date - slsl.start_date) * 86400), 3600) / 60), 2, '0')
		    || ':' ||
		    lpad(mod(round((slsl.end_date - slsl.start_date) * 86400), 60), 2, '0') as duration_hhmmss
		,round((slsl.end_date - slsl.start_date) * 86400) as duration_sec
		,decode(slsl.status
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
			,slsl.status
		) as status
		,slsl.return_code
		,slsl.nb_row as processed_rows
		,slsl.nb_ins as inserted_rows
		,slsl.nb_upd as updated_rows
		,slsl.nb_del as deleted_rows
		,slsl.error_message as error_msg
		,decode(sls0.lp_step_type
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
			,sls0.lp_step_type
		) as lp_step_type
		,sls00.lp_step_name as parent_lp_step_name
		,sls0.lagent_name as logical_agent_name
		,case when sls0.scen_name is not null
			then 'Y'
			else 'N'
		end as is_scenario
		,case when sls0.var_name is not null
			then 'Y'
			else 'N'
		end as is_variable
		,sls0.var_name
	from sls0
		left join sls00
			on sls0.par_i_lp_step = sls00.i_lp_step
			and sls00.rn = 1
		inner join slsl
			on sls0.i_lp_inst = slsl.i_lp_inst
			and sls0.i_lp_step = slsl.i_lp_step
		inner join sli
			on sls0.i_lp_inst = sli.i_lp_inst
)
select *
from sls
order by end_ts desc, lp_exec_no, lp_step_no
;