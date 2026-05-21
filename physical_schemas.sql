/*
  extracts all physical schemas available in ODI.
*/
select sp.i_pschema as pschema_no
	,coalesce(sp.schema_name,'Unspecified') as main_schema
	,coalesce(sp.wschema_name,'Unspecified') as work_schema
	,sc.con_name as internal_name
	,st.tech_int_name as techno_name
	,to_char(sp.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sp.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from snp_pschema sp
	inner join snp_connect sc
		on sp.i_connect = sc.i_connect
	inner join snp_techno st
		on sc.i_techno = st.i_techno
;