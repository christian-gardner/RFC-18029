CREATE OR REPLACE TRIGGER SQA_TD_DATA_SEQ_BI
BEFORE INSERT ON RDM.SQA_TD_DATA
FOR EACH ROW
DECLARE
  P_ID                number;
  P_CNT               NUMBER;
  P_CNT_2             NUMBER;
  P_CLIENT            VARCHAR2 (10 BYTE);
  P_WORK_CODE         VARCHAR2 (10 BYTE);
  P_WORK_GROUP        VARCHAR2 (20 BYTE);
  P_LOAN_TYPE         VARCHAR2 (10 BYTE);
  NBR_QS              NUMBER;
  SQL_STMP            VARCHAR2 (1000 BYTE);
  P_STANDING          NUMBER;
  MESSAGE             VARCHAR2(300 BYTE);
  P_REPORT_SEGMENT    VARCHAR2(100 BYTE);
  P_CONTRACTOR        VARCHAR2(100 BYTE);
  P_COMPLETEDDATE     DATE;
  START_CHECK_DATE    DATE;
  GV_CURRENT_DATE     DATE;
  GV_TESTING          NUMBER;
  BAD_DATA         EXCEPTION;

BEGIN

          SELECT NVL(MAX(STANDING),0)
            INTO  P_STANDING
            FROM SQA_VENDOR_LIST;

          SELECT VARIABLE_VALUE
           INTO  GV_TESTING
           FROM  SQA_SYS_VARIABLES
          WHERE VARIABLE_NAME = 'TESTING';


         IF ( GV_TESTING = 1 ) THEN

                SELECT TO_DATE(VARIABLE_VALUE,'MM/DD/YYYY')
                 INTO  GV_CURRENT_DATE
                 FROM  SQA_SYS_VARIABLES
                WHERE VARIABLE_NAME = 'Current_date';
         ELSE
                SELECT  TRUNC(SYSDATE)
                INTO    GV_CURRENT_DATE
                FROM  DUAL;
         END IF;

        P_CLIENT         := :new.CLIENT;
        P_WORK_CODE      := :new.work_code;
        P_LOAN_TYPE      := :new.LOAN_TYPE;
        P_CONTRACTOR     := :new.CONTRACTOR;
        P_REPORT_SEGMENT := :new.REPORT_SEGMENT;
        P_COMPLETEDDATE  := :new.completed_dt; 
        
    BEGIN
    ----- Refresh or Grass
        SELECT GROUP_NAME
        INTO   P_WORK_GROUP
        FROM   SQA_TD_WORK_GROUPS
        WHERE  WORKCODE = P_WORK_CODE;
        
          SELECT COUNT(*)
          INTO P_CNT
          FROM SQA_VENDOR_LIST
         WHERE  VENDOR_CODE  = P_CONTRACTOR
           AND   SEGMENTS    = P_REPORT_SEGMENT
           AND   WORKCODE    = P_WORK_GROUP;                
    EXCEPTION
         WHEN OTHERS THEN
         P_WORK_GROUP := 'ERROR';
         P_CNT        := -1;
    END;

         
  --- P_CNT 
  --    0  NEW CONTRACTOR 
  ---   1  CONTRACTOR LISTED
  ---- -1  BAD WORK CODE

/*

   This is a new contractor
   set the starting counting point to the max (trunc(completed date)) - 90
   from the workorder view
   where contractor = p_contractor

   the followup date comes from the 30/50/100 rule
   the followup is Initial

 */

   IF ( P_CNT = 0 )
      THEN

      START_CHECK_DATE := TRUNC(P_COMPLETEDDATE) - 1;

     begin

/*
           FOLLOW_UP_DTE         = NULL,
           NEXT_REVIEW           = NULL,
           FOLLOW_UP             = 'Initial',
           STANDING              = BOTTOM_OF_LIST,
           NBR_WORKORDERS        =  0,
           NBR_COMPLETED         =  0,
           THIRTY_FIFTY_DAY_RULE =  0,
           START_COUNTER_DATE    =  (GV_CURRENT_DATE + 1),
           ASSIGN_IT             =  0,
           COMPLETED_BY          =  0,
           ASSIGNED_TO           =  0,
           BATCH_NO              =  0,
           LAST_REVIEW           = GV_CURRENT_DATE

*/

                   INSERT INTO SQA_VENDOR_LIST(
                                  VENDOR_CODE,
                                  STANDING ,
                                  ACTIVE,
                                  SEGMENTS,
                                  WORKCODE,
                                  START_COUNTER_DATE,
                                  FOLLOW_UP,
                                  FOLLOW_UP_CAT,
                                  THIRTY_FIFTY_DAY_RULE,
                                  BATCH_NO,
                                  ASSIGNED_TO,
                                  ASSIGN_IT,
                                  COMPLETED_BY,
                                  NBR_COMPLETED,
                                  NBR_WORKORDERS)
                           VALUES (P_CONTRACTOR,
                                  (P_STANDING +1),
                                   1,
                                  P_REPORT_SEGMENT,
                                  P_WORK_GROUP,
                                  START_CHECK_DATE,
                                  'Initial',
                                  'INITIAL-NEW-TDA-VENDOR',
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0);
     exception
            WHEN OTHERS THEN
             NULL;
     END;


   END IF;



EXCEPTION
        WHEN BAD_DATA THEN
        SEND_EMAIL (P_TEAM=>'RDM',P_FROM=>'APEX SQA APP',P_SUBJECT=>'Error IN SQA_TD_DATA TRIGGER!!' ,P_MESSAGE=>'-'||P_CLIENT||'-'||P_WORK_CODE||'-'||P_LOAN_TYPE||'-' );

        WHEN OTHERS THEN
        MESSAGE := SQLERRM;

        SEND_EMAIL (P_TEAM=>'RDM',P_FROM=>'APEX SQA APP',P_SUBJECT=>'Error IN SQA_TD_DATA TRIGGER!!' ,P_MESSAGE=>MESSAGE );



END;
/