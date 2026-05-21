/*
  extracts package steps for each package available in ODI.
  "var_value" is populated only if the step is a 'Set Variable' step.
*/
with ss as (select * from snp_step with read only)
,sp as (select * from snp_package with read only)
,sth as (select * from snp_txt_header with read only)
select
	ss.i_step as pkg_step_no
	,ss.step_name as pkg_step_name
	,decode(ss.step_type
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
		,ss.step_type
		) as pkg_step_type
	,ss.nno as pkg_step_order
	,sp.i_package as pkg_no
	,coalesce(ss.i_trt,0) as prc_no
	,coalesce(ss.i_var,0) as var_no
	,coalesce(sth.full_text,to_clob('Unspecified')) as var_value
	,coalesce(ss.i_mapping,0) as map_no
from ss
	inner join sp
		on ss.i_package = sp.i_package
	left join sth
		on ss.i_txt_var_value = sth.i_txt
order by sp.i_package, ss.nno
;