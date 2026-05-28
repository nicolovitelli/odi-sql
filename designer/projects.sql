with sp as (select * from snp_project with read only)
select i_project as prj_no
	,project_name as prj_name
	,to_char(first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from sp
;