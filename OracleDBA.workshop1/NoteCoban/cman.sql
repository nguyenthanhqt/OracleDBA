-- Unzip software
[oracle@server1 ~]$ unzip -d $HOME V982064-01.zip
-- Install 
[oracle@server1 ~]$ cd client
[oracle@server1 client]$ ls
install  response  runInstaller  stage  welcome.html
--
+ Chon custom
+ ORACLE_HOME la /u01/app/oracle/product/19.0.0/client_1
+ Chon cman va listener
-- Chuan bi moi truong
[oracle@server1 ~]$ echo "client:/u01/app/oracle/product/19.0.0/client_1:N" >>/etc/oratab
[oracle@server1 ~]$ cat /etc/oratab
cdb:/u01/app/oracle/product/19.0.0/dbhome_1:N
test:/u01/app/oracle/product/19.0.0/dbhome_1:N
+ASM:/u01/app/19.0.0/grid:N		# line added by Agent
orclcdb:/u01/app/oracle/product/19.0.0/dbhome_1:N		# line added by Agent
client:/u01/app/oracle/product/19.0.0/client_1:N
[oracle@server1 ~]$ . oraenv
ORACLE_SID = [orclcdb] ? client
The Oracle base has been set to /u01/app/oracle
[oracle@server1 ~]$ cd $ORACLE_HOME/network/admin
[oracle@server1 admin]$ ls
samples  shrept.lst  sqlnet.ora
[oracle@server1 admin]$ ls samples/
cman.ora  listener.ora  sqlnet.ora  tnsnames.ora
[oracle@server1 admin]$ cp samples/cman.ora cman.ora
--Tao thu muc ghi log
mkdir -p /u01/app/oracle/cman/log
mkdir -p /u01/app/oracle/cman/trace
-- thay cac thong so sau trong file cman.ora
<fqhost> localhost
<lsnport> 1522
<logdir> /u01/app/oracle/cman/log 
<trcdir> /u01/app/oracle/cman/trace
-- Thiet lap cac thong so
max_gateway_processes=8
min_gateway_processes=3
--
[oracle@server1 admin]$ cmctl

CMCTL for Linux: Version 19.0.0.0.0 - Production on 20-APR-2022 10:16:39

Copyright (c) 1996, 2019, Oracle.  All rights reserved.

Welcome to CMCTL, type "help" for information.

CMCTL> admin cman_localhost
Current instance cman_localhost is not yet started
Connections refer to (DESCRIPTION=(address=(protocol=tcp)(host=localhost)(port=1522))).
The command completed successfully.
CMCTL:cman_localhost> startup
Starting Oracle Connection Manager instance cman_localhost. Please wait...
CMAN for Linux: Version 19.0.0.0.0 - Production
Status of the Instance
----------------------
Instance name             cman_localhost
Version                   CMAN for Linux: Version 19.0.0.0.0 - Production
Start date                20-APR-2022 10:17:29
Uptime                    0 days 0 hr. 0 min. 9 sec
Num of gateways started   3
Average Load level        0
Log Level                 OFF
Trace Level               OFF
Instance Config file      /u01/app/oracle/product/19.0.0/client_1/network/admin/cman.ora
Instance Log directory    /u01/app/oracle/diag/netcman/server1/cman_localhost/alert
Instance Trace directory  /u01/app/oracle/diag/netcman/server1/cman_localhost/trace
The command completed successfully.
CMCTL:cman_localhost> 
-- Cau hinh de database ghi nhan vao cman
-- Change moi truong sang orclcdb
[oracle@server1 admin]$ cd $ORACLE_HOME/network/admin
-- Them dong sau vao file tnsnames.ora
LISTENER_CMAN =
  (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1522))
-- Log vao database orclcdb
sqlplus / as sysdba
alter system set remote_listener='LISTENER_CMAN';
-- Cach khac
alter system set remote_listener='192.168.56.22:1521' scope=both;
-- Register
alter system register;
--- Setup phia client. Them vao file tnsnames.ora phia client dong sau:
C_ORCLCDB =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1522))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = orclcdb)
    )
  )
