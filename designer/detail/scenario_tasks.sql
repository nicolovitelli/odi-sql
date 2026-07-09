with sst0 as (select * from snp_scen_task with read only)
,ss as (select * from snp_scen with read only)
,sst as (
	select sst0.scen_no as scen_no
		,ss.scen_name
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
		,sst0.def_lschema_name as tgt_lschema_name
		,sst0.col_lschema_name as src_lschema_name
		,case
		  when sst0.def_txt is null
		    or regexp_like(sst0.def_txt, '^[[:space:]]*$')
		  then null
		  else sst0.def_txt
		end as tgt_text
		,case when sst0.col_txt is null
		    or regexp_like(sst0.col_txt, '^[[:space:]]*$')
		  then null
		  else sst0.col_txt
		end as src_text
	from sst0
		inner join ss
			on sst0.scen_no = ss.scen_no
	order by sst0.scen_no, sst0.nno, sst0.scen_task_no
)
select *
from sst
;