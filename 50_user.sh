#!/bin/bash

# 1) create common user C##EXAMPLEDBA in CDB$ROOT
# 2) create normal user EXAMPLE and dba user EXAMPLEDBA in first PDB
# 2) create directory ORAPUMP in /opt/oracle/orapump


# modify user_name and password to your liking, careful, it will be logged in the output
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# example, normal user
user_name="example"

# password
password="oracle"
# ∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧∧


# exampledba, with DBA role
dba_name="${user_name}dba"

# c#exampledba, with DBA role in all containers
common_name="c##${user_name}dba"

# create directory for external tables and datapump
echo "create directory orapump"
mkdir -p /opt/oracle/orapump

# create users
sqlplus -s / as sysdba << EOF
PROMPT create common user ${common_name} ${password} in CDB$ROOT
CREATE USER ${common_name} IDENTIFIED BY "${password}" CONTAINER=ALL;
GRANT CREATE SESSION, DBA TO ${common_name} CONTAINER=ALL;

PROMPT switch to PDB ${ORACLE_PDB}
ALTER SESSION SET CONTAINER=${ORACLE_PDB};

PROMPT create directory object for orapump
CREATE OR REPLACE DIRECTORY orapump AS '/opt/oracle/orapump'; 

PROMPT create normal user ${user_name}  ${password}
CREATE USER ${user_name} IDENTIFIED BY "${password}" 
  DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
GRANT CREATE SESSION, RESOURCE, SELECT_CATALOG_ROLE, SELECT ANY TABLE TO ${user_name};
GRANT READ, WRITE, EXECUTE ON DIRECTORY orapump TO ${user_name};

PROMPT create dba user ${dba_name}  ${password}
CREATE USER ${dba_name} IDENTIFIED BY "${password}" 
  DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
GRANT CREATE SESSION, DBA TO ${dba_name};
GRANT READ, WRITE, EXECUTE ON DIRECTORY orapump TO ${dba_name};
EOF



