PROMPT gather fixed table stats
EXEC DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;

PROMPT gather dictionary stats
EXEC DBMS_STATS.GATHER_DICTIONARY_STATS;

PROMPT gather database stats
EXEC DBMS_STATS.GATHER_DATABASE_STATS;

PROMPT gather system stats
EXEC DBMS_STATS.GATHER_SYSTEM_STATS;

SET LINE 100
COLUMN operation  FORMAT A30
COLUMN start_time FORMAT A16
COLUMN end_time   FORMAT A16
SELECT to_char(start_time,'YYYY-MM-DD HH24:MI') as start_time,
       to_char(  end_time,'YYYY-MM-DD HH24:MI') as end_time,
       operation       
  FROM dba_optstat_operations
 WHERE operation IN (
       'gather_dictionary_stats', 
       'gather_database_stats', 
       'gather_schema_stats', 
       'gather_fixed_objects_stats')
ORDER BY start_time;



