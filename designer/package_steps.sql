with ss0 as (select * from snp_step with read only)
,sp as (select * from snp_package with read only)
,sth as (select * from snp_txt_header with read only)
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
		,coalesce(ss0.i_trt,0) as prc_no
		,coalesce(ss0.i_var,0) as var_no
		,coalesce(sth.full_text,to_clob('Unspecified')) as var_value
		,coalesce(ss0.i_mapping,0) as map_no
	from ss0
		inner join sp
			on ss0.i_package = sp.i_package
		left join sth
			on ss0.i_txt_var_value = sth.i_txt
	order by sp.i_package, ss0.nno
)
select *
from ss
;