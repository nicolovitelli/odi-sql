with sc as (select * from snp_col with read only)
,st as (select * from snp_table with read only)
select sc.i_col as col_no
	,sc.col_name as col_name
	,sc.source_dt as col_datatype
	,coalesce(sc.longc,-1) as col_length
	,coalesce(sc.scalec,-1) as col_scale
	,st.i_table as ds_no
	,to_char(sc.first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sc.last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from sc
	inner join st
		on sc.i_table = st.i_table
order by st.i_table
;