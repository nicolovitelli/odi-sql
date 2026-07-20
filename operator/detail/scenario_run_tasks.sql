with sstl0 as (select * from snp_sess_task_log with read only)
,ss as (select * from snp_session with read only)
,sst as (select * from snp_sb_task with read only)
,sstl as (
	select ss.sess_no
		,ss.sess_name
		,sstl0.nno as task_id
		,sstl0.scen_task_no as task_order
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
		,to_char(sstl0.task_beg, 'yyyy-mm-dd hh24:mi:ss') as start_ts
		,to_char(sstl0.task_end, 'yyyy-mm-dd hh24:mi:ss') as end_ts
		,lpad(floor(round(sstl0.task_dur) / 3600), 2, '0')
			    || ':' ||
			    lpad(floor(mod(round(sstl0.task_dur), 3600) / 60), 2, '0')
			    || ':' ||
			    lpad(mod(round(sstl0.task_dur), 60), 2, '0') as duration_hhmmss
		,round(sstl0.task_dur) as duration_sec
		,decode(sstl0.task_status
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
				,sstl0.task_status
			) as status
		,sstl0.task_rc as return_code
		,sstl0.nb_row as processed_rows
		,sstl0.nb_ins as inserted_rows
		,sstl0.nb_upd as updated_rows
		,sstl0.nb_del as deleted_rows
		,sstl0.col_txt as src_text
		,sst.col_lschema_name as src_lschema_name
		,sstl0.def_txt as tgt_text
		,sst.def_lschema_name as tgt_lschema_name
		,sstl0.error_message as error_msg
	from sstl0
		inner join ss
			on sstl0.sess_no = ss.sess_no
		inner join sst
			on sstl0.sb_no = sst.sb_no
			and sstl0.nno = sst.nno
			and sstl0.scen_task_no = sst.scen_task_no
)
select *
from sstl
order by sess_no desc, task_id desc, task_order desc
fetch first 50 rows only
;