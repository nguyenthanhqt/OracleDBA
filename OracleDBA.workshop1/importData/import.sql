--FILE_NAME_CONVERT
SQL> ! mkdir -p /u01/app/oracle/oradata/ORCLCDB/hddtNew
--
CREATE PLUGGABLE DATABASE pdb_hddt
ADMIN USER ADMIN IDENTIFIED BY oracle
ROLES=(DBA)
DEFAULT TABLESPACE users 
DATAFILE '/u01/app/oracle/oradata/ORCLCDB/hddtNew/user01.dbf'
SIZE 250M AUTOEXTEND ON
FILE_NAME_CONVERT = ('/u01/app/oracle/oradata/ORCLCDB/pdbseed/', 
                     '/u01/app/oracle/oradata/ORCLCDB/hddtNew/');


alter pluggable database pdb_hddt open;

sqlplus sys/oracle@localhost:1521/pdb_hddt as sysdba

create directory hddtNew as '/u01/app/oracle/oradata/ORCLCDB/hddtNew/';
SELECT owner, directory_name, directory_path  FROM all_directories

create tablespace DATA datafile '/u01/app/oracle/oradata/ORCLCDB/hddtNew/hddtData01.dbf' size 10M autoextend on next 1m maxsize unlimited;

create user hddt identified by hddt;
grant connect,resource,unlimited tablespace to hddt;
alter user hddt default tablespace tbs_hddtNew;

sqlplus sys/oracle@localhost:1521/pdb_hddt as sysdba

impdp system/oracle@localhost:1521/pdb_hddt DIRECTORY=hddtNew DUMPFILE=backup_dump_hddt_2024-01-20.dmp schemas=INVOICE_TT78_STANDARD LOGFILE=empimport.log

impdp \" / as sysdba \" directory=invoicedb 

impdp \" oracle/oracle as sysdba \" directory=invoicedb schemas=INVOICE_TT78_STANDARD dumpfile=backup_dump_hddt_2024-01-20.dmp logfile=restore.log 
impdp \" INVOICE_TT78_STANDARD/INVOICE_TT78_STANDARD as sysdba \" directory=invoicedb schemas=INVOICE_TT78_STANDARD dumpfile=invoice20240123.dmp logfile=restore20240123.log 

impdp \" as sysdba \" directory=invoicedb schemas=INVOICE_TT78_STANDARD dumpfile=invoice20240123.dmp logfile=restore20240123.log 

impdp \" as sysdba \" directory=invoicedb schemas=INVOICE_TT78_STANDARD dumpfile=backup_dump_hddt_2024-01-20.dmp logfile=restore.log 

impdp "'/ as sysdba'" directory=invoicedb dumpfile=backup_dump_hddt_2024-01-20.dmp logfile=restore.log  schemas=INVOICE_TT78_STANDARD
