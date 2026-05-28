with sv as (select * from snp_var with read only)
,sth as (select * from snp_txt_header with read only)
,sl as (select * from snp_lschema with read only)
select
	sv.i_var as var_no
	,sv.var_name
	,coalesce(sv.i_project,0) prj_no
	,coalesce(sth.full_text,to_clob('Unspecified')) as var_text
	,coalesce(sl.i_lschema,0) as lschema_no
	,decode(sv.ind_store,'N','No History','L','Latest Value','H','All Values','Unspecified') as var_history
	,decode(sv.var_datatype,'T','Text','D','Datetime','A','Alphanumeric','N','Numeric','Unspecified') as var_datatype
	,coalesce(to_char(sv.def_n), to_char(sv.def_v), to_char(sv.def_date),'Unspecified') as var_default_value
	,to_char(sv.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sv.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from sv
	left join sth
		on sv.i_txt_var_in = sth.i_txt
	left join sl
		on sv.lschema_name = sl.lschema_name
;