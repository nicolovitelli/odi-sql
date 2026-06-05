with smr0 as (select * from snp_map_ref with read only)
,sv as (select * from snp_var with read only)
,sm as (select * from snp_mapping with read only)
,smr as (
	select distinct sm.i_mapping as map_no
		,sm.name as map_name
		,sv.i_var as var_no
		,sv.var_name
	from smr0
		inner join sv
			on smr0.ref_guid = sv.global_id
		inner join sm
			on smr0.i_owner_mapping = sm.i_mapping
	order by sm.i_mapping
)
select *
from smr
;