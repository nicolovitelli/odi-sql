/*
  extracts all variables used by sessions that occurred after a specified date.
  sessions whose operator log has been deleted from ODI will not be returned.
*/
with function parse_startup_variables(p_clob in clob) 
    return sys.odcivarchar2list is
        v_result sys.odcivarchar2list := sys.odcivarchar2list();
        v_line varchar2(4000);
        v_start integer := 1;
        v_pos integer;
        v_project varchar2(128);
        v_var varchar2(128);
        v_val varchar2(4000);
    begin
        if p_clob is null or dbms_lob.getlength(p_clob) = 0 then
            return v_result;
        end if;
        loop
            v_pos := dbms_lob.instr(p_clob, chr(10), v_start);
            if v_pos = 0 then
                v_line := dbms_lob.substr(p_clob, 4000, v_start);
            else
                v_line := dbms_lob.substr(p_clob, v_pos - v_start, v_start);
            end if;
            v_line := trim(v_line);
            if v_line is not null then
                declare
                    dot_pos integer := instr(v_line, '.');
                    eq_pos integer := instr(v_line, '=');
                begin
                    if dot_pos > 0 and eq_pos > dot_pos then
                        v_project := trim(substr(v_line, 1, dot_pos - 1));
                        v_var := trim(substr(v_line, dot_pos + 1, eq_pos - dot_pos - 1));
                        v_val := trim(substr(v_line, eq_pos + 1));
                        v_val := trim(both '''' from v_val);
                        v_result.extend;
                        v_result(v_result.last) := v_project || '|' || v_var || '|' || v_val;
                    end if;
                end;
            end if;
            exit when v_pos = 0;
            v_start := v_pos + 1;
        end loop;
        return v_result;
    end parse_startup_variables;
    slr as (select * from snp_lpi_run with read only)
    ,sli as (select * from snp_lp_inst with read only)
    ,slsl as (select * from snp_lpi_step_log with read only)
    ,ss as (select * from snp_session with read only)
    ,ssb as (select * from snp_sb with read only)
    ,scen as (select * from snp_scen with read only)
select 
    ss.sess_no as scen_exec_no
    ,regexp_substr(t.column_value, '[^|]+', 1, 2) as var_name
    ,regexp_substr(t.column_value, '[^|]+', 1, 3) as var_value
from slr
    inner join sli  
            on slr.i_lp_inst = sli.i_lp_inst
    inner join slsl 
            on slr.i_lp_inst = slsl.i_lp_inst 
           and slr.nb_run = slsl.nb_run
    inner join ss   
            on slsl.sess_no = ss.sess_no
    inner join ssb  
            on ss.sb_no = ssb.sb_no
    inner join scen 
            on ssb.scen_no = scen.scen_no
    cross apply table(parse_startup_variables(ss.startup_variables)) t
where ss.sess_beg > to_date(:bvdate, 'yyyy-mm-dd hh24:mi:ss')
;