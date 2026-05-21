/*
  extracts datastores and knowledge modules used by each mapping.
  dependency_type:
    'SOURCE'  => datastore used exclusively as a source
    'TARGET'  => datastore used exclusively as a target
    'STAGING' => datastore used as both source and target
  km_no is set to 0 if the datastore is a source.
  row_number is used to filter out datastores that appear multiple times 
  	(as source, target, or staging) within the same mapping.
*/
with st as (select * from snp_table with read only)
,smr as (select * from snp_map_ref with read only)
,smc as (select * from snp_map_comp with read only)
,spn as (select * from snp_phy_node with read only)
,sdc as (select * from snp_deploy_spec with read only)
,sm as (select * from snp_mapping with read only)
,strt as (select * from snp_trt with read only)
,src0 as (
	select
		coalesce(sm.i_mapping,0) as map_no
		,sm.name as map_name
		,st.i_table as ds_no
		,st.res_name as ds_name
		,coalesce(strt.i_trt,0) as km_no
		,strt.trt_name as km_name
		,case when (spn.i_tgt_comp_km is null and spn.i_src_comp_km is not null)
				then 'SOURCE'
				else 
					case when (spn.i_tgt_comp_km is not null and spn.i_src_comp_km is null)
						then 'TARGET'
						else
							case when (spn.i_tgt_comp_km is not null
										and spn.i_src_comp_km is not null
										)
								then
									'STAGING'
								else 'Unspecified'
							end
					end
		end as dependency_type
	from st
		inner join smr
			on st.global_id = smr.ref_guid
		inner join smc
			on smr.i_map_ref = smc.i_map_ref
		inner join spn
			on smc.i_map_comp = spn.i_map_comp
		inner join sdc
			on spn.i_owner_ds = sdc.i_deploy_spec
		inner join sm
			on sdc.i_owner_mapping = sm.i_mapping
		left join smr smr2
			on spn.i_tgt_comp_km = smr2.i_map_ref
		left join strt
			on smr2.ref_guid = strt.global_id
)
,src as (
	select src0.*
		,row_number() over (partition by map_no, ds_no, dependency_type order by map_no desc) as rn
	from src0
)
select map_no, map_name, ds_no, ds_name, km_no, km_name, dependency_type
from src
where rn = 1
order by map_no
;