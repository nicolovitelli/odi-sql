/*
  extracts all user functions available in ODI.
*/
with su as (select * from snp_ufunc with read only)
,sui as (select * from snp_ufunc_impl with read only)
,sth as (select * from snp_txt_header with read only)
,sut as (select * from snp_ufunc_techno with read only)
select su.i_ufunc ufunc_no
	,su.ufunc_name
	,su.group_name as ufunc_group
	,su.i_project as prj_no
	,to_char(su.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(su.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from su