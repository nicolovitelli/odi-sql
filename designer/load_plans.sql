with slp0 as (select * from snp_load_plan with read only)
,sls0 as (select * from snp_lp_step with read only)
,slr0 as (select * from snp_lpi_run with read only)
,sli as (select * from snp_lp_inst with read only)
,sls_step as (
	select sls0.i_load_plan
		,count(sls0.i_lp_step) cnt
		,count(case when sls0.lp_step_type = 'RS' then 1 end) as cnt_scen
	from sls0
	group by sls0.i_load_plan
)
,slr as (
	select sli.i_load_plan
		,slr0.end_date
		,row_number() over (partition by sli.i_load_plan order by slr0.end_date desc) as rn
	from slr0
		inner join sli
			on slr0.i_lp_inst = sli.i_lp_inst
	where slr0.status = 'D'
)
,slr_failed as (
	select sli.i_load_plan
		,slr0.end_date
		,row_number() over (partition by sli.i_load_plan order by slr0.end_date desc) as rn
	from slr0
		inner join sli
			on slr0.i_lp_inst = sli.i_lp_inst
	where slr0.status = 'E'
)
,slr_avg as (
	select sli.i_load_plan
		,round(avg(slr0.duration)) as avg_dur_sec
	from slr0
		inner join sli
			on slr0.i_lp_inst = sli.i_lp_inst
	where slr0.status = 'D'
	group by sli.i_load_plan
)
,slp as (
	select slp0.i_load_plan as lp_no
		,slp0.load_plan_name as lp_name
		,coalesce(sls_step.cnt,0) as step_count
		,coalesce(sls_step.cnt_scen,0) as scenario_step_count
		,case when slr_avg.avg_dur_sec is not null
			then 
				lpad(floor(slr_avg.avg_dur_sec / 3600), 2, '0') || ':' ||
			    lpad(floor(mod(slr_avg.avg_dur_sec, 3600) / 60), 2, '0') || ':' ||
			    lpad(mod(slr_avg.avg_dur_sec, 60), 2, '0')
			else '-1'
		end as avg_duration
		,to_char(slr.end_date,'yyyy-mm-dd hh24:mi:ss') as last_successful_execution_ts
		,to_char(slr_failed.end_date,'yyyy-mm-dd hh24:mi:ss') as last_failed_execution_ts
		,to_char(slp0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(slp0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from slp0
		left join slr
			on slp0.i_load_plan = slr.i_load_plan
			and slr.rn = 1
		left join slr_failed
			on slp0.i_load_plan = slr_failed.i_load_plan
			and slr_failed.rn = 1
		left join slr_avg
			on slp0.i_load_plan = slr_avg.i_load_plan
		left join sls_step
			on slp0.i_load_plan = sls_step.i_load_plan
)
select *
from slp
order by last_deploy_ts desc
;