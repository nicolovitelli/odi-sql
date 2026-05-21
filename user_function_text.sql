/*
  extracts text for each user function available in ODI.
  the same user function might appear in different rows if it's implemented with several technologies.
*/
with su as (select * from snp_ufunc with read only)
,sui as (select * from snp_ufunc_impl with read only)
,sut as (select * from snp_ufunc_techno with read only)
,sth as (select * from snp_txt_header with read only)
select su.i_ufunc as ufunc_no
	,sut.tech_int_name as ufunc_tech
	,sth.full_text as ufunc_text
from su
	inner join sui
		on su.i_ufunc = sui.i_ufunc
	inner join sut
		on sui.i_ufunc_impl = sut.i_ufunc_impl
	inner join sth
		on sui.i_txt_impl = sth.i_txt