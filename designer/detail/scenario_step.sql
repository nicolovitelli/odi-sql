with sss0 as (select * from snp_scen_step with read only)
,sl as (select * from snp_lschema with read only)
,st as (select * from snp_table with read only)
,sm as (select * from snp_model with read only)
,ss as (select * from snp_scen with read only)
,sss as (
	select sss0.scen_no
		,ss.scen_name
		,sss0.nno as step_no
		,sss0.step_name
		,decode(sss0.step_type
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
			,sss0.step_type
		) as step_type
		,substr(sss0.var_name, instr(sss0.var_name, '.') + 1) as var_name
		,substr(sss0.var_name, 1, instr(sss0.var_name, '.') - 1) as var_prj_name
		,sss0.var_long_value as var_value
		,sl.lschema_name as tgt_lschema_name
		,st.res_name as tgt_ds_name
	from sss0
		inner join ss
			on sss0.scen_no = ss.scen_no
		left join sl
			on sss0.lschema_name = sl.lschema_name
		left join sm
			on sss0.mod_code = sm.mod_name
		left join st
			on sss0.res_name = st.res_name
			and sm.i_mod = st.i_mod
)
select *
from sss
order by scen_no, step_no
;