with ssl0 as (select * from snp_step_log with read only)
,ssr as (select * from snp_step_report with read only)
,ss as (select * from snp_session with read only)
,ssl as (
	select ss.sess_no
		,ss.sess_name
		,ssl0.nno as task_id
		,ssr.step_name
		,to_char(ssl0.step_beg, 'yyyy-mm-dd hh24:mi:ss') as start_ts
		,to_char(ssl0.step_end, 'yyyy-mm-dd hh24:mi:ss') as end_ts
		,lpad(floor(round(ssl0.step_dur) / 3600), 2, '0')
			    || ':' ||
			    lpad(floor(mod(round(ssl0.step_dur), 3600) / 60), 2, '0')
			    || ':' ||
			    lpad(mod(round(ssl0.step_dur), 60), 2, '0') as duration_hhmmss
		,round(ssl0.step_dur) as duration_sec
		,decode(ssl0.step_status
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
				,ssl0.step_status
			) as status
		,ssl0.step_rc as return_code
		,ssr.lschema_name
		,ssl0.nb_row as processed_rows
		,ssl0.nb_ins as inserted_rows
		,ssl0.nb_upd as updated_rows
		,ssl0.nb_del as deleted_rows
		,ssl0.error_message as error_msg
	from ssl0
		inner join ss
			on ssl0.sess_no = ss.sess_no
		inner join ssr
			on ssl0.sess_no = ssr.scen_run_no
			and ssl0.nno = ssr.nno
)
select *
from ssl
order by sess_no desc, task_id desc
;