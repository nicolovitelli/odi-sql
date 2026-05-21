/*
  extracts all associations between context - logical schema - physical schema
*/
with spc as (select * from snp_pschema_cont with read only)
select 
	i_context as cont_no
	,i_lschema as lschema_no
	,i_pschema as pschema_no
from spc
;