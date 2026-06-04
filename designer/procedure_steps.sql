with st as (select * from snp_trt with read only)
,slt0 as (select * from snp_line_trt with read only)
,sth as (select * from snp_txt_header with read only)
,slt as (
	select st.trt_name as prc_name
		,slt0.i_line_trt as prc_step_no
		,slt0.sql_name as prc_step_name
		,slt0.ord_trt as prc_step_order
		,sth.full_text as prc_step_text
	from slt0
		inner join st
				on slt0.i_trt = st.i_trt
		inner join sth
				on coalesce(slt0.col_i_txt,slt0.def_i_txt) = sth.i_txt
	where st.trt_type = 'U'
	order by st.i_trt, slt0.i_line_trt, slt0.ord_trt
)
select *
from slt
;