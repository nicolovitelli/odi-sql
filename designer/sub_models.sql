with ssm0 as (select * from snp_sub_model with read only)
,sm as (select * from snp_model with read only)
,ssm as (
	select ssm0.i_smod as smod_no
		,sm.mod_name
		,ssm0.smod_name
		,ssm0.smod_type
		,to_char(ssm0.first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(ssm0.last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
		,ssm0.cod_smod
		,ssm0.i_smod_parent
		,ssm0.table_name_pattern
		,ssm0.rev_apply_pattern
		,ssm0.rev_pattern_order
	from ssm0
		inner join sm
			on ssm0.i_mod = sm.i_mod
)
select *
from ssm
;