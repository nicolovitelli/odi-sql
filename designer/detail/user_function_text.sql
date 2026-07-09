with su0 as (select * from snp_ufunc with read only)
,sui as (select * from snp_ufunc_impl with read only)
,sut as (select * from snp_ufunc_techno with read only)
,sth as (select * from snp_txt_header with read only)
,su as (
	select su0.i_ufunc as ufunc_no
		,su0.ufunc_name as ufunc_name
		,sut.tech_int_name as ufunc_tech
		,sth.full_text as ufunc_text
	from su0
		inner join sui
			on su0.i_ufunc = sui.i_ufunc
		inner join sut
			on sui.i_ufunc_impl = sut.i_ufunc_impl
		inner join sth
			on sui.i_txt_impl = sth.i_txt
	order by su0.last_date desc
)
select *
from su
;