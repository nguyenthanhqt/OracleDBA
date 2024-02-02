--share server
--Xem thong tin share server

SQL> show parameter share;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
hi_shared_memory_address             integer     0
max_shared_servers                   integer
shared_memory_address                integer     0
shared_pool_reserved_size            big integer 31666995
shared_pool_size                     big integer 0
shared_server_sessions               integer
shared_servers                       integer     1
SQL>

-- cau hinh max min
alter system set max_shared_servers=10 scope=both;
alter system set shared_servers=3 scope=both;

SQL> alter system set max_shared_servers=10 scope=both;

System altered.

SQL> alter system set shared_servers=3 scope=both;

System altered.

SQL>

-- cau hinh dispatcher
SQL> alter session set container=orcl_plug;
SQL> exec dbms_service.create_service('orcl_share', 'orcl_share');
SQL> exec dbms_service.start_service('orcl_share');

SQL> show parameter dispatcher

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
dispatchers                          string      (PROTOCOL=TCP) (SERVICE=orclcd
                                                 bXDB)
enable_dnfs_dispatcher               boolean     FALSE
max_dispatchers                      integer
SQL>

--(login vao container root)
alter system set dispatchers='(PROTOCOL=TCP) (SERVICE=orclcdbXDB, orcl_share)(dispatchers=3)';

-- kiem tra service
SQL> ! lsnrctl services

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 02-FEB-2024 11:21:24

Copyright (c) 1991, 2022, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oraclesv02)(PORT=1521)))
Services Summary...
Service "0d9047a4f4805a3ee063650a0a0a4c93" has 1 instance(s).
  Instance "orclcdb", status READY, has 1 handler(s) for this service...
    Handler(s):
      "DEDICATED" established:0 refused:0 state:ready
         LOCAL SERVER
Service "1036ae06ba711344e063650a0a0a0f88" has 1 instance(s).
  Instance "orclcdb", status READY, has 1 handler(s) for this service...
    Handler(s):
      "DEDICATED" established:0 refused:0 state:ready
         LOCAL SERVER
Service "86b637b62fdf7a65e053f706e80a27ca" has 1 instance(s).
  Instance "orclcdb", status READY, has 1 handler(s) for this service...
    Handler(s):
      "DEDICATED" established:0 refused:0 state:ready
         LOCAL SERVER
Service "orcl_plug" has 1 instance(s).
  Instance "orclcdb", status READY, has 1 handler(s) for this service...
    Handler(s):
      "DEDICATED" established:0 refused:0 state:ready
         LOCAL SERVER
Service "orcl_share" has 1 instance(s).
  Instance "orclcdb", status READY, has 4 handler(s) for this service...
    Handler(s):
      "DEDICATED" established:0 refused:0 state:ready
         LOCAL SERVER
      "D002" established:0 refused:0 current:0 max:1022 state:ready
         DISPATCHER <machine: oraclesv02.localdomain, pid: 27536>
         (ADDRESS=(PROTOCOL=tcp)(HOST=oraclesv02)(PORT=35573))
      "D001" established:0 refused:0 current:0 max:1022 state:ready
         DISPATCHER <machine: oraclesv02.localdomain, pid: 27534>
         (ADDRESS=(PROTOCOL=tcp)(HOST=oraclesv02)(PORT=28543))
      "D000" established:0 refused:0 current:0 max:1022 state:ready
         DISPATCHER <machine: oraclesv02.localdomain, pid: 15227>
         (ADDRESS=(PROTOCOL=tcp)(HOST=oraclesv02)(PORT=29823))
Service "orclcdb" has 1 instance(s).
  Instance "orclcdb", status READY, has 1 handler(s) for this service...
    Handler(s):
      "DEDICATED" established:0 refused:0 state:ready
         LOCAL SERVER
Service "orclcdbXDB" has 1 instance(s).
  Instance "orclcdb", status READY, has 3 handler(s) for this service...
    Handler(s):
      "D002" established:0 refused:0 current:0 max:1022 state:ready
         DISPATCHER <machine: oraclesv02.localdomain, pid: 27536>
         (ADDRESS=(PROTOCOL=tcp)(HOST=oraclesv02)(PORT=35573))
      "D001" established:0 refused:0 current:0 max:1022 state:ready
         DISPATCHER <machine: oraclesv02.localdomain, pid: 27534>
         (ADDRESS=(PROTOCOL=tcp)(HOST=oraclesv02)(PORT=28543))
      "D000" established:0 refused:0 current:0 max:1022 state:ready
         DISPATCHER <machine: oraclesv02.localdomain, pid: 15227>
         (ADDRESS=(PROTOCOL=tcp)(HOST=oraclesv02)(PORT=29823))
Service "pdb_hddt" has 1 instance(s).
  Instance "orclcdb", status READY, has 1 handler(s) for this service...
    Handler(s):
      "DEDICATED" established:0 refused:0 state:ready
         LOCAL SERVER
The command completed successfully

--
sqlplus hr/hr@localhost:1521/orcl_share
select username, server from v$session where username='HR'


---SGA_PGA
MEM: sga=60% of ram
     pga=40% of ram