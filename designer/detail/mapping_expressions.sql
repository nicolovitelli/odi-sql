with sm0 as (select * from snp_mapping with read only)
,smp as (select * from snp_map_prop with read only)
,sme as (select * from snp_map_expr with read only)
,su as (select * from snp_ufunc with read only)
,smer as (select * from snp_map_expr_ref with read only)
,smr as (select * from snp_map_ref with read only)
,sm as (
	select
		sme.i_map_expr as map_expr_no
		,smp.name as map_expr_type
		,sme.txt as map_expr_text
		,sm0.i_mapping as map_no
		,sm0.name as map_name
		,0 as ufunc_no
		,'N/A' as ufunc_name
		,to_char(sme.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(sme.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from sm0
		inner join smp
			on sm0.i_mapping = smp.i_owner_mapping
		inner join sme
			on smp.i_map_prop = sme.i_owner_map_prop
	where 1=1
		and upper(smp.name) in ('BEGIN_MAPPING_CMD','END_MAPPING_CMD')
		and sme.txt is not null
	union all
	select sme.i_map_expr as map_expr_no
		,'USER_FUNCTION' as map_expr_type
		,sme.txt as map_expr_text
		,sm0.i_mapping as map_no
		,sm0.name as map_name
		,su.i_ufunc as ufunc_no
		,su.ufunc_name as ufunc_name
		,to_char(sme.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(sme.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from sm0
		inner join smr
			on sm0.i_mapping = smr.i_owner_mapping
		inner join su
			on smr.ref_guid = su.global_id
		inner join smer
			on smr.i_map_ref = smer.i_ref_map_ref
		inner join sme
			on smer.i_owner_map_expr = sme.i_map_expr
	where 1=1
		and smr.adapter_intf_type = 'IUserFunction'
		and su.group_name = 'Lookup_user_function'
)
select *
from sm
order by map_no
;