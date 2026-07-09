with sm0 as (select * from snp_mapping with read only)
,smr as (select * from snp_map_ref with read only)
,su as (select * from snp_ufunc with read only)
,sui as (select * from snp_ufunc_impl with read only)
,sut as (select * from snp_ufunc_techno with read only)
,sm as (
	select distinct sm0.i_mapping as map_no
		,sm0.name as mapping_name
		,su.i_ufunc as ufunc_no
		,su.ufunc_name as ufunc_name
	from sm0
		inner join smr
			on smr.i_owner_mapping = sm0.i_mapping
		inner join su
			on su.global_id = smr.ref_guid
		left join sui
			on su.i_ufunc = sui.i_ufunc
		inner join sut
			on sui.i_ufunc_impl = sut.i_ufunc_impl
			and sut.tech_int_name = 'ORACLE'
)
select *
from sm
order by map_no
;