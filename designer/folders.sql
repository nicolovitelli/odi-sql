with sf0 as (select * from snp_folder with read only)
,sm0 as (select * from snp_mapping with read only)
,sp0 as (select * from snp_package with read only)
,st0 as (select * from snp_trt with read only)
,sm as (
	select sf0.i_folder
		,count(1) as cnt
	from sm0
		inner join sf0
			on sm0.i_folder = sf0.i_folder
	where sm0.is_reusable = 'N'
	group by sf0.i_folder
)
,srm as (
	select sf0.i_folder
		,count(1) as cnt
	from sm0
		inner join sf0
			on sm0.i_folder = sf0.i_folder
	where sm0.is_reusable = 'Y'
	group by sf0.i_folder
)
,sp as (
	select sf0.i_folder
		,count(1) as cnt
	from sp0
		inner join sf0
			on sp0.i_folder = sf0.i_folder
	group by sf0.i_folder
)
,st as (
	select sf0.i_folder
		,count(1) as cnt
	from st0
		inner join sf0
			on st0.i_folder = sf0.i_folder
	group by sf0.i_folder
)
,sf as (
	select sf0.i_folder fol_no
		,sf0.folder_name
		,sf00.folder_name as parent_folder_name
		,coalesce(sm.cnt,0) as mapping_count
		,coalesce(srm.cnt,0) as rmapping_count
		,coalesce(sp.cnt,0) as package_count
		,coalesce(st.cnt,0) as procedure_count
		,to_char(sf0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(sf0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from sf0
		left join sm
			on sf0.i_folder = sm.i_folder
		left join srm
			on sf0.i_folder = srm.i_folder
		left join sp
			on sf0.i_folder = sp.i_folder
		left join st
			on sf0.i_folder = st.i_folder
		left join sf0 sf00
			on sf0.par_i_folder = sf00.i_folder
)
select *
from sf
order by last_deploy_ts desc
;