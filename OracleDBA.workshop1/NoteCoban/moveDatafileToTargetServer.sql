#1. coppy toan data lên server cần restore;
#2.Thiết lập môi trường
    cat /etc/oratab
    echo 'CDB:/u01/app/oracle/product/19.0.0/dbhome_1:N' >> /etc/oratab 
#3. tao file spfile
echo "CDB:/u01/app/oracle/product/19.0.0/dbhome_1:N" >>/etc/oratab

create pfile='/home/oracle/CDB/pfile.txt' from spfile='/home/oracle/CDB/spfileCDB.ora'; 

mkdir -p /u01/app/oracle/admin/CDB/adump

SQL> ! cat /home/oracle/CDB/pfile.txt
CDB.__data_transfer_cache_size=0
CDB.__db_cache_size=734003200
CDB.__inmemory_ext_roarea=0
CDB.__inmemory_ext_rwarea=0
CDB.__java_pool_size=0
CDB.__large_pool_size=4194304
CDB.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
CDB.__pga_aggregate_target=209715200
CDB.__sga_target=1073741824
CDB.__shared_io_pool_size=50331648
CDB.__shared_pool_size=272629760
CDB.__streams_pool_size=0
CDB.__unified_pga_pool_size=0
*.audit_file_dest='/u01/app/oracle/admin/CDB/adump'
*.audit_trail='db'
*.compatible='19.0.0'
*.control_files='/home/oracle/CDB/control01.ctl'
*.db_block_size=8192
*.db_name='CDB'
*.db_recovery_file_dest='/home/oracle/fast_recovery_area'
*.db_recovery_file_dest_size=12732m
*.diagnostic_dest='/u01/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=CDBXDB)'
*.enable_pluggable_database=true
*.local_listener='(ADDRESS=(PROTOCOL=tcp)(HOST=oraclesv02)(PORT=1521))'
*.nls_language='AMERICAN'
*.nls_territory='AMERICA'
*.open_cursors=300
*.pga_aggregate_target=200m
*.processes=300
*.remote_login_passwordfile='EXCLUSIVE'
*.sga_target=1024m
*.undo_tablespace='UNDOTBS1'

 ! vi /home/oracle/CDB/pfile.txt

 # tao cac thu muc
 mkdir -p /home/oracle/fast_recovery_area
 mkdir -p /home/oracle/fast_recovery_area

 #4. tao spfile tu pfile
 create spfile from pfile ='/home/oracle/CDB/pfile.txt';

#5. start database
startup nomount;
show parameter control;
alter databaser mount;

#Cap nhat lai duong dan file
select name from v$datafile;
select member from v$logfile;

alter database rename file '/u01/app/oracle/oradata/CDB/system01.dbf' to '/home/oracle/CDB/system01.dbf';
alter database rename file '/u01/app/oracle/oradata/CDB/sysaux01.dbf' to '/home/oracle/CDB/sysaux01.dbf';
alter database rename file '/u01/app/oracle/oradata/CDB/undotbs01.dbf' to '/home/oracle/CDB/undotbs01.dbf';
alter database rename file '/u01/app/oracle/oradata/CDB/pdbseed/system01.dbf' to '/home/oracle/CDB/pdbseed/system01.dbf';
alter database rename file '/u01/app/oracle/oradata/CDB/pdbseed/sysaux01.dbf' to '/home/oracle/CDB/pdbseed/sysaux01.dbf';
alter database rename file '/u01/app/oracle/oradata/CDB/users01.dbf' to '/home/oracle/CDB/users01.dbf';
alter database rename file '/u01/app/oracle/oradata/CDB/pdbseed/undotbs01.dbf' to '/home/oracle/CDB/pdbseed/undotbs01.dbf';
alter database rename file '/u01/app/oracle/oradata/CDB/PDB1/system01.dbf' to '/home/oracle/CDB/PDB1/system01.dbf';
alter database rename file '/u01/app/oracle/oradata/CDB/PDB1/sysaux01.dbf' to '/home/oracle/CDB/PDB1/sysaux01.dbf';
alter database rename file '/u01/app/oracle/oradata/CDB/PDB1/undotbs01.dbf' to '/home/oracle/CDB/PDB1/undotbs01.dbf';
alter database rename file '/u01/app/oracle/oradata/CDB/PDB1/users01.dbf' to '/home/oracle/CDB/PDB1/users01.dbf';
-- 
alter database rename file '/u01/app/oracle/oradata/CDB/redo03.log' to '/home/oracle/CDB/redo03.log';
alter database rename file '/u01/app/oracle/oradata/CDB/redo02.log' to '/home/oracle/CDB/redo02.log';
alter database rename file '/u01/app/oracle/oradata/CDB/redo01.log' to '/home/oracle/CDB/redo01.log';


#cau hinh EM
exec DBMS_XDB_CONFIG.SETHTTPSPORT(5502);



#exportdump
. ~/.bash_profile

