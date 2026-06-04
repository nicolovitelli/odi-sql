with sst0 as (select * from snp_scen_task with read only)
,sl as (select * from snp_lschema with read only)
,sst as (
	select sst0.scen_no as scen_no
		,sst0.nno as task_no
		,sst0.scen_task_no as task_order
		,decode(
			sst0.task_type
			,'S'
			,'Procedure'
			,'J'
			,'Mapping'
			,'V'
			,'Variable'
			,'C'
			,'Loading'
			,'L'
			,'Loading'
			,sst0.task_type
		) as task_type
		,sst0.task_name1
		,sst0.task_name2
		,sst0.task_name3
		,sl.i_lschema as tgt_lschema_no
		,sl1.i_lschema as src_lschema_no
		,case
		  when sst0.def_txt is null
		    or regexp_like(sst0.def_txt, '^[[:space:]]*$')
		  then null
		  else sst0.def_txt
		end as tgt_text
		,case when sst.col_txt is null
		    or regexp_like(sst0.col_txt, '^[[:space:]]*$')
		  then null
		  else sst0.col_txt
		end as src_text
	from sst0
		left join sl
			on sst0.def_lschema_name = sl.lschema_name
		left join sl sl1
			on sst0.col_lschema_name = sl1.lschema_name
	order by sst0.scen_no, sst0.task_no, sst0.task_order
)
select *
from sst
;