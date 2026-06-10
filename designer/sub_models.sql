with ssm0 as (select * from snp_sub_model with read only)
,sm as (select * from snp_model with read only)
,ssm as (
	select ssm0.i_smod as smod_no
		,sm.mod_name
		,ssm0.smod_name
		,ssm0.smod_type
		,ssm0.cod_smod
		,ssm0.i_smod_parent
		,to_char(ssm0.first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(ssm0.last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from ssm0
		inner join sm
			on ssm0.i_mod = sm.i_mod
)
select *
from ssm
order by last_deploy_ts desc
;