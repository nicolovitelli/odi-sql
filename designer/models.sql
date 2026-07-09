with sm0 as (select * from snp_model with read only)
,ssm0 as (select * from snp_sub_model with read only)
,st0 as (select * from snp_table with read only)
,ssm as (
	select sm0.i_mod
		,count(1) as cnt
	from ssm0
		inner join sm0
			on ssm0.i_mod = sm0.i_mod
	group by sm0.i_mod
)
,st as (
	select sm0.i_mod
		,count(1) as cnt
	from st0
		inner join sm0
			on st0.i_mod = sm0.i_mod
	group by sm0.i_mod
)
,split_obj_types as (
	select 
		i_mod,
		regexp_substr(rev_obj_type, '[^;]+', 1, level) as single_value,
		level as val_order
	from sm0
	where rev_obj_type is not null
	connect by regexp_substr(rev_obj_type, '[^;]+', 1, level) is not null
		and prior i_mod = i_mod
		and prior sys_guid() is not null
)
,mapped_obj_types as (
	select 
		i_mod,
		listagg(
			case single_value
				when 'T'  then 'Tables'
				when 'V'  then 'Views'
				when 'Q'  then 'Queues'
				when 'SY' then 'Synonyms'
				when 'ST' then 'System Tables'
				when 'AT' then 'Alias Tables'
				else single_value
			end, chr(10)
		) within group (order by val_order) as decoded_rev_obj_type
	from split_obj_types
	group by i_mod
)
,sm as (
select sm0.i_mod as mod_no
	,sm0.mod_name
	,sm0.tech_int_name as tech_name
	,sm0.lschema_name
	,coalesce(ssm.cnt,0) as sub_model_count
	,coalesce(st.cnt,0) as datastore_count
	,sm0.rev_context as rev_eng_context
	,sm0.rev_obj_patt as rev_eng_mask
	,sm0.rev_alias_ltrim as rev_eng_remove_from_talias
	,sm0.alias_length as rev_eng_talias_length
	,m_obj.decoded_rev_obj_type as rev_eng_obj_type
	,decode(sm0.rev_update
		,1
		,'Y'
		,0
		,'N'
		,sm0.rev_update
	) as update_existing_datastores
	,decode(sm0.rev_insert
		,1
		,'Y'
		,0
		,'N'
		,sm0.rev_insert
	) as insert_new_datastores
	,to_char(sm0.first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
	,to_char(sm0.last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
from sm0
	left join ssm
		on sm0.i_mod = ssm.i_mod
	left join st
		on sm0.i_mod = st.i_mod
	left join mapped_obj_types m_obj
		on sm0.i_mod = m_obj.i_mod
)
select *
from sm
order by last_deploy_ts desc
;