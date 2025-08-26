PROMPT change maintenance window on CDB$ROOT to 02:00
DECLARE
  l_name     dba_scheduler_windows.window_name%type;
  l_interval dba_scheduler_windows.repeat_interval%type;
  l_duration dba_scheduler_windows.duration%type;
  
  PROCEDURE change(s IN OUT VARCHAR, clause VARCHAR2, value VARCHAR2) 
  IS 
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('before='||s);
    s := regexp_replace(s, '('||clause||')=([0-9]+)','\1='||value,1,1,'i');
    --DBMS_OUTPUT.PUT_LINE('after ='||s);
  END change;
BEGIN
  FOR r IN (SELECT owner, window_name, repeat_interval
              FROM dba_scheduler_windows
             WHERE owner = 'SYS'
               AND resource_plan = 'DEFAULT_MAINTENANCE_PLAN'
               AND window_name LIKE '%_WINDOW')
  LOOP
    l_interval := r.repeat_interval;
    --DBMS_OUTPUT.PUT_LINE(rpad(r.window_name,20)||' '||l_interval);
    change(l_interval, 'BYHOUR',   '02');
    change(l_interval, 'BYMINUTE', '00');
    l_duration := numtodsinterval(2, 'hour');
    
    DBMS_SCHEDULER.DISABLE(name => r.window_name, force => TRUE);

    DBMS_SCHEDULER.SET_ATTRIBUTE(
       name      => r.owner||'.'||r.window_name,
       attribute => 'REPEAT_INTERVAL',
       value     => l_interval
    );
    
    DBMS_SCHEDULER.SET_ATTRIBUTE(
       name      => r.owner||'.'||r.window_name,
       attribute => 'DURATION',
       value     => l_duration
    );
    
    DBMS_SCHEDULER.ENABLE(name => r.window_name);
  END LOOP;
END;
/

SET LINE 200
COLUMN con_name        FORMAT A10
COLUMN window_name     FORMAT A16
COLUMN enabled         FORMAT A5
COLUMN repeat_interval FORMAT A60

SELECT sys_context('userenv','con_name') as con_name,
       window_name, enabled, repeat_interval, 
       extract(hour from duration) as hours,
       extract(minute from duration) as minutes
  FROM dba_scheduler_windows
 WHERE owner = 'SYS'
  AND resource_plan = 'DEFAULT_MAINTENANCE_PLAN';



-- switch to first pdb
COLUMN first_pdb_col NEW_VALUE first_pdb
SELECT min(pdb_name) AS first_pdb_col
  FROM dba_pdbs
 WHERE pdb_name != 'PDB$SEED';
ALTER SESSION SET CONTAINER=&first_pdb;

PROMPT change maintenance window on PDB to 02:30
DECLARE
  l_name     dba_scheduler_windows.window_name%type;
  l_interval dba_scheduler_windows.repeat_interval%type;
  l_duration dba_scheduler_windows.duration%type;
  
  PROCEDURE change(s IN OUT VARCHAR, clause VARCHAR2, value VARCHAR2) 
  IS 
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('before='||s);
    s := regexp_replace(s, '('||clause||')=([0-9]+)','\1='||value,1,1,'i');
    --DBMS_OUTPUT.PUT_LINE('after ='||s);
  END change;
BEGIN
  FOR r IN (SELECT owner, window_name, repeat_interval
              FROM dba_scheduler_windows
             WHERE owner = 'SYS'
               AND resource_plan = 'DEFAULT_MAINTENANCE_PLAN'
               AND window_name LIKE '%_WINDOW')
  LOOP
    l_interval := r.repeat_interval;
    --DBMS_OUTPUT.PUT_LINE(rpad(r.window_name,20)||' '||l_interval);
    change(l_interval, 'BYHOUR',   '02');
    change(l_interval, 'BYMINUTE', '30');
    l_duration := numtodsinterval(2, 'hour');
    
    DBMS_SCHEDULER.DISABLE(name => r.window_name, force => TRUE);

    DBMS_SCHEDULER.SET_ATTRIBUTE(
       name      => r.owner||'.'||r.window_name,
       attribute => 'REPEAT_INTERVAL',
       value     => l_interval
    );
    
    DBMS_SCHEDULER.SET_ATTRIBUTE(
       name      => r.owner||'.'||r.window_name,
       attribute => 'DURATION',
       value     => l_duration
    );
    
    DBMS_SCHEDULER.ENABLE(name => r.window_name);
  END LOOP;
END;
/

SET LINE 200
COLUMN con_name        FORMAT A10
COLUMN window_name     FORMAT A16
COLUMN enabled         FORMAT A5
COLUMN repeat_interval FORMAT A60

SELECT sys_context('userenv','con_name') as con_name,
       window_name, enabled, repeat_interval, 
       extract(hour from duration) as hours,
       extract(minute from duration) as minutes
  FROM dba_scheduler_windows
 WHERE owner = 'SYS'
  AND resource_plan = 'DEFAULT_MAINTENANCE_PLAN';
