BEGIN

   DBMS_SCHEDULER.DROP_JOB('RDM.ARCH_SQA_DATA');
   

EXCEPTION 
    WHEN OTHERS THEN 
    NULL;
END;


BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'RDM.ARCH_SQA_DATA'
      ,start_date      => TO_TIMESTAMP_TZ('2016/08/09 17:00:00.000000 -04:00','yyyy/mm/dd hh24:mi:ss.ff tzr')
      ,repeat_interval => 'FREQ=WEEKLY;BYDAY=MON,TUE,WED,THU,FRI,SAT,SUN;BYHOUR=01'
      ,end_date        => NULL
      ,job_class       => 'DEFAULT_JOB_CLASS'
      ,job_type        => 'STORED_PROCEDURE'
      ,job_action      => 'SQA_LOVS.ARCHIVE_SQA_DATA'
      ,comments        => 'Refresh RDM Schema'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'RDM.ARCH_SQA_DATA'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'RDM.ARCH_SQA_DATA'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'RDM.ARCH_SQA_DATA'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'RDM.ARCH_SQA_DATA'
     ,attribute => 'MAX_RUNS');
  BEGIN
    SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
      ( name      => 'RDM.ARCH_SQA_DATA'
       ,attribute => 'STOP_ON_WINDOW_CLOSE'
       ,value     => FALSE);
  EXCEPTION
    -- could fail if program is of type EXECUTABLE...
    WHEN OTHERS THEN
      NULL;
  END;
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'RDM.ARCH_SQA_DATA'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'RDM.ARCH_SQA_DATA'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'RDM.ARCH_SQA_DATA'
     ,attribute => 'AUTO_DROP'
     ,value     => TRUE);

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'RDM.ARCH_SQA_DATA');
END;
/