--Test ket noi
[oracle@server1 admin]$ sqlplus system/oracle@c_orclcdb

SQL*Plus: Release 19.0.0.0.0 - Production on Wed Apr 20 10:51:30 2022
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Last Successful login time: Wed Apr 20 2022 10:49:21 +07:00

Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0
-- Cau hinh database de su dung session multiplexing
[oracle@server1 samples]$ . oraenv
ORACLE_SID = [client] ? orclcdb
The Oracle base remains unchanged with value /u01/app/oracle
[oracle@server1 samples]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Wed Apr 20 10:57:16 2022
Version 19.3.0.0.0
Copyright (c) 1982, 2019, Oracle.  All rights reserved.
Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0
SQL> alter system set dispatchers="(PROTOCOL=tcp)(MULTIPLEX=on)";
System altered.
-- query
column "OS USER" format A8
column username format A10
column Machine format A8
column programe format A15
select server,substr(username,1,15) "USERNAME",
substr(OSUSER,1,8) "OS USER",substr(machine,1,7) machine,
substr(program,1,15) "program"
from v$session
where type='USER'
/
SERVER	  USERNAME   OS USER  MACHINE
--------- ---------- -------- --------
program
------------------------------------------------------------
DEDICATED SYS	     oracle   server1
sqlplus@server1
DEDICATED SYSRAC     oracle   server1
oraagent.bin@se
DEDICATED SYS	     oracle   server1
sqlplus@server1
-- Mo mot session khac trong moi truong client
[oracle@server1 admin]$ sqlplus system/oracle@c_orclcdb
--
SERVER	  USERNAME   OS USER  MACHINE
--------- ---------- -------- --------
program
------------------------------------------------------------
DEDICATED SYS	     oracle   server1
sqlplus@server1
DEDICATED SYSRAC     oracle   server1
oraagent.bin@se
DEDICATED SYS	     oracle   server1
sqlplus@server1
NONE	  SYSTEM     oracle   server1
sqlplus@server1
--Mo them mot session nua trong client
[oracle@server1 admin]$ sqlplus system/oracle@c_orclcdb
-- Query lai
SQL> /
DEDICATED SYS	     oracle   server1
sqlplus@server1
DEDICATED SYSRAC     oracle   server1
oraagent.bin@se
DEDICATED SYS	     oracle   server1
sqlplus@server1
NONE	  SYSTEM     oracle   server1
sqlplus@server1
NONE	  SYSTEM     oracle   server1
sqlplus@server1
-- Ca 2 ket noi qua cung 1 dispatcher
SQL> col "QUEUE" format A12
SQL> select saddr, circuit, dispatcher, server, substr(queue,1,8) "queue", waiter from v$circuit;
0000000073937150 000000006B004028 0000000074524E88 00		    NONE    00
000000007391E240 000000006B0059B8 0000000074524E88 00		    NONE    00
-- Khao sat khi su dung multiplexing so server process khong tang khi tang ket noi
select s.username
from  gv$session s, gv$process p
where p.spid=nvl('&unix_process',' ')
and s.paddr=p.addr
order by s.sid;
-- Tat cman
[oracle@server1 samples]$ . oraenv
ORACLE_SID = [orclcdb] ? client
The Oracle base remains unchanged with value /u01/app/oracle
[oracle@server1 samples]$ cmctl

CMCTL for Linux: Version 19.0.0.0.0 - Production on 20-APR-2022 11:56:31

Copyright (c) 1996, 2019, Oracle.  All rights reserved.

Welcome to CMCTL, type "help" for information.

CMCTL> admin cman_localhost
Current instance cman_localhost is already started
Connections refer to (DESCRIPTION=(address=(protocol=tcp)(host=localhost)(port=1522))).
The command completed successfully.
CMCTL:cman_localhost> shutdown abort
The command completed successfully.
CMCTL:cman_localhost> exit

-- Muilty plexing
alter system set dispatchers="(PROTOCOL=ctp)(MULTYPLEX=on)";

ps -ef | grep orclcdb














