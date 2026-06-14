with st0 as (select * from snp_trt with read only)
,sf as (select * from snp_folder with read only)
,ss0 as (select * from snp_scen with read only)
,slt0 as (select * from snp_line_trt with read only)
,sp as (select * from snp_project with read only)
,stc as (select * from snp_txt_crossr with read only)
,su0 as (select * from snp_ufunc with read only)
,step0 as (select * from snp_step with read only)
,slp0 as (select * from snp_lp_step with read only)
,sv0 as (select * from snp_var with read only)
,ss as (
	select st0.i_trt
		,count(1) as cnt
	from ss0
		inner join st0
			on ss0.i_trt = st0.i_trt
	group by st0.i_trt
)
,slt as (
	select st0.i_trt
		,count(1) as cnt
		,count(case when slt0.always_exe = 1 then 1 end) as cnt_enabled_steps
	from slt0
		inner join st0
			on slt0.i_trt = st0.i_trt
	group by st0.i_trt
)
,sv as (
	select st0.i_trt
		,count(1) as cnt
	from sv0
		inner join stc
			on sv0.i_var = stc.i_var
		inner join slt0
			on stc.i_txt = slt0.def_i_txt
			or stc.i_txt = slt0.col_i_txt
		inner join st0
			on slt0.i_trt = st0.i_trt
	where stc.object_type = 'V'
	group by st0.i_trt
)
,su as (
	select st0.i_trt
		,count(1) as cnt
	from su0
		inner join stc
			on su0.i_ufunc = stc.i_ufunc
		inner join slt0
			on stc.i_txt = slt0.def_i_txt
			or stc.i_txt = slt0.col_i_txt
		inner join st0
			on slt0.i_trt = st0.i_trt
	where stc.object_type = 'F'
	group by st0.i_trt
)
,step as (
	select st0.i_trt
		,count(1) as cnt
	from step0
		inner join st0
			on step0.i_trt = st0.i_trt
	group by st0.i_trt
)
,slp as (
	select st0.i_trt
		,count(1) as cnt
	from slp0
		inner join ss0
			on slp0.scen_name = ss0.scen_name
			and slp0.scen_version = ss0.scen_version
		inner join st0
			on ss0.i_trt = st0.i_trt
	group by st0.i_trt
)
,st as (
	select st0.i_trt as prc_no
		,st0.trt_name as prc_name
		,sf.folder_name as fol_name
		,sp.project_name as prj_name
		,coalesce(slt.cnt,0) as step_count
		,coalesce(slt.cnt_enabled_steps,0) as enabled_step_count
		,coalesce(sv.cnt,0) as variable_count
		,coalesce(ss.cnt,0) as scenario_count
		,coalesce(su.cnt,0) as user_function_count
		,coalesce(step.cnt,0) as package_step_usage_count
		,coalesce(slp.cnt,0) as load_plan_usage_count
		,case when ss0.scen_no is not null
			then 'Y'
			else 'N'
		end as is_scenario_outdated
		,to_char(st0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(st0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from st0
		left join sf
			on st0.i_folder = sf.i_folder
		left join sp
			on sf.i_project = sp.i_project
		left join ss
			on st0.i_trt = ss.i_trt
		left join slt
			on st0.i_trt = slt.i_trt
		left join sv
			on st0.i_trt = sv.i_trt
		left join su
			on st0.i_trt = su.i_trt
		left join step
			on st0.i_trt = step.i_trt
		left join slp
			on st0.i_trt = slp.i_trt
		left join ss0
			on st0.i_trt = ss0.i_trt
			and st0.last_date > ss0.last_date
	where st0.trt_type = 'U'
)
select *
from st
order by last_deploy_ts desc
;