with st0 as (select * from snp_trt with read only)
,sf as (select * from snp_folder with read only)
,ss0 as (select * from snp_scen with read only)
,ss as (
	select st0.i_trt
		,count(1) as cnt
	from ss0
		inner join st0
			on ss0.i_trt = st0.i_trt
	group by st0.i_trt
)
,slt0 as (select * from snp_line_trt with read only)
,slt as (
	select st0.i_trt
		,count(1) as cnt
		,count(case when slt0.always_exe = 1 then 1 end) as cnt_active_steps
	from slt0
		inner join st0
			on slt0.i_trt = st0.i_trt
	group by st0.i_trt
)
,stc as (select * from snp_txt_crossr with read only)
,sv0 as (select * from snp_var with read only)
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
,su0 as (select * from snp_ufunc with read only)
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
,step0 as (select * from snp_step with read only)
,step as (
	select st0.i_trt
		,count(1) as cnt
	from step0
		inner join st0
			on step0.i_trt = st0.i_trt
	group by st0.i_trt
)
,st as (
	select st0.i_trt as prc_no
		,st0.trt_name as prc_name
		,sf.folder_name as fol_name
		,coalesce(slt.cnt,0) as number_of_steps
		,coalesce(slt.cnt_active_steps,0) as number_of_active_steps
		,coalesce(sv.cnt,0) as number_of_variables
		,coalesce(su.cnt,0) as number_of_ufunctions
		,coalesce(ss.cnt,0) as number_of_scenarios
		,coalesce(step.cnt,0) as used_by_pkg_steps
		,to_char(st0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(st0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from st0
		left join sf
			on st0.i_folder = sf.i_folder
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
	where st0.trt_type = 'U'
)
select *
from st
order by last_deploy_ts desc
;