
begin 


    begin

    execute immediate 'drop index RDM.SQA_TD_DATA_BATCH';

    exception 
            when others then
            null;
    end;




 EXECUTE IMMEDIATE 'CREATE INDEX RDM.SQA_TD_DATA_BATCH ON RDM.SQA_TD_DATA ( CONTRACTOR, REPORT_SEGMENT, COMPLETED_DT)';

EXCEPTION 
      WHEN OTHERS THEN
      NULL;
END;
/

