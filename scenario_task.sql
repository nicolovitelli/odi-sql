/*
  extracts all tasks to be executed for each scenario.
*/
with sst as (select * from snp_scen_task with read only)
,sl as (select * from snp_lschema with read only)
select sst.scen_no as scen_no
	,sst.nno as task_no
	,sst.scen_task_no as task_order
	,decode(
		sst.task_type
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
		,sst.task_type
	) as task_type
	,sst.task_name1
	,sst.task_name2
	,sst.task_name3
	,sl.i_lschema as tgt_lschema_no
	,sl1.i_lschema as src_lschema_no
	,case
	  when sst.def_txt is null
	    or regexp_like(sst.def_txt, '^[[:space:]]*$')
	  then null
	  else sst.def_txt
	end as tgt_text
	,case when sst.col_txt is null
	    or regexp_like(sst.col_txt, '^[[:space:]]*$')
	  then null
	  else sst.col_txt
	end as src_text
from sst
	left join sl
		on sst.def_lschema_name = sl.lschema_name
	left join sl sl1
		on sst.col_lschema_name = sl1.lschema_name
order by scen_no, task_no, task_order
;