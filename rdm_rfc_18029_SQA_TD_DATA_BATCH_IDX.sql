
drop index RDM.SQA_TD_DATA_BATCH;


CREATE INDEX RDM.SQA_TD_DATA_BATCH ON RDM.SQA_TD_DATA ( CONTRACTOR, REPORT_SEGMENT, COMPLETED_DT);


