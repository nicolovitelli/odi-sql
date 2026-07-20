with ssr00 as (select * from snp_scen_report with read only)
,ssr0 as (
	select dbms_lob.substr(
			case when length(regexp_substr(ssr00.error_message, 'PLS-[^' || chr(10) || chr(13) || ']+')) = 0
		        	then regexp_substr(ssr00.error_message, 'ORA-[^' || chr(10) || chr(13) || ']+')
		        	else regexp_substr(ssr00.error_message, 'PLS-[^' || chr(10) || chr(13) || ']+')
		    end
		,4000
		,1
		) as error_msg
		,ssr00.sess_end
	from ssr00
	where 1=1
		and (dbms_lob.instr(ssr00.error_message, 'ORA-') > 0
		or dbms_lob.instr(ssr00.error_message, 'PLS-') > 0)
)
,ssr as (
	select ssr0.error_msg
		,count(1) error_cnt
		,to_char(max(ssr0.sess_end), 'yyyy-mm-dd hh24:mi:ss') as last_occurrence_ts
	from ssr0
	group by error_msg
)
select *
from ssr
order by error_cnt desc, last_occurrence_ts desc
;