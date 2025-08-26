sqlplus -s / as sysdba << EOF 
PROMPT CDB set database timezone to Berlin time
ALTER DATABASE SET time_zone='Europe/Berlin';

PROMPT PDB set database timezone to Berlin time
ALTER SESSION SET CONTAINER=${ORACLE_PDB};
ALTER DATABASE SET time_zone='Europe/Berlin';
EOF
