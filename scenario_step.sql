/*
  extracts all steps to be executed for each scenario.
*/
with sss as (select * from snp_scen_step with read only)
,sv as (select * from snp_var with read only)
,sp as (select * from snp_project with read only)
,sl as (select * from snp_lschema with read only)
,st as (select * from snp_table with read only)
,sm as (select * from snp_model with read only)
select sss.scen_no
	,sss.nno as step_no
	,sss.step_name
	,decode(sss.step_type
		,'RS'
		,'Sub-Model Reverse-engineering'
		,'T'
		,'Procedure'
		,'RM'
		,'Reverse Model'
		,'SE'
		,'Oracle Data Integrator Command'
		,'VD'
		,'Declare Variable'
		,'JD'
		,'Journalize Datastore'
		,'M'
		,'Mapping'
		,'JM'
		,'Journalize Model'
		,'VP'
		,'Populate Variable'
		,'JS'
		,'Journalize Sub-Model'
		,'V'
		,'Refresh Variable'
		,'RD'
		,'Datastore Reverse-engineering'
		,'OE'
		,'Operating System Command'
		,'VE'
		,'Evaluate Variable'
		,'CD'
		,'Check Datastore'
		,'VS'
		,'Set Variable'
		,'CM'
		,'Check Model'
		,'CS'
		,'Check Sub-Model'
		,sss.step_type
	) as step_type
	,sv.i_var as var_no
	,sss.var_long_value as var_value
	,sl.i_lschema as tgt_lschema_no
	,st.i_table as tgt_ds_no
from sss
	left join sp
		on substr(sss.var_name, 1, instr(sss.var_name, '.') - 1) = sp.project_name
	left join sv
		on substr(sss.var_name, instr(sss.var_name, '.') + 1) = sv.var_name
		and sp.i_project = sv.i_project
	left join sl
		on sss.lschema_name = sl.lschema_name
	left join sm
		on sss.mod_code = sm.mod_name
	left join st
		on sss.res_name = st.res_name
		and sm.i_mod = st.i_mod