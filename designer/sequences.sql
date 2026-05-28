with ss as (select * from snp_sequence with read only)
select ss.seq_id as seq_no
	,ss.i_project as prj_no
	,ss.seq_name
	,ss.incr
	,ss.seq_type
	,ss.ind_std
	,ss.std_max
	,ss.std_pos
	,ss.spc_tab
	,ss.spc_col
	,ss.spc_where
	,ss.lschema_name
	,to_char(ss.first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(ss.last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	,ss.db_seq_name
	,ss.v_last_date
	,ss.i_txt_spc_where
from ss
;