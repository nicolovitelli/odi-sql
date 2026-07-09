with sv0 as (select * from snp_var with read only)
,stc as (select * from snp_txt_crossr with read only)
,slt as (select * from snp_line_trt with read only)
,st as (select * from snp_trt with read only)
,sf as (select * from snp_folder with read only)
,sv as (
	select sv0.i_var as var_no
		,sv0.var_name
		,coalesce(slts.sql_name, sltt.sql_name) as prc_step_name
		,coalesce(sts.i_trt, stt.i_trt) as prc_no
		,coalesce(sts.trt_name, stt.trt_name) as prc_name
		,coalesce(sfs.folder_name, sft.folder_name) as fol_name
		,case when slts.i_trt is not null
			then 'Source Command'
			else
				case when sltt.i_trt is not null
					then 'Target Command'
					else 'Unknown'
				end
		end as used_in
	from sv0
		inner join stc
			on sv0.i_var = stc.i_var
		left join slt slts
			on stc.i_txt = slts.col_i_txt
		left join st sts
			on slts.i_trt = sts.i_trt
			and sts.trt_type = 'U'
		left join sf sfs
			on sts.i_folder = sfs.i_folder
		left join slt sltt
			on stc.i_txt = sltt.def_i_txt
		left join st stt
			on sltt.i_trt = stt.i_trt
			and stt.trt_type = 'U'
		left join sf sft
			on stt.i_folder = sft.i_folder
	where 1=1
		and stc.object_type = 'V'
)
select *
from sv
order by prc_no
;