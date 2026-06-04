with sm0 as (select * from snp_model with read only)
,sm as (
select sm0.i_mod as mod_no
	,sm0.mod_name
	,sm0.mod_text
	,sm0.tech_int_name
	,sm0.lschema_name
	,sm0.lagent_name
	,sm0.rev_context
	,sm0.rev_type
	,sm0.rev_update
	,sm0.rev_insert
	,sm0.rev_obj_patt
	,sm0.rev_obj_type
	,sm0.rev_alias_ltrim
	,sm0.i_trt_kcm
	,sm0.i_trt_kdm
	,to_char(sm0.first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sm0.last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
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
from sm0
)
select *
from sm
;