with sstl as (select * from snp_sess_task_log with read only)
,ss as (select * from snp_session with read only)
select ss.sess_no as scen_exec_no
	,ss.sess_name
	,sstl.nno
	,sstl.scen_task_no
	,sstl.task_beg
	,sstl.task_end
	,sstl.task_dur
	,sstl.task_rc
	,sstl.nb_row
	,sstl.nb_ins
	,sstl.nb_upd
	,sstl.nb_del
	,sstl.col_txt
	,sstl.def_txt
	,sstl.task_name3
	,sstl.error_message as error_msg
	,sstl.col_conn_name
	,sstl.def_conn_name
from sstl
	inner join ss
		on sstl.sess_no = ss.sess_no
where sstl.task_status = 'E'
order by sstl.task_end desc nulls last
fetch first 50 rows only
;