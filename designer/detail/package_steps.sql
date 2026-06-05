with ss0 as (select * from snp_step with read only)
,sp as (select * from snp_package with read only)
,sth as (select * from snp_txt_header with read only)
,st as (select * from snp_trt with read only)
,sv as (select * from snp_var with read only)
,sm as (select * from snp_mapping with read only)
,ss as (
	select ss0.i_step as pkg_step_no
		,ss0.step_name as pkg_step_name
		,decode(ss0.step_type
			,'V'
			,'Refresh Variable'
			,'VD'
			,'Declare Variable'
			,'OE'
			,'OS Command'
			,'VS'
			,'Set Variable'
			,'VE'
			,'Evaluate Variable'
			,'T'
			,'Procedure'
			,'SE'
			,'ODI Command'
			,'M'
			,'Mapping'
			,ss0.step_type
			) as pkg_step_type
		,ss0.nno as pkg_step_order
		,sp.i_package as pkg_no
		,sp.pack_name as pkg_name
		,coalesce(ss0.i_trt,0) as prc_no
		,st.trt_name as prc_name
		,coalesce(ss0.i_var,0) as var_no
		,sv.var_name
		,coalesce(sth.full_text,to_clob('Unspecified')) as var_value
		,coalesce(ss0.i_mapping,0) as map_no
		,sm.name as map_name
	from ss0
		inner join sp
			on ss0.i_package = sp.i_package
		left join sth
			on ss0.i_txt_var_value = sth.i_txt
		left join st
			on ss0.i_trt = st.i_trt
		left join sv
			on ss0.i_var = sv.i_var
		left join sm
			on ss0.i_mapping = sm.i_mapping
	order by sp.i_package, ss0.nno
)
select *
from ss
;