
sqlplus -s / as sysdba << EOF
PROMPT disable traditional audit
ALTER SYSTEM SET audit_trail=none SCOPE=SPFILE;
EOF

# shut down database
echo "shutting down database"
/home/oracle/shutDown.sh normal

# enable unified auditing DocID 1567006.1
echo "relinking"
pushd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk uniaud_on ioracle
popd

# start up database
echo "starting up database"
/home/oracle/startUp.sh

# audit logons
echo "audit logon, logoff"
sqlplus -s / as sysdba << EOF
prompt create audit policy for logon logoff
CREATE AUDIT POLICY tedata_connection_policy ACTIONS logon, logoff CONTAINER=ALL;
prompt enable audit policy for logon logoff
AUDIT POLICY        tedata_connection_policy;
EOF

# auto purge audit table
sqlplus -s / as sysdba << EOF
SET SERVEROUTPUT ON
DECLARE 
  l_archive_job_name VARCHAR2(128 BYTE) := 'TEDATA_ARCHIVE_AUDIT';
  l_purge_job_name   VARCHAR2(128 BYTE) := 'TEDATA_PURGE_AUDIT';
  n NUMBER;
BEGIN
  -- drop archive job if exists
  SELECT count(*) INTO n
    FROM user_scheduler_jobs
   WHERE job_name = l_archive_job_name;
  IF n > 0 THEN
    dbms_output.put_line('Dropping job '||l_archive_job_name);
    dbms_scheduler.drop_job(l_archive_job_name);
  END IF;

  -- drop purge job if exists
  SELECT count(*) INTO n
    FROM dba_audit_mgmt_cleanup_jobs
   WHERE job_name = l_purge_job_name;
  IF n > 0 THEN
    dbms_output.put_line('Dropping job '||l_purge_job_name);
    dbms_audit_mgmt.drop_purge_job(l_purge_job_name);
  END IF;
    
  dbms_output.put_line('Partitioning audit to 7 days');
  dbms_audit_mgmt.alter_partition_interval(7, 'DAY');

  -- create a job that marks audit entries to purge if older than 28 days  
  dbms_scheduler.create_job (
    job_name        => l_archive_job_name,
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'dbms_audit_mgmt.set_last_archive_timestamp(dbms_audit_mgmt.audit_trail_unified, trunc(systimestamp) - 28)',
    start_date      => systimestamp,
    repeat_interval => 'freq=daily; byhour=0; byminute=0; bysecond=0;',
    end_date        => null,
    enabled         => true,
    comments        => 'automatically set audit last archive time'
  );
  dbms_output.put_line('Created job  '||l_archive_job_name);
  
  -- log execution of the marker job
  dbms_scheduler.set_attribute(l_archive_job_name, 'LOGGING_LEVEL', dbms_scheduler.logging_full);
  
  -- create a job that purges the marked records every 24 hours
  dbms_audit_mgmt.create_purge_job(
    audit_trail_type           => dbms_audit_mgmt.audit_trail_unified,
    audit_trail_purge_interval => 24 /* hours */,
    audit_trail_purge_name     => l_purge_job_name,
    use_last_arch_timestamp    => TRUE,
    container                  => dbms_audit_mgmt.container_all
  );
  dbms_output.put_line('Created job  '||l_purge_job_name);  
END;
/
EOF