/*
  extracts all steps executed by sessions that occurred after a specified date.
*/
with ssr as (select * from snp_scen_report with read only)
,step as (select * from snp_step_report with read only)
,scen as (select * from snp_scen with read only)
,sss as (select * from snp_scen_step with read only)
select
	ssr.scen_run_no as scen_exec_no
	,sss.nno as step_order
	,sss.step_name
	,decode(sss.step_type
		,'RS'
		,'Sub-Model Reverse-engineering'
		,'T'
		,'Procedure'
		,'RM'
		,'Reverse Model'
		,'SE'
		,'Oracle Data Integrator Command'
		,'VD'
		,'Declare Variable'
		,'JD'
		,'Journalize Datastore'
		,'M'
		,'Mapping'
		,'JM'
		,'Journalize Model'
		,'VP'
		,'Populate Variable'
		,'JS'
		,'Journalize Sub-Model'
		,'V'
		,'Refresh Variable'
		,'RD'
		,'Datastore Reverse-engineering'
		,'OE'
		,'Operating System Command'
		,'VE'
		,'Evaluate Variable'
		,'CD'
		,'Check Datastore'
		,'VS'
		,'Set Variable'
		,'CM'
		,'Check Model'
		,'CS'
		,'Check Sub-Model'
		,sss.step_type
	) as step_type
	,to_char(step.step_beg,'yyyy-mm-dd hh24:mi:ss') as start_ts
	,to_char(step.step_end,'yyyy-mm-dd hh24:mi:ss') as end_ts
	,step.step_dur as duration_sec
	,step.nb_row processed_rows
	,step.nb_ins inserted_rows
	,step.nb_upd updated_rows
	,step.step_status as status
	,step.error_message as error_msg
from ssr
	inner join step
		on ssr.scen_no = step.scen_no
		and ssr.scen_run_no = step.scen_run_no
	inner join scen
		on ssr.scen_no = scen.scen_no
	inner join sss
		on scen.scen_no = sss.scen_no
		and step.nno = sss.nno
where step.step_beg > to_date(:bvDate,'yyyy-mm-dd hh24:mi:ss')
;