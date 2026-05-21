/*
  extracts all properties used by each knowledge module.
  connect by is necessary because most knowledge modules inherit properties from their parent knowledge modules.
*/
with st as (select * from snp_trt with read only)
,sue as (select * from snp_user_exit with read only)
,sth as (select * from snp_txt_header with read only)
,src as (
    select
        connect_by_root t.i_trt as child_km_no,
        t.i_trt                 as parent_km_no,
        level                   as lvl
    from st t
    start with 1=1
    connect by nocycle prior t.i_base_comp_km = t.i_trt
)
select
    sue.i_user_exit as prop_no,
    src.child_km_no as km_no,
    sue.ue_name prop_name,
    sue.ue_sdesc prop_desc,
   	case
	  when sth.full_text is null
	    or regexp_like(sth.full_text, '^[[:space:]]*$')
	  then to_clob(
	         coalesce(
	           decode(sue.short_value, '1', 'True', '0', 'False', sue.short_value),
	           'Unspecified'
	         )
	       )
	  else sth.full_text
	end as prop_default_value
from src
	inner join sue
	    on sue.i_trt = src.parent_km_no
	left join sth
		on sue.i_txt_value = sth.i_txt
order by
    sue.i_user_exit, src.child_km_no
;