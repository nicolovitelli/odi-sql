/*
  extracts procedure steps for each procedure available in ODI.
*/
with st as (select * from snp_trt with read only)
,slt as (select * from snp_line_trt with read only)
,sth as (select * from snp_txt_header with read only)
select
	,st.trt_name as prc_name
	,slt.i_line_trt as prc_step_no
	,slt.sql_name as prc_step_name
	,slt.ord_trt as prc_step_order
	,sth.full_text as prc_step_text
from st
	inner join slt
			on st.i_trt = slt.i_trt
	inner join sth
			on coalesce(slt.col_i_txt,slt.def_i_txt) = sth.i_txt
where st.trt_type = 'U'
order by st.i_trt, slt.i_line_trt, slt.ord_trt
;