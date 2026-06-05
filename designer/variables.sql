with sv0 as (select * from snp_var with read only)
,sth as (select i_txt, full_text from snp_txt_header with read only)
,sl as (select lschema_name from snp_lschema with read only)
,sp as (select i_project, project_name from snp_project with read only)
,step0 as (select i_var from snp_step with read only)
,step as (
	select sv0.i_var
		,count(1) as cnt
	from step0
		inner join sv0
			on step0.i_var = sv0.i_var
	group by sv0.i_var
)
,slv0 as (select var_name from snp_lp_var with read only)
,slv as (
	select sv0.i_var
		,count(1) as cnt
	from slv0
		left join sp
			on substr(slv0.var_name, 1, instr(slv0.var_name, '.') - 1) = sp.project_name
		inner join sv0
			on (
				sp.i_project = sv0.i_project
				or substr(slv0.var_name, 1, instr(slv0.var_name, '.') - 1) = 'GLOBAL'
				)
			and substr(slv0.var_name, instr(slv0.var_name, '.') + 1) = sv0.var_name
	group by sv0.i_var
)
,st0 as (select i_trt from snp_trt with read only)
,slt as (select i_trt, def_i_txt, col_i_txt from snp_line_trt with read only)
,stc as (select i_txt, i_var  from snp_txt_crossr with read only)
,st as (
	select sv0.i_var
		,count(1) as cnt
	from st0
		inner join slt
			on st0.i_trt = slt.i_trt
		inner join stc
			on stc.i_txt = slt.def_i_txt
			or stc.i_txt = slt.col_i_txt
		inner join sv0
			on sv0.i_var = stc.i_var
	group by sv0.i_var
)
,sm0 as (select i_mapping from snp_mapping with read only)
,smr as (select i_owner_mapping, ref_guid from snp_map_ref with read only)
,sm as (
	select sv0.i_var
		,count(1) as cnt
	from sm0
		inner join smr
			on sm0.i_mapping = smr.i_owner_mapping
		inner join sv0
			on smr.ref_guid = sv0.global_id
	group by sv0.i_var
)
,sv as (
	select sv0.i_var as var_no
		,sv0.var_name
		,sp.project_name as prj_name
		,sth.full_text as var_text
		,sl.lschema_name as lschema_name
		,decode(sv0.ind_store
			,'N'
			,'No History'
			,'L'
			,'Latest Value'
			,'H'
			,'All Values'
			,sv0.ind_store
		) as var_history
		,decode(
			sv0.var_datatype
			,'T'
			,'Text'
			,'D'
			,'Datetime'
			,'A'
			,'Alphanumeric'
			,'N'
			,'Numeric'
			,sv0.var_datatype
		) as var_datatype
		,coalesce(
			to_char(sv0.def_n)
			,to_char(sv0.def_v)
			,to_char(sv0.def_date)
		) as var_default_value
		,coalesce(step.cnt,0) as package_step_usage_count
		,coalesce(slv.cnt,0) as load_plan_usage_count
		,coalesce(st.cnt,0) as procedure_usage_count
		,coalesce(sm.cnt,0) as mapping_usage_count
		,to_char(sv0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(sv0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from sv0
		left join sp
			on sv0.i_project = sp.i_project
		left join sth
			on sv0.i_txt_var_in = sth.i_txt
		left join sl
			on sv0.lschema_name = sl.lschema_name
		left join step
			on sv0.i_var = step.i_var
		left join slv
			on sv0.i_var = slv.i_var
		left join st
			on sv0.i_var = st.i_var
		left join sm
			on sv0.i_var = sm.i_var
)
select *
from sv
order by last_deploy_ts desc
;