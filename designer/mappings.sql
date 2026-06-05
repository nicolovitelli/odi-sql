with sm0 as (select * from snp_mapping with read only)
,sdc as (select * from snp_deploy_spec with read only)
,sf as (select * from snp_folder with read only)
,sp as (select * from snp_project with read only)
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
		,count(case when smc0.type_name = 'JOIN' then 1 end) as cnt_join
		,count(case when smc0.type_name = 'DATASTORE' then 1 end) as cnt_ds
		,count(case when smc0.type_name = 'LOOKUP' then 1 end) as cnt_lkp
		,count(case when smc0.type_name = 'AGGREGATE' then 1 end) as cnt_agg
		,count(case when smc0.type_name = 'REUSABLEMAPPING' then 1 end) as cnt_rm
		,count(case when smc0.type_name = 'FILTER' then 1 end) as cnt_fil
		,count(case when smc0.type_name = 'EXPRESSION' then 1 end) as cnt_exp
		,count(case when smc0.type_name = 'DISTINCT' then 1 end) as cnt_dis
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
,st_ds as (
	select st.i_mapping
		,count(case when st.dependency_type = 'TARGET' then 1 end) as cnt_tgt
		,count(case when st.dependency_type = 'SOURCE' then 1 end) as cnt_src
		,count(case when st.dependency_type = 'STAGING' then 1 end) as cnt_stg
	from st
	group by st.i_mapping
)
,smcp as (select * from snp_map_cp with read only)
,sma as (select * from snp_map_attr with read only)
,sme as (select * from snp_map_expr with read only)
,sv as (select * from snp_var with read only)
,sm_expr as (
	select /*+ materialize */ sm0.i_mapping,
        sme.txt as expr_clob
    from sm0
	    inner join snp_map_comp smc0
	    	on sm0.i_mapping = smc0.i_owner_mapping
	    inner join smcp
	    	on smc0.i_map_comp = smcp.i_owner_map_comp
	    inner join sma
	    	on smcp.i_map_cp = sma.i_owner_map_cp
	    inner join sme
	    	on sma.i_map_attr = sme.i_owner_map_attr
    where sme.txt is not null
      and dbms_lob.instr(sme.txt, '#', 1, 1) > 0
)
,sm_var as (
	select /*+ materialize */ sv.i_var
        ,sv.var_name
        ,sv.var_type
        ,sp.project_code
        ,'#' || sp.project_code || '.' || sv.var_name as search_proj
        ,'#GLOBAL.' || sv.var_name as search_global
        ,'#' || sv.var_name as search_short
    from sv
    	left join sp
    		on sv.i_project = sp.i_project
)
,sm_expr_var as (
	select me.i_mapping
		,count(distinct v.var_name) as cnt
	from sm_expr me
		inner join sm_var v 
	    	on dbms_lob.instr(me.expr_clob, v.var_name, 1, 1) > 0 
	where (v.var_type = 'P' and dbms_lob.instr(me.expr_clob, v.search_proj, 1, 1) > 0)
	    or
	    (v.var_type = 'G' and (
	        dbms_lob.instr(me.expr_clob, v.search_global, 1, 1) > 0 
	        or dbms_lob.instr(me.expr_clob, v.search_short, 1, 1) > 0
	    ))
	group by me.i_mapping
)
,sm as (
	select sm0.i_mapping map_no
		,sm0.name as map_name
		,sf.folder_name as fol_name
		,sp.project_name as prj_name
		,sm0.is_reusable
		,decode(sdc.is_concurrent,1,'True',0,'False',sdc.cleanup_on_error) as is_concurrent
		,decode(sdc.is_frozen,1,'True',0,'False',sdc.cleanup_on_error) as is_frozen
		,decode(sdc.cleanup_on_error,1,'True',0,'False',sdc.cleanup_on_error) as do_cleanup_on_error
		,coalesce(step.cnt,0) as package_step_usage_count
		,coalesce(st_ds.cnt_src,0) as source_datastore_count
		,coalesce(st_ds.cnt_tgt,0) as target_datastore_count
		,coalesce(st_ds.cnt_stg,0) as staging_datastore_count
		,coalesce(ss.cnt,0) as scenario_count
		,coalesce(smc.cnt,0) as component_count
		,coalesce(smc.cnt_join,0) as join_component_count
		,coalesce(smc.cnt_ds,0) as datastore_component_count
		,coalesce(smc.cnt_lkp,0) as lookup_component_count
		,coalesce(smc.cnt_agg,0) as aggregate_component_count
		,coalesce(smc.cnt_rm,0) as reusable_component_count
		,coalesce(smc.cnt_fil,0) as filter_component_count
		,coalesce(smc.cnt_exp,0) as expression_component_count
		,coalesce(smc.cnt_dis,0) as distinct_component_count
		,coalesce(sm_expr_var.cnt,0) as variable_count
		,to_char(sm0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(sm0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from sm0
		left join sf
			on sm0.i_folder = sf.i_folder
		left join sp
			on sf.i_project = sp.i_project
		left join sdc
			on sm0.i_mapping = sdc.i_owner_mapping
		left join ss
			on sm0.i_mapping = ss.i_mapping
		left join smc
			on sm0.i_mapping = smc.i_mapping
		left join step
			on sm0.i_mapping = step.i_mapping
		left join st_ds
			on sm0.i_mapping = st_ds.i_mapping
		left join sm_expr_var
			on sm0.i_mapping = sm_expr_var.i_mapping
		left join smc
			on sm0.i_mapping = smc.i_mapping
)
select *
from sm
order by last_deploy_ts desc
;