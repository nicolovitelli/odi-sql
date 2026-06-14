with st0 as (select * from snp_table with read only)
,sm as (select * from snp_model with read only)
,ssm as (select * from snp_sub_model with read only)
,smap0 as (select * from snp_mapping with read only)
,smr as (select * from snp_map_ref with read only)
,smc as (select * from snp_map_comp with read only)
,spn as (select * from snp_phy_node with read only)
,sdc as (select * from snp_deploy_spec with read only)
,sc0 as (select * from snp_col with read only)
,sc as (
	select st0.i_table
		,count(1) as cnt
	from sc0
		inner join st0
			on sc0.i_table = st0.i_table
	group by st0.i_table
)
,smap as (
	select st0.i_table
		,count(case when (spn.i_tgt_comp_km is null and spn.i_src_comp_km is not null) then 1 end) as cnt_src
		,count(case when (spn.i_tgt_comp_km is not null and spn.i_src_comp_km is null) then 1 end) as cnt_tgt
		,count(case when (spn.i_tgt_comp_km is not null and spn.i_src_comp_km is not null) then 1 end) as cnt_stg
	from st0
		inner join smr
			on st0.global_id = smr.ref_guid
		inner join smc
			on smr.i_map_ref = smc.i_map_ref
		inner join spn
			on smc.i_map_comp = spn.i_map_comp
		inner join sdc
			on spn.i_owner_ds = sdc.i_deploy_spec
		inner join smap0
			on sdc.i_owner_mapping = smap0.i_mapping
		left join smr smr2
			on spn.i_tgt_comp_km = smr2.i_map_ref
	group by st0.i_table
)
,st as (
	select st0.i_table as ds_no
		,st0.res_name as ds_pname
		,st0.table_name as ds_lname
		,st0.table_alias as ds_alias
		,decode(st0.table_type
			,'T'
			,'Table'
			,'V'
			,'View'
			,st0.table_type
		) as ds_type
		,sm.mod_name as model_name
		,ssm.smod_name as sub_model_name
		,coalesce(smap.cnt_tgt,0) as target_usage_count
		,coalesce(smap.cnt_src,0) as source_usage_count
		,coalesce(smap.cnt_stg,0) as staging_usage_count
		,coalesce(sc.cnt,0) as column_count
		,to_char(st0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(st0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from st0
		inner join sm
			on st0.i_mod = sm.i_mod
		inner join ssm
			on st0.i_sub_model = ssm.i_smod
		left join sc
			on st0.i_table = sc.i_table
		left join smap
			on st0.i_table = smap.i_table
)
select *
from st
order by last_deploy_ts desc
;