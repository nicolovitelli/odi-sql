/*
  extracts mapping expressions used in ODI mappings.
  currently, only begin/end mapping commands and expressions that have user functions are extracted.
*/
with sm as (select * from snp_mapping with read only)
,smp as (select * from snp_map_prop with read only)
,sme as (select * from snp_map_expr with read only)
,su as (select * from snp_ufunc with read only)
,smer as (select * from snp_map_expr_ref with read only)
,smr as (select * from snp_map_ref with read only)
select
	sme.i_map_expr as map_expr_no
	,smp.name as map_expr_type
	,sme.txt as map_expr_text
	,sm.i_mapping as map_no
	,0 as ufunc_no
	,to_char(sme.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sme.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from sm
	inner join smp
		on sm.i_mapping = smp.i_owner_mapping
	inner join sme
		on smp.i_map_prop = sme.i_owner_map_prop
where 1=1
	and upper(smp.name) in ('BEGIN_MAPPING_CMD','END_MAPPING_CMD')
	and sme.txt is not null
union all
select sme.i_map_expr as map_expr_no
	,'USER_FUNCTION' as map_expr_type
	,sme.txt as map_expr_text
	,sm.i_mapping as map_no
	,su.i_ufunc as ufunc_no
	,to_char(sme.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sme.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from sm
	inner join smr
		on sm.i_mapping = smr.i_owner_mapping
	inner join su
		on smr.ref_guid = su.global_id
	inner join smer
		on smr.i_map_ref = smer.i_ref_map_ref
	inner join sme
		on smer.i_owner_map_expr = sme.i_map_expr
where 1=1
	and smr.adapter_intf_type = 'IUserFunction'
	and su.group_name = 'Lookup_user_function'
;