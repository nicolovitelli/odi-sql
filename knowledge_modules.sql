/*
  extracts all knowledge modules available in ODI.
*/
with st as (select * from snp_trt with read only)
select
	st.i_trt as km_no
	,st.trt_name as km_name
	,decode(st.trt_type
		,'KJ'
		,'Journalizing Knowledge Module'
		,'KL'
		,'Loading Knowledge Module'
		,'KI'
		,'Integration Knowledge Module'
		,'KS'
		,'Service KM'
		,'KR'
		,'Reverse-engineering Knowledge Module'
		,'KC'
		,'Check Knowledge Module'
		,st.trt_type
	) as km_type
	,coalesce(st.i_project,0) as prj_no
	,to_char(st.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(st.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from st
where st.trt_type <> 'U'
;