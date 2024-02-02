 cd /run/media/admin/OL-7.9\ Server.x86_64/Packages/ # vao cd
 rpm -ivh libaio-0.3.109-13.el7.x86_64.rpm 
 rpm -ivh libaio-devel-0.3.109-13.el7.x86_64.rpm 
 rpm -ivh ksh-20120801-142.0.1.el7.x86_64.rpm 

#Tải goi len server và chạy
 rpm -ivh oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm

 id oracle
 #set passwor oracle
 passwd oracle

 # cau hinh selinux=disable
 vi /etc/selinux/config

 systemctl stop firewalld
 systemctl disable firewalld

[root@oarclesv01 oracle]# mkdir -p /u01/app/oracle/product/19.0.0/dbhome_1
[root@oarclesv01 oracle]# chown -R oracle:oinstall /u01
[root@oarclesv01 oracle]# chmod -R 775 /u01

#Co th dung cong cu Xlaunch de tai ui tu xa

.oraenv

#start listener
lsnrctl start

#start database
sqlplus / as sysdba
SQL> startup #khoi dong db
    desc dbms_stats
    desc dbms_standard

#Tao plugable database
name: orcl_plug
username: pdbadmin/oracle

show pdbs

#KEt noi truc tiep vao plugable
conn system/oracle@oraclesv02:1521/orcl_plug

(lsnrctl status)

alter system set local_listener='(ADDRESS=(PROTOCOL=tcp)(HOST=oraclesv01)(PORT=1521))'

 alter system register ;
conn system/oracle@oraclesv02:1521/orcl_plug
show con_name

# Tao user nhan su
create user nhansu identified by oracle ;
grant connect, resource, unlimited tablespace to nhansu ;

#ket noi vao nhan su
conn nhansu/oracle@oraclesv01:1521/orcl_plug
sqlplus nhansu/oracle@oraclesv02:1521/orcl_plug
sqlplus system/oracle@oraclesv02:1521/orcl_plug
sqlplus orclcdb/oracle@oraclesv02:1521/orcl_plug

CREATE TABLE students  
( id number(10) NOT NULL,  
  name varchar2(40) NOT NULL,  
  class varchar2(10)  
);

insert into customers values(10, 'Thanh', 'HCM')

B8: tao sample
perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat
perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat
sqlplus system/oracle@oraclesv01:1521/orcl_plug
@mksample oracle oracle hr oe pm ix sh bi users temp /tmp/ oraclesv02:1521/orcl_plug 

SELECT NAME FROM v$database;

alter pluggable database all open

conn oe/oe@oraclesv02:1521/orcl_plug
conn hr/hr@oraclesv02:1521/orcl_plug

./oratop -r -f -i 10 / as sysdba

https://10.10.10.101:5500/em

HRPDB =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = oraclesv02)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = orcl_plug)
    )
  )
