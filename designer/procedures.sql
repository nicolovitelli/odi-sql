/*
  extracts all procedures available in ODI.
*/
with st as (select * from snp_trt with read only)
select
	st.i_trt as prc_no
	,st.trt_name as prc_name
	,st.i_folder as fol_no
	,to_char(st.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(st.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from st
where st.trt_type = 'U'
;