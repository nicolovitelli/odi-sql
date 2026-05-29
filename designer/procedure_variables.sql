with sv as (select * from snp_var with read only)
,stc as (select * from snp_txt_crossr with read only)
,slt as (select * from snp_line_trt with read only)
,st as (select * from snp_trt with read only)
select distinct sv.i_var as var_no
	,st.i_trt as prc_no
from sv
	inner join stc
		on sv.i_var = stc.i_var
	inner join slt
		on stc.i_txt = slt.def_i_txt
		or stc.i_txt = slt.col_i_txt
	inner join st
		on slt.i_trt = st.i_trt
where 1=1
	and st.trt_type = 'U'
	and stc.object_type = 'V'
;