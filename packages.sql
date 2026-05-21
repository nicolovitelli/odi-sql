/*
  extracts all packages available in ODI.
*/
with sp as (select * from snp_package with read only)
,sf as (select * from snp_folder with read only)
select
	sp.i_package pkg_no
	,sp.pack_name pkg_name
	,coalesce(sf.i_folder,0) fol_no
	,to_char(sp.first_date,'yyyy-mm-dd hh24:mi:ss') first_deploy_ts
	,to_char(sp.last_date,'yyyy-mm-dd hh24:mi:ss') last_deploy_ts
from sp
	left join sf
		on sp.i_folder = sf.i_folder
;