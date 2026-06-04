with sm0 as (select * from snp_mapping with read only)
,sdc as (select * from snp_deploy_spec with read only)
,sf as (select * from snp_folder with read only)
,ss0 as (select * from snp_scen with read only)
,ss as (
	select sm0.i_mapping
		,count(1) as cnt
	from ss0
		inner join sm0
			on ss0.i_mapping = sm0.i_mapping
	group by sm0.i_mapping
)
,smc0 as (select * from snp_map_comp with read only)
,smc as (
	select sm0.i_mapping
		,count(1) as cnt
	from smc0
		inner join sm0
			on smc0.i_owner_mapping = sm0.i_mapping
	group by sm0.i_mapping
)
,step0 as (select * from snp_step with read only)
,step as (
	select sm0.i_mapping
		,count(1) as cnt
	from step0
		inner join sm0
			on step0.i_mapping = sm0.i_mapping
	group by sm0.i_mapping
)
,st0 as (select * from snp_table with read only)
,smr as (select * from snp_map_ref with read only)
,spn as (select * from snp_phy_node with read only)
,st as (
	select
		sm0.i_mapping
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
	from st0
		inner join smr
			on st0.global_id = smr.ref_guid
		inner join smc0
			on smr.i_map_ref = smc0.i_map_ref
		inner join spn
			on smc0.i_map_comp = spn.i_map_comp
		inner join sdc
			on spn.i_owner_ds = sdc.i_deploy_spec
		inner join sm0
			on sdc.i_owner_mapping = sm0.i_mapping
		left join smr smr2
			on spn.i_tgt_comp_km = smr2.i_map_ref
)
,st1 as (
	select st.i_mapping
		,count(case when st.dependency_type = 'TARGET' then 1 end) as cnt_tgt
		,count(case when st.dependency_type = 'SOURCE' then 1 end) as cnt_src
		,count(case when st.dependency_type = 'STAGING' then 1 end) as cnt_stg
	from st
	group by st.i_mapping
)
,sm as (
	select sm0.i_mapping map_no
		,sm0.name as map_name
		,sf.folder_name as fol_name
		,sm0.is_reusable
		,decode(sdc.cleanup_on_error,1,'True',0,'False',sdc.cleanup_on_error) as cleanup_on_error
		,decode(sdc.is_concurrent,1,'True',0,'False',sdc.cleanup_on_error) as is_concurrent
		,decode(sdc.is_frozen,1,'True',0,'False',sdc.cleanup_on_error) as is_frozen
		,coalesce(step.cnt,0) as used_by_pkg_steps
		,coalesce(st1.cnt_src,0) as number_of_sources
		,coalesce(st1.cnt_tgt,0) as number_of_targets
		,coalesce(st1.cnt_stg,0) as number_of_staging
		,coalesce(ss.cnt,0) as number_of_scenarios
		,coalesce(smc.cnt,0) as number_of_components
		,to_char(sm0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(sm0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from sm0
		left join sf
			on sm0.i_folder = sf.i_folder
		left join sdc
			on sm0.i_mapping = sdc.i_owner_mapping
		left join ss
			on sm0.i_mapping = ss.i_mapping
		left join smc
			on sm0.i_mapping = smc.i_mapping
		left join step
			on sm0.i_mapping = step.i_mapping
		left join st1
			on sm0.i_mapping = st1.i_mapping
)
select *
from sm
order by last_deploy_ts desc
;