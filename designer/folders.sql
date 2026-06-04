with sf0 as (select * from snp_folder with read only)
,sf as (
	select sf0.i_folder fol_no
		,sf0.folder_name
		,to_char(sf0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(sf0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from sf0
)
select *
from sf
;