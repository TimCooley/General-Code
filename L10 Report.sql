/*
X:\Operations\Data Analyst\Case ETL\Level 10 Metrics.xlsx
*/


------------ PFA JIRA Tickets Outstanding Over 20 days prior to Claim Filing Deadline, across entire ETL Case Team
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('Pre Filing Analysis')
AND ISSUE_TYPE NOT IN ('Sub-task')
and assignee in ('******)
and CLAIM_DEADLINE <= (trunc(sysdate) + 20)
and status not in ('Closed','Done','Resolved')
;



------------ RLQA JIRA Tickets Outstanding Over 20 days prior to Claim Filing Deadline, across entire ETL Case Team
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('RL QA')
AND ISSUE_TYPE NOT IN ('Sub-task')
and assignee in ('******)
and CLAIM_DEADLINE <= (trunc(sysdate) + 20)
and status not in ('Closed','Done','Resolved')
;




------------ DA JIRA Tickets Outstanding Over 20 days prior to Claim Filing Deadline, across entire ETL Case Team
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('Data Anomalies')
AND ISSUE_TYPE NOT IN ('Sub-task')
and assignee in ('******)
and CLAIM_DEADLINE <= (trunc(sysdate) + 20)
and status not in ('Closed','Done','Resolved')
;



------------ RECONCILIATION PERCENTAGE PFA LAST 7 DAYS

WITH RECONCILED_ACCOUNTS AS (
select COUNT(*) AS "RECONCILED_ACCOUNTS"
from case_specialists.RECON_NOTES
WHERE RECON_FLAG = 'Y'
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE
AND PRODUCT_TYPE = 'PFA'
and QA_COMPLETED_DATED is null 
AND RECON_ID NOT IN( 50, 102)
),
UNRECONCILED_ACCOUNTS AS (
SELECT COUNT(*) AS "UNRECONCILED_ACCOUNTS"
FROM case_specialists.RECON_NOTES
WHERE RECON_FLAG = 'N'
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE
AND PRODUCT_TYPE = 'PFA'
and QA_COMPLETED_DATED is null 
AND RECON_ID NOT IN( 50, 102)
),
INELIGIBLE_ACCOUNTS AS(
SELECT COUNT(*) AS "INELIGIBLE_ACCOUNTS"
FROM case_specialists.RECON_NOTES
WHERE RECON_ID = 50
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE
AND PRODUCT_TYPE = 'PFA'
and QA_COMPLETED_DATED is null 
)

SELECT (R.RECONCILED_ACCOUNTS + UR.UNRECONCILED_ACCOUNTS + I.INELIGIBLE_ACCOUNTS) AS "TOTAL ACCOUNTS", R.RECONCILED_ACCOUNTS, UR.UNRECONCILED_ACCOUNTS, I.INELIGIBLE_ACCOUNTS,
ROUND((((R.RECONCILED_ACCOUNTS / (R.RECONCILED_ACCOUNTS + (UR.UNRECONCILED_ACCOUNTS /*+ I.INELIGIBLE_ACCOUNTS*/))))*100),0) AS "RECONCILIATION PERCENTAGE"
FROM RECONCILED_ACCOUNTS R, UNRECONCILED_ACCOUNTS UR,INELIGIBLE_ACCOUNTS I
;


------------ RECONCILIATION PERCENTAGE RLQA LAST 7 DAYS

WITH RECONCILED_ACCOUNTS AS (
select COUNT(*) AS "RECONCILED_ACCOUNTS"
from case_specialists.RECON_NOTES
WHERE RECON_FLAG = 'Y'
AND RECON_ID IS NOT NULL
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE
AND PRODUCT_TYPE = 'RLQA'
AND RECON_ID NOT IN( 50, 102)
--and QA_COMPLETED_DATED is null 
),
UNRECONCILED_ACCOUNTS AS (
SELECT COUNT(*) AS "UNRECONCILED_ACCOUNTS"
FROM case_specialists.RECON_NOTES
WHERE RECON_FLAG = 'N'
AND RECON_ID IS NOT NULL
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE
AND PRODUCT_TYPE = 'RLQA'
AND RECON_ID NOT IN( 50, 102)
--and QA_COMPLETED_DATED is null 
),
INELIGIBLE_ACCOUNTS AS(
SELECT COUNT(*) AS "INELIGIBLE_ACCOUNTS"
FROM case_specialists.RECON_NOTES
WHERE RECON_ID = 50
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE
AND PRODUCT_TYPE = 'RLQA'
--and QA_COMPLETED_DATED is null 
)

SELECT (R.RECONCILED_ACCOUNTS + UR.UNRECONCILED_ACCOUNTS + I.INELIGIBLE_ACCOUNTS) AS "TOTAL ACCOUNTS", R.RECONCILED_ACCOUNTS, UR.UNRECONCILED_ACCOUNTS, I.INELIGIBLE_ACCOUNTS,
ROUND((((R.RECONCILED_ACCOUNTS / (R.RECONCILED_ACCOUNTS + (UR.UNRECONCILED_ACCOUNTS /*+ I.INELIGIBLE_ACCOUNTS*/))))*100),0) AS "RECONCILIATION PERCENTAGE"
FROM RECONCILED_ACCOUNTS R, UNRECONCILED_ACCOUNTS UR,INELIGIBLE_ACCOUNTS I
;      
                
 
/*SELECT * 
from case_specialists.RECON_NOTES
--WHERE RECON_FLAG = 'Y'
WHERE RECON_ID IS NOT NULL
--AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE
AND PRODUCT_TYPE = 'RLQA'
AND CASE_ID IN (20297)
 ;*/
 
 
 

------------ RECONCILIATION PERCENTAGE DA LAST 7 DAYS

WITH RECONCILED_ACCOUNTS AS (
select COUNT(*) AS "RECONCILED_ACCOUNTS"
from case_specialists.RECON_NOTES
WHERE RECON_FLAG = 'Y'
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE
AND PRODUCT_TYPE = 'DA'
and QA_COMPLETED_DATED is null 
AND RECON_ID NOT IN( 50, 102)
),
UNRECONCILED_ACCOUNTS AS (
SELECT COUNT(*) AS "UNRECONCILED_ACCOUNTS"
FROM case_specialists.RECON_NOTES
WHERE RECON_FLAG = 'N'
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE
AND PRODUCT_TYPE = 'DA'
and QA_COMPLETED_DATED is null 
AND RECON_ID NOT IN( 50, 102)
),
INELIGIBLE_ACCOUNTS AS(
SELECT COUNT(*) AS "INELIGIBLE_ACCOUNTS"
FROM case_specialists.RECON_NOTES
WHERE RECON_ID = 50
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE
AND PRODUCT_TYPE = 'DA'
and QA_COMPLETED_DATED is null 
)

SELECT (R.RECONCILED_ACCOUNTS + UR.UNRECONCILED_ACCOUNTS + I.INELIGIBLE_ACCOUNTS) AS "TOTAL ACCOUNTS", R.RECONCILED_ACCOUNTS, UR.UNRECONCILED_ACCOUNTS, I.INELIGIBLE_ACCOUNTS,
ROUND((((R.RECONCILED_ACCOUNTS / (R.RECONCILED_ACCOUNTS + (UR.UNRECONCILED_ACCOUNTS /*+ I.INELIGIBLE_ACCOUNTS*/))))*100),0) AS "RECONCILIATION PERCENTAGE"
FROM RECONCILED_ACCOUNTS R, UNRECONCILED_ACCOUNTS UR,INELIGIBLE_ACCOUNTS I
; 





--------- COUNT OF ALL CDR TICKETS YTD
select COUNT (*) 
from jbrown.jira_tasks
where project_name in ('Case Data Request')
and client is not null
and created > '01-JAN-2024'
;




--------- COUNT OF CDR TICKETS CREATED IN THE LAST 7 DAYS
select COUNT (*) 
from jbrown.jira_tasks
where project_name in ('Case Data Request')
and created > SYSDATE - 7
;





---------- DEF due within next 5 days. Based off of due date of ticket
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('Deficiencies')
--and created >= '01-JAN-2022';
and assignee in ('******)
and due_date <= (trunc(sysdate) + 5)
and status not in ('Closed','Done','Resolved')
--AND resolution is null
;





---------- ER Tickets due within next 5 days. Based off of due date of ticket
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('Exception Reporting')
--and created >= '01-JAN-2022';
and assignee in ('******)
and due_date <= (trunc(sysdate) + 5)
and status not in ('Closed','Done','Resolved')
--AND resolution is null
;


----------- CCW Tickets UPDATED OVER 10 days ago
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('CUSIP Client Work')
--and created >= '01-JAN-2022';
and assignee in ('******)
--and due_date <= (trunc(sysdate) + 5)
and UPDATE_DATE < sysdate - 10
and status not in ('Closed','Done','Resolved')
--AND resolution is null
;


------------ CDR due within next 10 days. Based off of due date of ticket
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('Case Data Request 2','Case Data Request')
AND SUMMARY NOT LIKE '%25092%'
AND SUMMARY NOT LIKE '%25516%'
and assignee in ('******)
and due_date <= (trunc(sysdate) + 10)
and status not in ('Closed','Done','Resolved')
--AND resolution is null
;




---------------------------------

-- ETL L10 METRICS COMPLETE

---------------------------------































