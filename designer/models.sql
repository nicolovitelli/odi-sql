with sm0 as (select * from snp_model with read only)
,ssm0 as (select * from snp_sub_model with read only)
,ssm as (
	select sm0.i_mod
		,count(1) as cnt
	from ssm0
		inner join sm0
			on ssm0.i_mod = sm0.i_mod
	group by sm0.i_mod
)
,st0 as (select * from snp_table with read only)
,st as (
	select sm0.i_mod
		,count(1) as cnt
	from st0
		inner join sm0
			on st0.i_mod = sm0.i_mod
	group by sm0.i_mod
)
,sm as (
select sm0.i_mod as mod_no
	,sm0.mod_name
	,sm0.mod_text
	,sm0.tech_int_name
	,sm0.lschema_name
	,sm0.lagent_name
	,coalesce(ssm.cnt,0) as sub_model_count
	,coalesce(st.cnt,0) as datastore_count
	,sm0.rev_context
	,sm0.rev_type
	,sm0.rev_update
	,sm0.rev_insert
	,sm0.rev_obj_patt
	,sm0.rev_obj_type
	,sm0.rev_alias_ltrim
	,sm0.i_trt_kcm
	,sm0.i_trt_kdm
	,sm0.i_trt_kjm
	,sm0.cod_mod
	,sm0.ind_evo_jdbc
	,sm0.ind_jrn_method
	,sm0.def_action_grp
	,sm0.i_mod_folder
	,sm0.i_def_folder
	,sm0.ws_lschema_name
	,sm0.alias_length
	,sm0.ws_data_source
	,sm0.ws_name
	,sm0.i_txt_mod
	,sm0.i_trt_skm
	,sm0.ws_name_space
	,sm0.ws_java_package
	,sm0.v_last_date
	,sm0.release_tag
	,to_char(sm0.first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sm0.last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from sm0
	left join ssm
		on sm0.i_mod = ssm.i_mod
	left join st
		on sm0.i_mod = st.i_mod
)
select *
from sm
order by last_deploy_ts desc
;