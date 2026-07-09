with st as (select * from snp_trt with read only)
,sue as (select * from snp_user_exit with read only)
,sth as (select * from snp_txt_header with read only)
,src0 as (
    select
        connect_by_root t.i_trt as child_km_no
       	,t.i_trt as parent_km_no
        ,level as lvl
        ,t.trt_name
    from st t
    where trt_type <> 'U'
    start with 1=1
    connect by nocycle prior t.i_base_comp_km = t.i_trt
)
,src as (
	select
	    src0.child_km_no as km_no
	    ,src0.trt_name as km_name
	    ,sue.i_user_exit as prop_no
	    ,sue.ue_name prop_name
	    ,sue.ue_sdesc prop_desc
	   	,case
		  when sth.full_text is null
		    or regexp_like(sth.full_text, '^[[:space:]]*$')
		  then to_clob(decode(sue.short_value, '1', 'True', '0', 'False', sue.short_value))
		  else sth.full_text
		end as prop_default_value
	from src0
		inner join sue
		    on sue.i_trt = src0.parent_km_no
		left join sth
			on sue.i_txt_value = sth.i_txt
)
select *
from src
order by km_no, prop_no
;