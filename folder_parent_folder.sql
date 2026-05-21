/* 
  extracts all parent folders for each folder. 
  connect by is used because a folder can be nested within multiple parent folders.
*/
with sf as (select * from snp_folder with read only)
,src as (
    select
         connect_by_root f.i_folder as fol_no
        ,case 
            when level = 1 then 0
            else f.i_folder
         end as parent_fol_no
    from sf f
    where level > 1
       or f.par_i_folder is null
    start with 1=1
    connect by nocycle prior f.par_i_folder = f.i_folder
    order by fol_no
)
select fol_no
    ,parent_fol_no
from src
where parent_fol_no <> 0
;