with ss0 as (select * from snp_scen with read only)
,sp as (select * from snp_package with read only)
,sf as (select * from snp_folder with read only)
,sprj as (select * from snp_project with read only)
,ssr0 as (select * from snp_scen_report with read only)
,ssr as (
	select ss0.scen_no
		,ssr0.sess_end
		,row_number() over (partition by ss0.scen_no order by ssr0.sess_end desc) rn
	from ss0
		inner join ssr0
			on ss0.scen_no = ssr0.scen_no
)
,ssr_failed as (
	select ss0.scen_no
		,ssr0.sess_end
		,row_number() over (partition by ss0.scen_no order by ssr0.sess_end desc) rn
	from ss0
		inner join ssr0
			on ss0.scen_no = ssr0.scen_no
	where ssr0.sess_status = 'E'
)
,ssr_exec as (
	select ssr0.scen_no
	    ,count(case when ssr0.sess_status = 'D' then 1 end) as cnt_d
	    ,count(case when ssr0.sess_status = 'E' then 1 end) as cnt_e
	from ssr0
	group by ssr0.scen_no
)
,ssr_avg as (
	select ss0.scen_no
		,round(avg(ssr0.sess_dur)) as avg_dur_sec
	from ssr0
		inner join ss0
			on ssr0.scen_no = ss0.scen_no
	where ssr0.sess_status = 'D'
	group by ss0.scen_no
)
,ssr_dur as (
	select ss0.scen_no
		,max(ssr0.sess_dur) as max_sess_dur
		,min(ssr0.sess_dur) as min_sess_dur
	from ssr0
		inner join ss0
			on ssr0.scen_no = ss0.scen_no
	group by ss0.scen_no
)
,sss0 as (select * from snp_scen_step with read only)
,sss as (
	select ss0.scen_no
		,count(1) as cnt
	from sss0
		inner join ss0
			on sss0.scen_no = ss0.scen_no
	group by ss0.scen_no
)
,sls0 as (select * from snp_lp_step with read only)
,sls as (
	select ss0.scen_no, count(1) as cnt
	from sls0
		inner join ss0
			on sls0.scen_name = ss0.scen_name
			and sls0.scen_version = ss0.scen_version
	group by ss0.scen_no
)
,sst0 as (select * from snp_scen_task with read only)
,sst as (
	select ss0.scen_no
		,count(1) as cnt
	from sst0
		inner join ss0
			on sst0.scen_no = ss0.scen_no
	group by ss0.scen_no
)
,seq_scen0 as (select * from snp_seq_scen with read only)
,sseq as (select * from snp_sequence with read only)
,seq_scen as (
	select ss0.scen_no
		,count(1) cnt
	from seq_scen0
		inner join ss0
			on seq_scen0.scen_no = ss0.scen_no
		inner join sprj
			on substr(seq_scen0.seq_name, 1, instr(seq_scen0.seq_name, '.') - 1) = sprj.project_name
		inner join sseq
			on substr(seq_scen0.seq_name, instr(seq_scen0.seq_name, '.') + 1) = sseq.seq_name
			and sprj.i_project = sseq.i_project
	group by ss0.scen_no
)
,svs0 as (select * from snp_var_scen with read only)
,sv as (select * from snp_var with read only)
,svs as (
	select ss0.scen_no
		,count(1) as cnt
	from svs0
		inner join ss0
			on svs0.scen_no = ss0.scen_no
		inner join sprj
			on substr(svs0.var_name, 1, instr(svs0.var_name, '.') - 1) = sprj.project_name
		inner join sv
			on substr(svs0.var_name, instr(svs0.var_name, '.') + 1) = sv.var_name
			and sprj.i_project = sv.i_project
	group by ss0.scen_no
)
,ss as (
	select ss0.scen_no
		,ss0.scen_version
		,ss0.scen_name
		,sp.pack_name as pkg_name
		,sf.folder_name as fol_name
		,case when sls.scen_no is not null
			then 'Y'
			else 'N'
		end as is_used_by_load_plan
		,coalesce(sss.cnt,0) as number_of_steps
		,coalesce(sst.cnt,0) as number_of_tasks
		,coalesce(seq_scen.cnt,0) as number_of_sequences
		,coalesce(svs.cnt,0) as number_of_variables
		,coalesce(ssr_exec.cnt_d,0) as completed_executions
		,coalesce(ssr_exec.cnt_e,0) as failed_executions
		,case when ssr_avg.avg_dur_sec is not null
			then 
				lpad(floor(ssr_avg.avg_dur_sec / 3600), 2, '0') || ':' ||
			    lpad(floor(mod(ssr_avg.avg_dur_sec, 3600) / 60), 2, '0') || ':' ||
			    lpad(mod(ssr_avg.avg_dur_sec, 60), 2, '0')
			else '-1'
		end as avg_duration
		,case when ssr_dur.max_sess_dur is not null
			then 
				lpad(floor(ssr_dur.max_sess_dur / 3600), 2, '0') || ':' ||
			    lpad(floor(mod(ssr_dur.max_sess_dur, 3600) / 60), 2, '0') || ':' ||
			    lpad(mod(ssr_dur.max_sess_dur, 60), 2, '0')
			else '-1'
		end as longest_duration
		,case when ssr_dur.min_sess_dur is not null
			then 
				lpad(floor(ssr_dur.min_sess_dur / 3600), 2, '0') || ':' ||
			    lpad(floor(mod(ssr_dur.min_sess_dur, 3600) / 60), 2, '0') || ':' ||
			    lpad(mod(ssr_dur.min_sess_dur, 60), 2, '0')
			else '-1'
		end as shortest_duration
		,to_char(ssr.sess_end,'yyyy-mm-dd hh24:mi:ss') as last_execution_ts
		,to_char(ssr_failed.sess_end,'yyyy-mm-dd hh24:mi:ss') as last_failed_ts
		,to_char(ss0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(ss0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from ss0
		left join ssr
			on ss0.scen_no = ssr.scen_no
			and ssr.rn = 1
		left join ssr_failed
			on ss0.scen_no = ssr_failed.scen_no
			and ssr_failed.rn = 1
		left join sss
			on ss0.scen_no = sss.scen_no
		left join ssr_exec
			on ss0.scen_no = ssr_exec.scen_no
		left join ssr_avg
			on ss0.scen_no = ssr_avg.scen_no
		left join sp
			on ss0.i_package = sp.i_package
		left join sf
			on sp.i_folder = sf.i_folder
		left join sls
			on ss0.scen_no = sls.scen_no
		left join sst
			on ss0.scen_no = sst.scen_no
		left join seq_scen
			on ss0.scen_no = seq_scen.scen_no
		left join svs
			on ss0.scen_no = svs.scen_no
		left join ssr_dur
			on ss0.scen_no = ssr_dur.scen_no
)
select *
from ss
order by last_deploy_ts desc
;