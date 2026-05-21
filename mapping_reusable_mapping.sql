/*
  extracts mappings along with their reusable mappings.
  mappings without any reusable mappings are excluded.
  the distinct keyword is used to avoid listing the same reusable mapping multiple times 
  	within the same mapping.
*/
with sm as (select * from snp_mapping with read only)
,smr as (select * from snp_map_ref with read only)
,smc as (select * from snp_map_comp with read only)
select distinct sm2.i_mapping as map_no
	,sm1.i_mapping as parent_map_no
from sm sm1
	inner join smc
		on sm1.i_mapping = smc.i_owner_mapping
	inner join smr
		on smc.i_map_ref = smr.i_map_ref
	inner join sm sm2
		on smr.ref_guid = sm2.global_id
where 1=1
	and smr.adapter_intf_type = 'IReusableMapping'
	and sm2.is_reusable = 'Y'
;