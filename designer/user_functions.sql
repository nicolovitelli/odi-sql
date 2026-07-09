with su0 as (select * from snp_ufunc with read only)
,sui as (select * from snp_ufunc_impl with read only)
,sth as (select * from snp_txt_header with read only)
,sut as (select * from snp_ufunc_techno with read only)
,sp as (select * from snp_project with read only)
,su as (
	select su0.i_ufunc as ufunc_no
		,su0.ufunc_name as ufunc_name
		,su0.group_name as ufunc_group
		,sp.project_name as prj_name
		,to_char(su0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(su0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from su0
		left join sp
			on su0.i_project = sp.i_project
)
select *
from su
order by last_deploy_ts desc
;