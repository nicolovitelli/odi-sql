with ss0 as (select * from snp_sequence with read only)
,stc as (select * from snp_txt_crossr with read only)
,st0 as (select * from snp_trt with read only)
,slt as (select * from snp_line_trt with read only)
,sp as (select * from snp_project with read only)
,st as (
	select ss0.seq_id
		,count(1) as cnt
	from st0
		inner join slt
			on st0.i_trt = slt.i_trt
		inner join stc
			on stc.i_txt = slt.def_i_txt
			or stc.i_txt = slt.col_i_txt
		inner join ss0
			on stc.seq_id = ss0.seq_id
	where stc.object_type = 'S'
	group by ss0.seq_id	
)
,sv0 as (select * from snp_var with read only)
,sv as (
	select ss0.seq_id
		,count(1) as cnt
	from sv0
		inner join stc
			on sv0.i_txt_var_in = stc.i_txt
		inner join ss0
			on stc.seq_id = ss0.seq_id
	where stc.object_type = 'S'
	group by ss0.seq_id	
)
,ss as (
	select ss0.seq_id as seq_no
		,ss0.seq_name
		,sp.project_name as prj_name
		,coalesce(st.cnt,0) as procedure_usage_count
		,coalesce(sv.cnt,0) as variable_usage_count
		,ss0.incr as incr_value
		,ss0.lschema_name
		,ss0.db_seq_name
		,to_char(ss0.first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(ss0.last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from ss0
		left join st
			on ss0.seq_id = st.seq_id
		left join sv
			on ss0.seq_id = sv.seq_id
		left join sp
			on ss0.i_project = sp.i_project
)
select *
from ss
order by last_deploy_ts desc
;