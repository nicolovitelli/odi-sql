/*
  extracts mappings along with the user functions they use.
  mappings without any user functions are excluded.
  only user functions implemented for ORACLE technology are included.
*/
with su as (select * from snp_ufunc with read only)
,smr as (select * from snp_map_ref with read only)
,sm as (select * from snp_mapping with read only)
,sui as (select * from snp_ufunc_impl with read only)
,sut as (select * from snp_ufunc_techno with read only)
select sm.i_mapping as map_no
	,su.i_ufunc as ufunc_no
from su
	inner join smr
		on su.global_id = smr.ref_guid
	inner join sm
		on smr.i_owner_mapping = sm.i_mapping
	left join sui
		on su.i_ufunc = sui.i_ufunc
	inner join sut
		on sui.i_ufunc_impl = sut.i_ufunc_impl
		and sut.tech_int_name = 'ORACLE'
;