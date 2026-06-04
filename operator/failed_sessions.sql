with ss as (select * from snp_session with read only)
select ss.sess_no as scen_exec_no
	,ss.sess_name
	,to_char(ss.sess_beg, 'yyyy-mm-dd hh24:mi:ss') as start_ts
	,to_char(ss.sess_end, 'yyyy-mm-dd hh24:mi:ss') as end_ts
	,ss.sess_dur as duration_sec
	,ss.sess_rc as return_code
	,ss.nb_row as processed_rows
	,ss.nb_ins as inserted_rows
	,ss.nb_upd as updated_rows
	,ss.nb_del as deleted_rows
	,ss.error_message as error_msg
from ss
where ss.sess_status = 'E'
order by ss.sess_end desc nulls last
fetch first 50 rows only
;