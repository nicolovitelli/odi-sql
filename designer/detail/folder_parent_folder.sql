with sf as (select * from snp_folder with read only)
,src as (
    select
         connect_by_root f.i_folder as fol_no
        ,connect_by_root f.folder_name as fol_name
        ,case 
            when level = 1 then 0
            else f.i_folder
         end as parent_fol_no
        ,case 
            when level = 1 then null
            else f.folder_name
         end as parent_fol_name
    from sf f
    where level > 1
       or f.par_i_folder is null
    start with 1=1
    connect by nocycle prior f.par_i_folder = f.i_folder
    order by fol_no
)
select fol_no
    ,fol_name
    ,parent_fol_no
    ,parent_fol_name
from src
where parent_fol_no <> 0
;