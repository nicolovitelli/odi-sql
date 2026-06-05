with spa0 as (select * from snp_plan_agent with read only)
,spa as (
	select spa0.i_plan_agent as plan_agent_no
		,spa0.scen_name as obj_name
		,decode(spa0.ind_job_type
			,'S'
			,'Scenario'
			,'L'
			,'Load Plan'
			,spa0.ind_job_type
		) as obj_type
		,spa0.lagent_name
		,spa0.context_code
		,decode(spa0.stat_plan
			,'E'
			,'Active'
			,'D'
			,'Inactive'
			,'I'
			,'Active for an Interval'
			,spa0.stat_plan
		) as status
		,decode(spa0.s_type
			,'W'
			,'Weekly'
			,'D'
			,'Daily'
			,'O'
			,'On Agent Startup'
			,'Y'
			,'Yearly'
			,'N'
			,'Monthly (Week Day)'
			,'H'
			,'Hourly'
			,'M'
			,'Monthly (Day of Month)'
			,'S'
			,'Simple'
			,spa0.s_type
		) as schedule_type
		,spa0.s_month_day as execution_day_of_month
		,case trim(spa0.s_week_day)
		    when '1' then 'Monday'
		    when '2' then 'Tuesday'
		    when '3' then 'Wednesday'
		    when '4' then 'Thursday'
		    when '5' then 'Friday'
		    when '6' then 'Saturday'
		    when '7' then 'Sunday'
		    else spa0.s_week_day
		 end as execution_day_of_week
		 ,spa0.r_dur_interval time_between_runs
		 ,decode(spa0.r_interval_unit 
		 	,'S'
		 	,'Seconds'
		 	,'M'
		 	,'Minutes'
		 	,'H'
		 	,'Hours'
		 	,'D'
		 	,'Days'
		 	,spa0.r_interval_unit 
		 ) as time_between_runs_unit
		
		,to_char(spa0.s_year) || '-' || to_char(spa0.s_month) || '-' || to_char(spa0.s_day)
			|| ' ' || to_char(spa0.s_hour) || ':' || to_char(spa0.s_minute) || ':' || to_char(spa0.s_second) as first_execution_ts
		,to_char(spa0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(spa0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from spa0
)
select *
from spa
order by status, obj_type
;