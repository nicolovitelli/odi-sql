/*
  extracts all mappings along with their associated knowledge modules.
  the distinct keyword is used to remove duplicate entries of the same knowledge module 
  	when it is used multiple times within the same mapping.
*/
with sm as (select * from snp_mapping with read only)
,sdc as (select * from snp_deploy_spec with read only)
,spn as (select * from snp_phy_node with read only)
,smc as (select * from snp_map_comp with read only)
,smr as (select * from snp_map_ref with read only)
,st as (select * from snp_table with read only)
,strt as (select * from snp_trt with read only)
select distinct sm.i_mapping as map_no
	,strt.i_trt as km_no
from sm
	inner join sdc
		on sm.i_mapping = sdc.i_owner_mapping
	inner join spn
		on sdc.i_deploy_spec = spn.i_owner_ds
	inner join smc
		on spn.i_map_comp = smc.i_map_comp
	inner join smr
		on smc.i_map_ref = smr.i_map_ref
	inner join st
		on smr.ref_guid = st.global_id
	inner join smr smr2
		on spn.i_tgt_comp_km = smr2.i_map_ref
	inner join strt
		on smr2.ref_guid = strt.global_id
;