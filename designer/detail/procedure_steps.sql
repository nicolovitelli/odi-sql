with st as (select * from snp_trt with read only)
,slt0 as (select * from snp_line_trt with read only)
,sth as (select * from snp_txt_header with read only)
,slt as (
	select st.trt_name as prc_name
		,slt0.i_line_trt as prc_step_no
		,slt0.sql_name as prc_step_name
		,slt0.ord_trt as prc_step_order
		,sths.full_text as prc_step_src_text
		,stht.full_text as prc_step_tgt_text
	from slt0
		inner join st
				on slt0.i_trt = st.i_trt
		left join sth sths
				on slt0.col_i_txt = sths.i_txt
		left join sth stht
			on slt0.def_i_txt = stht.i_txt
	where st.trt_type = 'U'
	order by st.i_trt, slt0.i_line_trt, slt0.ord_trt
)
select *
from slt
;