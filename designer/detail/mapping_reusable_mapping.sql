with sm0 as (select * from snp_mapping with read only)
,smr as (select * from snp_map_ref with read only)
,smc as (select * from snp_map_comp with read only)
,sm as (
	select distinct sm2.i_mapping as map_no
		,sm2.name as rm_name
		,sm1.i_mapping as parent_map_no
		,sm1.name as parent_mapping_name
	from sm0 sm1
		inner join smc
			on sm1.i_mapping = smc.i_owner_mapping
		inner join smr
			on smc.i_map_ref = smr.i_map_ref
		inner join sm0 sm2
			on smr.ref_guid = sm2.global_id
	where 1=1
		and smr.adapter_intf_type = 'IReusableMapping'
		and sm2.is_reusable = 'Y'
)
select *
from sm
order by map_no
;