/*
  extracts all logical schemas available in ODI.
*/
with sl as (select * from snp_lschema with read only)
,st as (select * from snp_techno with read only)
select sl.i_lschema lschema_no
	,st.tech_int_name techno_name
	,sl.lschema_name
	,to_char(sl.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sl.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from sl
	inner join st
		on sl.i_techno = st.i_techno
;