with sp0 as (select * from snp_project with read only)
,sf0 as (select i_project from snp_folder with read only)
,sf as (
	select sf0.i_project
		,count(1) as cnt
	from sf0
	group by sf0.i_project
)
,ss0 as (select i_project from snp_sequence with read only)
,ss as (
	select ss0.i_project
		,count(1) as cnt
	from ss0
	group by ss0.i_project
)
,st0 as (select i_project from snp_trt with read only)
,st as (
	select st0.i_project
		,count(1) as cnt
	from st0
	group by st0.i_project
)
,su0 as (select i_project from snp_ufunc with read only)
,su as (
	select su0.i_project
		,count(1) as cnt
	from su0
	group by su0.i_project
)
,sv0 as (select i_project from snp_var with read only)
,sv as (
	select sv0.i_project
		,count(1) as cnt
	from sv0
	group by sv0.i_project
)
,sp as (
	select sp0.i_project as prj_no
		,sp0.project_name as prj_name
		,coalesce(sf.cnt,0) as number_of_folders
		,coalesce(ss.cnt,0) as number_of_sequences
		,coalesce(st.cnt,0) as number_of_procedures
		,coalesce(su.cnt,0) as number_of_ufunctions
		,coalesce(sv.cnt,0) as number_of_variables
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
)
select *
from sp
;