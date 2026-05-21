/*
  extracts all scenarios executed after a given date.
  sessions can appear here even if the operator log was deleted from ODI.
*/
with ssr as (select * from snp_scen_report with read only)
,ss as (select * from snp_scen with read only)
select
	ssr.scen_run_no as scen_exec_no
	,ssr.scen_no
	,ss.scen_name
	,to_char(ssr.sess_beg,'yyyy-mm-dd hh24:mi:ss') as start_ts
	,to_char(ssr.sess_end,'yyyy-mm-dd hh24:mi:ss') as end_ts
	,ssr.sess_dur as duration_sec
	,ssr.nb_row as processed_rows
	,ssr.nb_ins as inserted_rows
	,ssr.nb_upd as updated_rows
	,ssr.sess_status as status
	,ssr.error_message as error_msg
from ssr
	inner join ss
		on ssr.scen_no = ss.scen_no
where ssr.sess_beg > to_date(:bvDate,'yyyy-mm-dd hh24:mi:ss')
;