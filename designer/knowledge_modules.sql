with st0 as (select * from snp_trt with read only)
,sp as (select * from snp_project with read only)
,st as (
	select
		st0.i_trt as km_no
		,st0.trt_name as km_name
		,decode(st0.trt_type
			,'KJ'
			,'Journalizing Knowledge Module'
			,'KL'
			,'Loading Knowledge Module'
			,'KI'
			,'Integration Knowledge Module'
			,'KS'
			,'Service KM'
			,'KR'
			,'Reverse-engineering Knowledge Module'
			,'KC'
			,'Check Knowledge Module'
			,st0.trt_type
		) as km_type
		,sp.project_name as project_name
		,to_char(st0.first_date,'yyyy-mm-dd hh24:mi:ss') as first_deploy_ts
		,to_char(st0.last_date,'yyyy-mm-dd hh24:mi:ss') as last_deploy_ts
	from st0
		left join sp
			on st0.i_project = sp.i_project
	where st0.trt_type <> 'U'
)
select *
from st
order by last_deploy_ts desc
;