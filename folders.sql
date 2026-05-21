/*
  extracts all folders available in ODI.
*/
with sf as (select * from snp_folder with read only)
select sf.i_folder fol_no
	,sf.folder_name
	,to_char(sf.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sf.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from sf
;