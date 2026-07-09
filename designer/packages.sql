with sp0 as (select * from snp_package with read only)
,sf as (select * from snp_folder with read only)
,step0 as (select * from snp_step with read only)
,sprj0 as (select * from snp_project with read only)
,ss0 as (select * from snp_scen with read only)
,ss as (
	select sp0.i_package
		,count(1) as cnt
	from ss0
		inner join sp0
			on ss0.i_package = sp0.i_package
	group by sp0.i_package
)
,step as (
	select sp0.i_package
		,count(1) as cnt
		,count(case when step0.step_type = 'T' then 1 end) as cnt_prc_steps
		,count(case when step0.step_type in ('V', 'VP', 'VE', 'VD') then 1 end) as cnt_var_steps
		,count(case when step0.step_type = 'M' then 1 end) as cnt_map_steps
		,count(case when step0.step_type = 'SE' then 1 end) as cnt_odi_steps
	from step0
		inner join sp0
			on step0.i_package = sp0.i_package
	group by sp0.i_package
)
,step_off as (
	select sp0.i_package
		,count(1) as cnt
	from step0
		inner join sp0
			on step0.i_package = sp0.i_package
	and step0.ok_next_step is null 
    and step0.ko_next_step is null
    and step0.i_step not in (
        select nvl(ok_next_step, -1) 
        from step0 
        where i_package = sp0.i_package
    )
    and step0.i_step not in (
        select nvl(ko_next_step, -1) 
        from step0 
        where i_package = sp0.i_package
    )
    group by sp0.i_package
)
,sprj as (
	select sp0.i_package, sprj0.project_name
	from sprj0
		inner join sf
			on sprj0.i_project = sf.i_project
		inner join sp0
			on sf.i_folder = sp0.i_folder
)
,sp as (
	select sp0.i_package as pkg_no
		,sp0.pack_name as pkg_name
		,sf.folder_name as fol_name
		,sprj.project_name as prj_name
		,coalesce(ss.cnt,0) as scenario_count
		,coalesce(step.cnt,0) as step_count
		,coalesce(step_off.cnt,0) as unreachable_step_count
		,coalesce(step.cnt_prc_steps,0) as procedure_step_count
		,coalesce(step.cnt_var_steps,0) as variable_step_count
		,coalesce(step.cnt_map_steps,0) as mapping_step_count
		,coalesce(step.cnt_odi_steps,0) as odi_command_step_count
		,to_char(sp0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(sp0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from sp0
		left join sf
			on sp0.i_folder = sf.i_folder
		left join ss
			on sp0.i_package = ss.i_package
		left join step
			on sp0.i_package = step.i_package
		left join step_off
			on sp0.i_package = step_off.i_package
		left join sprj
			on sp0.i_package = sprj.i_package
)
select *
from sp
order by last_deploy_ts desc
;