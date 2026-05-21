/*
  extracts all load plan executions and their child sessions occurring after a given date.
*/
with slr as (select * from snp_lpi_run with read only)
,sli as (select * from snp_lp_inst with read only)
,slsl as (select * from snp_lpi_step_log with read only)
,ss as (select * from snp_session with read only)
,ssb as (select * from snp_sb with read only)
,scen as (select * from snp_scen with read only)
select
	slr.i_lp_inst as lp_exec_no
	,ss.sess_no as scen_exec_no
from slr
	inner join sli
		on slr.i_lp_inst = sli.i_lp_inst
	inner join slsl
		on slr.i_lp_inst = slsl.i_lp_inst
		and slr.nb_run = slsl.nb_run
	inner join ss
		on slsl.sess_no = ss.sess_no
	inner join ssb
		on ss.sb_no = ssb.sb_no
	inner join scen
		on ssb.scen_no = scen.scen_no
where ss.sess_beg > to_date(:bvDate,'yyyy-mm-dd hh24:mi:ss')
;