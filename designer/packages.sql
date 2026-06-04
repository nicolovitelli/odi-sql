with sp0 as (select * from snp_package with read only)
,sf as (select * from snp_folder with read only)
,ss0 as (select * from snp_scen with read only)
,ss as (
	select sp0.i_package
		,count(1) as cnt
	from ss0
		inner join sp0
			on ss0.i_package = sp0.i_package
	group by sp0.i_package
)
,step0 as (select * from snp_step with read only)
,step as (
	select sp0.i_package
		,count(1) as cnt
		,count(case when step0.i_trt is not null then 1 end) as cnt_prc_steps
		,count(case when step0.i_var is not null then 1 end) as cnt_var_steps
		,count(case when step0.i_mapping is not null then 1 end) as cnt_map_steps
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
,sp as (
	select sp0.i_package as pkg_no
		,sp0.pack_name as pkg_name
		,sf.folder_name as fol_name
		,coalesce(ss.cnt,0) as number_of_scenarios
		,coalesce(step.cnt,0) as number_of_steps
		,coalesce(step.cnt_prc_steps,0) as number_of_prc_steps
		,coalesce(step.cnt_var_steps,0) as number_of_var_steps
		,coalesce(step.cnt_map_steps,0) as number_of_map_steps
		,coalesce(step_off.cnt,0) as number_of_inactive_steps
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
)
select *
from sp
order by last_deploy_ts desc
;