with sc0 as (select * from snp_col with read only)
,st as (select * from snp_table with read only)
,sc as (
	select st.i_table as ds_no
		,st.res_name as ds_name
		,sc0.i_col as col_no
		,sc0.col_name as col_name
		,sc0.source_dt as col_datatype
		,sc0.longc as col_length
		,sc0.scalec as col_scale
		,to_char(sc0.first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(sc0.last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from sc0
		inner join st
			on sc0.i_table = st.i_table
)
select *
from sc
order by last_deploy_ts desc
;