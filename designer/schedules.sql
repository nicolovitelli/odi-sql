with spa0 as (select * from snp_plan_agent with read only)
,spa as (
	select spa0.i_plan_agent as schedule_no
		,spa0.scen_name as object_name
		,decode(spa0.ind_job_type
			,'S'
			,'Scenario'
			,'L'
			,'Load Plan'
			,spa0.ind_job_type
		) as object_type
		,decode(spa0.stat_plan
			,'E'
			,'Active'
			,'D'
			,'Inactive'
			,'I'
			,'Active for an interval'
			,spa0.stat_plan
		) as schedule_status
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
			,'Monthly (Week day)'
			,'H'
			,'Hourly'
			,'M'
			,'Monthly (day of the month)'
			,'S'
			,'Simple'
			,spa0.s_type
		) as schedule_type
		,spa0.s_year || '-'
			|| case when length(spa0.s_month) = 1
					then concat('0', spa0.s_month)
					else spa0.s_month
				end || '-'
			|| case when length(spa0.s_day) = 1
					then concat('0', spa0.s_day)
					else spa0.s_day
				end
		as first_execution_dt
		,spa0.s_month_day as scheduled_day_of_month
		,decode(spa0.s_week_day 
			,'1'
			,'Sunday'
			,'2'
			,'Monday'
			,'3'
			,'Tuesday'
			,'4'
			,'Wednesday'
			,'5'
			,'Thursday'
			,'6'
			,'Friday'
			,'7'
			,'Saturday'
		) as scheduled_day_of_week
		,case when length(spa0.s_hour) = 1
			then concat('0', spa0.s_hour)
			else spa0.s_hour
		end || ':' ||
		case when length(spa0.s_minute) = 1
			then concat('0', spa0.s_minute)
			else spa0.s_minute
		end || ':' ||
		case when length(spa0.s_second) = 1
			then concat('0', spa0.s_second)
			else spa0.s_second
		end as scheduled_time
		,spa0.r_time as times_to_repeat
		,spa0.r_dur_interval || case when spa0.r_dur_interval is not null then ' ' end || decode(spa0.r_interval_unit
			,'S'
			,'Second(s)'
			,'M'
			,'Minute(s)'
			,'H'
			,'Hour(s)'
			,spa0.r_interval_unit
		) as time_between_runs
		,spa0.r_dur_cycle as duration_repeated_cycle
		,spa0.r_deadline as max_duration
		,spa0.r_time_error as num_of_retries_on_err
		,spa0.lagent_name
		,spa0.context_code
		,to_char(spa0.first_date, 'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(spa0.last_date, 'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from spa0
)
select *
from spa
order by schedule_status, last_deploy_ts desc
;