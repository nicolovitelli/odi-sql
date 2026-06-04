with st0 as (select * from snp_table with read only)
,sm as (select * from snp_model with read only)
,sl as (select * from snp_lschema with read only)
,spc as (select * from snp_pschema_cont with read only)
,sc as (select * from snp_context with read only)
,sp as (select * from snp_pschema with read only)
,st as (
	select st0.i_table as ds_no
		,st0.res_name as ds_name
		,sp.i_pschema as pschema_no
		,sm.mod_name as model_name
		,to_char(st0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(st0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from st0
		inner join sm
			on st0.i_mod = sm.i_mod
		inner join sl
			on sm.lschema_name = sl.lschema_name
		inner join spc
			on sl.i_lschema = spc.i_lschema
		inner join sc
			on spc.i_context = sc.i_context
		inner join sp
			on spc.i_pschema = sp.i_pschema
	where 1=1
		and upper(sc.context_name) = 'GLOBAL'
)
select *
from st
;