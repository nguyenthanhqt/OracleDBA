[oracle@oraclesv02 hddtNew]$ sqlplus / as sysdba

--xe pdbs hien co
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 ORCL_PLUG                      READ WRITE NO
         4 PDB_HDDT                       READ WRITE NO

--chuyen san mot pluggable cu the 
SQL> alter session set container=orcl_plug;
SQL>