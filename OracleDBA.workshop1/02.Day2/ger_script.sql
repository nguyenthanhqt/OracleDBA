set serveroutput on 
set trimspool on
set line 500
set head off
set feed off

spool /home/oracle/script.sql
select 'alter index '||index_name||' rebuild;' from user_indexes;
Select 'exit' from dual; 
spool off
set head on
set feed on
set serveroutput off
exit
