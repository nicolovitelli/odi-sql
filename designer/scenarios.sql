with ss0 as (select * from snp_scen with read only)
,sp as (select * from snp_package with read only)
,sf as (select * from snp_folder with read only)
,ssr0 as (select * from snp_scen_report with read only)
,ssr as (
	select ss0.scen_no
		,max(ssr0.sess_end) as last_completed_execution_ts
		,max(case when ssr0.sess_status = 'E' then ssr0.sess_end end) as last_failed_execution_ts
		,max(case when ssr0.sess_status = 'D' then ssr0.sess_end end) as last_successful_execution_ts
	from ssr0
		inner join ss0
			on ssr0.scen_no = ss0.scen_no
	group by ss0.scen_no
)
,ssr_exec as (
	select ss0.scen_no
		,count(1) as cnt_c
	    ,count(case when ssr0.sess_status = 'D' then 1 end) as cnt_d
	    ,count(case when ssr0.sess_status = 'E' then 1 end) as cnt_e
	from ssr0
		inner join ss0
			on ssr0.scen_no = ss0.scen_no
	group by ss0.scen_no
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
,sprj0 as (select * from snp_project with read only)
,st as (select * from snp_trt with read only)
,sm as (select * from snp_mapping with read only)
,sprj as (
	select ss0.scen_no
		,sprj0.project_name
	from ss0
		left join sp
			on ss0.i_package = sp.i_package
		left join st
			on ss0.i_trt = st.i_trt
		left join sm
			on ss0.i_mapping = sm.i_mapping
		left join sf
			on sp.i_folder = sf.i_folder
			or st.i_folder = sf.i_folder
			or sm.i_folder = sf.i_folder
		left join sprj0
			on sprj0.i_project = sf.i_project
)
,seq_scen0 as (select * from snp_seq_scen with read only)
,sseq0 as (select * from snp_sequence with read only)
,sseq as (
	select sprj0.project_name || '.' || sseq0.seq_name seq_name
	from sseq0
		inner join snp_project sprj0
			on sseq0.i_project = sprj0.i_project
)
,seq_scen as (
	select ss0.scen_no
		,count(1) cnt
	from seq_scen0
		inner join snp_scen ss0
			on seq_scen0.scen_no = ss0.scen_no
		inner join sseq
			on seq_scen0.seq_name = sseq.seq_name
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
		inner join sprj0
			on substr(svs0.var_name, 1, instr(svs0.var_name, '.') - 1) = sprj0.project_name
		inner join sv
			on substr(svs0.var_name, instr(svs0.var_name, '.') + 1) = sv.var_name
			and sprj0.i_project = sv.i_project
	group by ss0.scen_no
)
,step0 as (select * from snp_step with read only)
,sth as (select * from snp_txt_header with read only)
,step as (
	select ss0.scen_no
		,count(1) as cnt
	from step0
		inner join sp
			on step0.i_package = sp.i_package
		inner join ss0
			on sp.i_package = ss0.i_package
		inner join sth
			on step0.i_txt_action = sth.i_txt
		inner join ss0 scen
			on replace(regexp_substr(dbms_lob.substr(sth.full_text, 4000, 1), '-SCEN_NAME=([^ ]+)', 1, 1, null, 1),'"', '') = scen.scen_name
			and replace(regexp_substr(dbms_lob.substr(sth.full_text, 4000, 1), '-SCEN_VERSION=([^ ]+)', 1, 1, null, 1),'"', '') = scen.scen_version
	where step0.step_type = 'SE'
	group by ss0.scen_no
)
,outd as (
	select ss0.scen_no
		,max(
			case when st.i_trt is not null or sm.i_mapping is not null
					or st1.i_trt is not null
				then 'Y'
				else 'N'
			end
		) as is_outdated
	from ss0
		left join sp
			on ss0.i_package = sp.i_package
		left join step0
			on sp.i_package = step0.i_package
		left join st
			on step0.i_trt = st.i_trt
			and st.last_date > ss0.last_date
		left join sm
			on step0.i_mapping = sm.i_mapping
			and sm.last_date > ss0.last_date
		left join st st1
			on ss0.i_trt = st1.i_trt
			and st1.last_date > ss0.last_date
	group by ss0.scen_no
)
,ss as (
	select ss0.scen_no
		,ss0.scen_version
		,ss0.scen_name
		,sp.pack_name as pkg_name
		,coalesce(sf_map.folder_name, sf_prc.folder_name, sf.folder_name) as fol_name
		,sprj.project_name as prj_name
		,outd.is_outdated
		,coalesce(ssr_exec.cnt_c,0) as completed_exec_count
		,coalesce(ssr_exec.cnt_e,0) as failed_exec_count
		,coalesce(sls.cnt,0) as load_plan_count
		,coalesce(step.cnt,0) as pkg_step_count
		,coalesce(seq_scen.cnt,0) as sequence_count
		,coalesce(sss.cnt,0) as step_count
		,coalesce(ssr_exec.cnt_d,0) as successful_exec_count
		,coalesce(sst.cnt,0) as task_count
		,coalesce(svs.cnt,0) as variable_count
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
		,to_char(ssr.last_completed_execution_ts, 'yyyy-mm-dd hh24:mi:ss') as last_completed_execution_ts
		,to_char(ssr.last_successful_execution_ts, 'yyyy-mm-dd hh24:mi:ss') as last_successful_execution_ts
		,to_char(ssr.last_failed_execution_ts, 'yyyy-mm-dd hh24:mi:ss') as last_failed_execution_ts
		,to_char(ss0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(ss0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from ss0
		left join ssr
			on ss0.scen_no = ssr.scen_no
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
		left join sprj
			on ss0.scen_no = sprj.scen_no
		left join step
			on ss0.scen_no = step.scen_no
		left join outd
			on ss0.scen_no = outd.scen_no
		left join st
			on ss0.i_trt = st.i_trt
		left join sf sf_prc
			on st.i_folder = sf_prc.i_folder
		left join sm
			on ss0.i_mapping = sm.i_mapping
		left join sf sf_map
			on sm.i_folder = sf_map.i_folder
)
select *
from ss
order by last_deploy_ts desc
;