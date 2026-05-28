with sm as (select * from snp_model with read only)
select sm.i_mod as mod_no
	,sm.mod_name
	,sm.mod_text
	,sm.tech_int_name
	,sm.lschema_name
	,sm.lagent_name
	,sm.rev_context
	,sm.rev_type
	,sm.rev_update
	,sm.rev_insert
	,sm.rev_obj_patt
	,sm.rev_obj_type
	,sm.rev_alias_ltrim
	,sm.i_trt_kcm
	,sm.i_trt_kdm
	,to_char(sm.first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sm.last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	,sm.i_trt_kjm
	,sm.cod_mod
	,sm.ind_evo_jdbc
	,sm.ind_jrn_method
	,sm.def_action_grp
	,sm.i_mod_folder
	,sm.i_def_folder
	,sm.ws_lschema_name
	,sm.alias_length
	,sm.ws_data_source
	,sm.ws_name
	,sm.i_txt_mod
	,sm.i_trt_skm
	,sm.ws_name_space
	,sm.ws_java_package
	,sm.v_last_date
	,sm.release_tag
from sm
;