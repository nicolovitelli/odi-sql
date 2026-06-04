with slp0 as (select * from snp_load_plan with read only)
,slr0 as (select * from snp_lpi_run with read only)
,sli as (select * from snp_lp_inst with read only)
,sls0 as (select * from snp_lp_step with read only)
,sls as (
	select distinct sls0.i_load_plan
	from sls0
	where sls0.lp_step_name <> 'root_step'
)
,sls1 as (
	select distinct s.i_load_plan
	from sls0 s
	where not exists (
	    select 1
	    from sls0
	    where sls0.i_load_plan = s.i_load_plan
	      and sls0.lp_step_type = 'RS'
	)
)
,sls2 as (
	select sls0.i_load_plan
		,count(sls0.i_lp_step) cnt
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
)
,slrf as (
	select sli.i_load_plan
		,slr0.end_date
		,row_number() over (partition by sli.i_load_plan order by slr0.end_date desc) as rn
	from slr0
		inner join sli
			on slr0.i_lp_inst = sli.i_lp_inst
	where slr0.status = 'E'
)
,lp_avg as (
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
		,case when sls.i_load_plan is not null
			then 'N'
			else 'Y'
		end as is_empty
		,case when sls1.i_load_plan is not null
			then 'N'
			else 'Y'
		end as has_scenario_step
		,sls2.cnt as number_of_steps
		,case when lp_avg.avg_dur_sec is not null
			then 
				lpad(floor(lp_avg.avg_dur_sec / 3600), 2, '0') || ':' ||
			    lpad(floor(mod(lp_avg.avg_dur_sec, 3600) / 60), 2, '0') || ':' ||
			    lpad(mod(lp_avg.avg_dur_sec, 60), 2, '0')
			else '-1'
		end as avg_duration
		,to_char(slr.end_date,'yyyy-mm-dd hh24:mi:ss') as last_execution_ts
		,to_char(slrf.end_date,'yyyy-mm-dd hh24:mi:ss') as last_failed_ts
		,to_char(slp0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(slp0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from slp0
		left join slr
			on slp0.i_load_plan = slr.i_load_plan
			and slr.rn = 1
		left join slrf
			on slp0.i_load_plan = slrf.i_load_plan
			and slrf.rn = 1
		left join lp_avg
			on slp0.i_load_plan = lp_avg.i_load_plan
		left join sls
			on slp0.i_load_plan = sls.i_load_plan
		left join sls1
			on slp0.i_load_plan = sls1.i_load_plan
		left join sls2
			on slp0.i_load_plan = sls2.i_load_plan
)
select *
from slp
order by last_deploy_ts desc
;