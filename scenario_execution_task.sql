/*
  extracts all tasks executed by sessions that occurred after a specified date.
*/
with sstl as (select * from snp_sess_task_log with read only)
,sst as (select * from snp_sb_task with read only)
select sstl.sess_no as scen_exec_no
	,sstl.nno as task_no
	,sstl.scen_task_no as task_order
	,decode(
		sst.task_type
		,'S'
		,'Procedure'
		,'J'
		,'Mapping'
		,'V'
		,'Variable'
		,'C'
		,'Loading'
		,'L'
		,'Loading'
		,sst.task_type
	) as task_type
	,sst.task_name1
	,sst.task_name2
	,sst.task_name3
	,to_char(sstl.task_beg,'yyyy-mm-dd hh24:mi:ss') as start_ts
	,to_char(sstl.task_end,'yyyy-mm-dd hh24:mi:ss') as end_ts
	,sstl.task_dur as duration_sec
	,sstl.nb_row as processed_rows
	,sstl.nb_ins as inserted_rows
	,sstl.nb_upd as updated_rows
	,sstl.task_status as status
	,sst.def_lschema_name as tgt_lschema_name
	,sst.col_lschema_name as src_lschema_name
	,sstl.def_txt as tgt_text
	,sstl.col_txt as src_text
	,sstl.error_message as error_msg
from sstl
	inner join sst
		on sstl.sb_no = sst.sb_no
		and sstl.nno = sst.nno
		and sstl.scen_task_no = sst.scen_task_no
where sstl.task_beg > to_date(:bvDate,'yyyy-mm-dd hh24:mi:ss')
order by sstl.sess_no, sstl.nno, sstl.scen_task_no
;