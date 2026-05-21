/*
  extracts mappings along with the variables they use.
  mappings without any variables are excluded.
  the distinct keyword is used to remove duplicate entries of the same variable 
  	when it appears multiple times within the same mapping.
*/
with smr as (select * from snp_map_ref with read only)
,sv as (select * from snp_var with read only)
,sm as (select * from snp_mapping with read only)
select distinct sm.i_mapping as map_no
	,sv.i_var as var_no
from smr
	inner join sv
		on smr.ref_guid = sv.global_id
	inner join sm
		on smr.i_owner_mapping = sm.i_mapping
;