dumpName='backup_dump_hddt_'$(date +"%F")'.dmp'
logName='backup_dump_hddt_'$(date +"%F")'.log'
expdp \" oracle/oracle as sysdba \" directory=backup_hddt schemas=INVOICE_TT78_STANDARD dumpfile=$dumpName logfile=$logName

#delet old file
find /home/oracle/app/oracle/export_backup/ -mtime +2 -type f -exec rm {} \;


#import db

<property name="connection.connection_string">Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=10.21.189.176)(PORT=1521))(CONNECT_DATA=(SID=hddtdb)));User Id=INVOICE_TT78_STANDARD;Password=INVOICE_TT78_STANDARD</property>	


create directory invoicedb as '/home/oracle/invoiceDB'
impdp \" / as sysdba \" directory=invoicedb 

impdp \" oracle/oracle as sysdba \" directory=invoicedb schemas=INVOICE_TT78_STANDARD dumpfile=backup_dump_hddt_2024-01-20.dmp logfile=restore.log 
impdp \" INVOICE_TT78_STANDARD/INVOICE_TT78_STANDARD as sysdba \" directory=invoicedb schemas=INVOICE_TT78_STANDARD dumpfile=invoice20240123.dmp logfile=restore20240123.log 

impdp \" as sysdba \" directory=invoicedb schemas=INVOICE_TT78_STANDARD dumpfile=invoice20240123.dmp logfile=restore20240123.log 

impdp \" as sysdba \" directory=invoicedb schemas=INVOICE_TT78_STANDARD dumpfile=backup_dump_hddt_2024-01-20.dmp logfile=restore.log 

impdp "'/ as sysdba'" directory=invoicedb dumpfile=backup_dump_hddt_2024-01-20.dmp logfile=restore.log  schemas=INVOICE_TT78_STANDARD


CREATE DIRECTORY hddtNew AS '/u01/app/oracle/oradata/hddtNew';
impdp "'/ as sysdba'" directory=hddtNew dumpfile=20240123.dmp logfile=restore.hddt.log  schemas=INVOICE_TT78_STANDARD
sqlplus INVOICE_TT78_STANDARD/INVOICE_TT78_STANDARD@10.10.10.10:1521
CREATE TABLESPACE DATA 
		    NOLOGGING 
		    DATAFILE '/u01/app/oracle/oradata/hddtNew/invoicedata01.dbf' SIZE 10M REUSE 
	    AUTOEXTEND ON NEXT 128M
                 MAXSIZE UNLIMITED
		    EXTENT MANAGEMENT LOCAL
                 SEGMENT SPACE MANAGEMENT AUTO;

SQL> select tablespace_name, con_id from cdb_tablespaces;

TABLESPACE_NAME                    CON_ID
------------------------------ ----------
SYSTEM                                  0
SYSAUX                                  0
UNDOTBS1                                0
TEMP                                    0
USERS                                   0
DATA                                    0
TPSINDEX                                0




adduser INVOICE_TT78_STANDARD

create user INVOICE_TT78_STANDARD identified by INVOICE_TT78_STANDARD;
grant connect, create session, imp_full_database to INVOICE_TT78_STANDARD;

CREATE DIRECTORY INVOICEDB AS '/u01/app/oracle/oradata/hddtNew';

impdp "'/ as sysdba'" directory=hddtNew dumpfile=20240123.dmp logfile=restore.hddtNew.log  schemas=INVOICE_TT78_STANDARD

sqlplus INVOICE_TT78_STANDARD/INVOICE_TT78_STANDARD@10.10.10.10:1521

conn INVOICE_TT78_STANDARD/INVOICE_TT78_STANDARD@orcl


<property name="connection.connection_string">Data Source=ho-hoadondt.bsc.com.vn:1521/BSCINVOICE;User Id=bsc;Password=bsc</property>
create user bsc identified by bsc;
grant connect, create session, imp_full_database to bsc

create user BSCINVOICE identified by BSCINVOICE;
grant connect, create session, imp_full_database to BSCINVOICE;

impdp "'/ as sysdba'" directory=hddtOld_direct dumpfile=EXP_BSCINVOICE_20231108.DMP logfile=restore.hddtOld.log  schemas=bsc
CREATE DIRECTORY hddtOld_direct AS '/u01/app/oracle/oradata/hddtOld';

BSCINVOICE


set file_name=exp_OTC_%date:~-4,4%%date:~-7,2%%date:~-10,2%
expdp OTC/OTCNEW@OTC directory=DIREXP schemas=OTC dumpfile=%file_name%.dmp logfile=%file_name%.log

create user otc identified by otc;
grant connect, create session, imp_full_database to otc


CREATE DIRECTORY otc_direct AS '/u01/app/oracle/oradata/otc';
impdp "'/ as sysdba'" directory=otc_direct dumpfile=EXP_OTC_20242301.DMP logfile=restore.otc.log  schemas=OTC