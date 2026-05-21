/*
  extracts all mappings available in ODI.
  also shows several properties set in the physical layer:
    - cleanup_on_error => Remove Temporary Objects on Error
    - is_concurrent    => Use Unique Temporary Object Names
    - is_frozen        => Is Frozen
*/
with sm as (select * from snp_mapping with read only)
,sdc as (select * from snp_deploy_spec with read only)
select
	sm.i_mapping map_no
	,sm.name as mapping_name
	,sm.i_folder as fol_no
	,sm.is_reusable
	,decode(sdc.cleanup_on_error,1,'True',0,'False',sdc.cleanup_on_error) as cleanup_on_error
	,decode(sdc.is_concurrent,1,'True',0,'False',sdc.cleanup_on_error) as is_concurrent
	,decode(sdc.is_frozen,1,'True',0,'False',sdc.cleanup_on_error) as is_frozen
	,to_char(sm.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sm.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from sm
	left join sdc
		on sm.i_mapping = sdc.i_owner_mapping
;