with sp0 as (select * from snp_project with read only)
,sf0 as (select * from snp_folder with read only)
,spkg0 as (select * from snp_package with read only)
,sm0 as (select * from snp_mapping with read only)
,scen0 as (select * from snp_scen with read only)
,ss0 as (select i_project from snp_sequence with read only)
,st0 as (select i_project, trt_type from snp_trt with read only)
,su0 as (select i_project from snp_ufunc with read only)
,sv0 as (select i_project from snp_var with read only)
,sf as (
	select sp0.i_project
		,count(1) as cnt
	from sf0
		inner join sp0
			on sf0.i_project = sp0.i_project
	group by sp0.i_project
)
,sm as (
	select sp0.i_project
		,count(1) as cnt
	from sm0
		inner join sf0
			on sm0.i_folder = sf0.i_folder
		inner join sp0
			on sf0.i_project = sp0.i_project
	group by sp0.i_project
)
,spkg as (
	select sp0.i_project
		,count(1) as cnt
	from spkg0
		inner join sf0
			on spkg0.i_folder = sf0.i_folder
		inner join sp0
			on sf0.i_project = sp0.i_project
	group by sp0.i_project
)
,scen as (
	select sp0.i_project
		,count(1) as cnt
	from scen0
		inner join spkg0
			on scen0.i_package = spkg0.i_package
		inner join sf0
			on spkg0.i_folder = sf0.i_folder
		inner join sp0
			on sf0.i_project = sp0.i_project
	group by sp0.i_project
)
,ss as (
	select sp0.i_project
		,count(1) as cnt
	from ss0
		inner join sp0
			on ss0.i_project = sp0.i_project
	group by sp0.i_project
)
,st as (
	select sp0.i_project
		,count(case when st0.trt_type = 'U' then 1 end) as cnt_prc
		,count(case when st0.trt_type <> 'U' then 1 end) as cnt_km
	from st0
		inner join sp0
			on st0.i_project = sp0.i_project
	group by sp0.i_project
)
,su as (
	select sp0.i_project
		,count(1) as cnt
	from su0
		inner join sp0
			on su0.i_project = sp0.i_project
	group by sp0.i_project
)
,sv as (
	select sp0.i_project
		,count(1) as cnt
	from sv0
		inner join sp0
			on sv0.i_project = sp0.i_project
	group by sp0.i_project
)
,sp as (
	select sp0.i_project as prj_no
		,sp0.project_name
		,coalesce(sf.cnt,0) as folder_count
		,coalesce(st.cnt_km,0) as knowledge_module_count
		,coalesce(sm.cnt,0) as mapping_count
		,coalesce(spkg.cnt,0) as package_count
		,coalesce(st.cnt_prc,0) as procedure_count
		,coalesce(scen.cnt,0) as scenario_count
		,coalesce(ss.cnt,0) as sequence_count
		,coalesce(su.cnt,0) as user_function_count
		,coalesce(sv.cnt,0) as variable_count
		,to_char(sp0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(sp0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from sp0
		left join sf
			on sp0.i_project = sf.i_project
		left join ss
			on sp0.i_project = ss.i_project
		left join st
			on sp0.i_project = st.i_project
		left join su
			on sp0.i_project = su.i_project
		left join sv
			on sp0.i_project = sv.i_project
		left join sm
			on sp0.i_project = sm.i_project
		left join spkg
			on sp0.i_project = spkg.i_project
		left join scen
			on sp0.i_project = scen.i_project
)
select *
from sp
order by last_deploy_ts desc
;