with ss0 as (select * from snp_session with read only)
,ss as (
	select ss0.sess_no as scen_exec_no
		,ss0.sess_name
		,ss0.user_name executed_by
		,to_char(ss0.sess_beg, 'yyyy-mm-dd hh24:mi:ss') as start_ts
		,to_char(ss0.sess_end, 'yyyy-mm-dd hh24:mi:ss') as end_ts
		,lpad(floor(ss0.sess_dur / 3600), 2, '0')
		    || ':' ||
		    lpad(floor(mod(ss0.sess_dur, 3600) / 60), 2, '0')
		    || ':' ||
		    lpad(mod(ss0.sess_dur, 60), 2, '0') as duration_hhmmss
		,ss0.sess_dur as duration_sec
		,decode(ss0.sess_status
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
			,ss0.sess_status
		) as status
		,ss0.sess_rc as return_code
		,ss0.nb_row as processed_rows
		,ss0.nb_ins as inserted_rows
		,ss0.nb_upd as updated_rows
		,ss0.nb_del as deleted_rows
		,ss0.error_message as error_msg
		,ss0.startup_variables
		,ss0.agent_name
		,case when ss0.scen_name is not null
			then 'Y'
			else 'N'
		end as is_scenario
	from ss0
	order by ss0.sess_end desc nulls last
)
select *
from ss
fetch first 50 rows only
;