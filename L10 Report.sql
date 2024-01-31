/*
X:\Operations\Data Analyst\Case ETL\Level 10 Metrics.xlsx
*/


------------ PFA JIRA Tickets Outstanding Over 20 days prior to Claim Filing Deadline, across entire ETL Case Team
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('Pre Filing Analysis')
AND ISSUE_TYPE NOT IN ('Sub-task')
and assignee in ('andrewtran', 'Elijah Barnes','Tomohiro Miyachi','Sahra Jaamac', 'Marvin Perez', 'Tim Cooley', 'Gabriel Slama')
and CLAIM_DEADLINE <= (trunc(sysdate) + 20)
and status not in ('Closed','Done','Resolved')
;



------------ RLQA JIRA Tickets Outstanding Over 20 days prior to Claim Filing Deadline, across entire ETL Case Team
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('RL QA')
AND ISSUE_TYPE NOT IN ('Sub-task')
and assignee in ('andrewtran', 'Elijah Barnes','Tomohiro Miyachi','Sahra Jaamac', 'Marvin Perez', 'Tim Cooley', 'Gabriel Slama')
and CLAIM_DEADLINE <= (trunc(sysdate) + 20)
and status not in ('Closed','Done','Resolved')
;




------------ DA JIRA Tickets Outstanding Over 20 days prior to Claim Filing Deadline, across entire ETL Case Team
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('Data Anomalies')
AND ISSUE_TYPE NOT IN ('Sub-task')
and assignee in ('andrewtran', 'Elijah Barnes','Tomohiro Miyachi','Sahra Jaamac', 'Marvin Perez', 'Tim Cooley', 'Gabriel Slama')
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
and assignee in ('andrewtran', 'Elijah Barnes','Tomohiro Miyachi','Sahra Jaamac', 'Marvin Perez', 'Tim Cooley', 'Gabriel Slama')
and due_date <= (trunc(sysdate) + 5)
and status not in ('Closed','Done','Resolved')
--AND resolution is null
;





---------- ER Tickets due within next 5 days. Based off of due date of ticket
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('Exception Reporting')
--and created >= '01-JAN-2022';
and assignee in ('andrewtran', 'Elijah Barnes','Tomohiro Miyachi','Sahra Jaamac', 'Marvin Perez', 'Tim Cooley', 'Gabriel Slama')
and due_date <= (trunc(sysdate) + 5)
and status not in ('Closed','Done','Resolved')
--AND resolution is null
;


----------- CCW Tickets UPDATED OVER 10 days ago
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('CUSIP Client Work')
--and created >= '01-JAN-2022';
and assignee in ('andrewtran', 'Elijah Barnes','Tomohiro Miyachi','Sahra Jaamac', 'Marvin Perez', 'Tim Cooley', 'Gabriel Slama')
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
and assignee in ('andrewtran', 'Elijah Barnes','Tomohiro Miyachi','Sahra Jaamac', 'Marvin Perez', 'Tim Cooley', 'Gabriel Slama')
and due_date <= (trunc(sysdate) + 10)
and status not in ('Closed','Done','Resolved')
--AND resolution is null
;




---------------------------------

-- ETL L10 METRICS COMPLETE

---------------------------------


---BELOW ARE OLD OUTDATED SCRIPTS



































/*
X:\Operations\Data Analyst\Case ETL\Level 10 Metrics.xlsx
*/







/****************************************** CDR METRICS
*/

--------- ALL UNRESOLVED TICKETS
select *
from jbrown.jira_tasks
where project_name in ('Case Data Request 2','Case Data Request')
--and created >= '01-JAN-2022';
and reporter in ('Elijah Barnes', 'Gabriel Slama', 'Marvin Perez', 'Tim Cooley', 'andrewtran', 'Stephano Barrios')
--and due_date >= (trunc(sysdate) + 5)
AND resolution is null;



----------- TICKETS PAST DUE DATE
select *
from jbrown.jira_tasks
where project_name in ('Case Data Request 2','Case Data Request')
and reporter in ('Elijah Barnes', 'Gabriel Slama', 'Marvin Perez', 'Tim Cooley', 'andrewtran', 'Stephano Barrios')
and due_date <= (trunc(sysdate))
and resolution is null;


----------- TICKET W/ DUE DATE IN NEXT 5 DAYS
select *
from jbrown.jira_tasks
where project_name in ('Case Data Request 2','Case Data Request')
--and created >= '01-JAN-2022';
and reporter in ('Elijah Barnes', 'Gabriel Slama', 'Marvin Perez', 'Tim Cooley', 'andrewtran', 'Stephano Barrios')
and due_date >= (trunc(sysdate) + 5)
AND resolution is null;







/****************************************** POPULATE L10 CDR METRICS
*/

----------- TICKETS PAST DUE DATE
select KEY, CLIENT, ASSIGNEE, CREATOR, CREATED, DUE_DATE, CLAIM_DEADLINE, PRIORITY
from jbrown.jira_tasks
where project_name in ('Case Data Request 2','Case Data Request')
and reporter in ('Elijah Barnes', 'Gabriel Slama', 'Marvin Perez', 'Tim Cooley', 'andrewtran', 'Stephano Barrios')
and due_date <= (trunc(sysdate))
and resolution is null
ORDER BY DUE_DATE
;


----------- TICKET W/ DUE DATE IN NEXT 5 DAYS
select *
from jbrown.jira_tasks
where project_name in ('Case Data Request 2','Case Data Request')
--and created >= '01-JAN-2022';
and reporter in ('Elijah Barnes', 'Gabriel Slama', 'Marvin Perez', 'Tim Cooley', 'andrewtran', 'Stephano Barrios')
and due_date >= (trunc(sysdate) + 5)
AND resolution is null
;

























------------------------------------------- OTHER METRICS -----------------------------------

--Clients that have not been finished yet or have a CDR created:
--All clients that have atleast one null value for "Completed By" AND No CDR Created
--
SELECT case_id,CASE_SHORT_NAME,filing_claim_deadline_date, PRODUCT_TYPE,
        (filing_claim_deadline_date -  TRUNC(SYSDATE)) "DAYS TILL FILING DEADLINE",
        CASE WHEN
        ((filing_claim_deadline_date - 30) -  TRUNC(SYSDATE)) >= 0 THEN TO_CHAR((filing_claim_deadline_date - 30) -  TRUNC(SYSDATE))
        ELSE 'PAST SLA'
        END AS "DAYS TILL SLA",
        CASE WHEN       
        (filing_claim_deadline_date - 30) -  TRUNC(SYSDATE) < 0 THEN  ABS(((filing_claim_deadline_date - 30) -  TRUNC(SYSDATE)))
        ELSE NULL
        END AS "DAYS PAST SLA",
        "TASK OWNER", "MAIN TICKET", CLIENT_NAME,'THIS CLIENT HAS OUTSTANDING ACCOUNTS AND NO DATA REQUEST HAS BEEN CREATED' AS NOTE
FROM
(
WITH
        OUTSTANDING_CLIENTS AS
        (
select RN.client_name,RN.case_id,RN.product_type,RN.completed_by,JT.ASSIGNEE,RN.JIRA_ID,C.filing_claim_deadline_date,C.CASE_SHORT_NAME--, count(*)
from case_specialists.recon_notes RN, JBROWN.JIRA_TASKS JT, FRT.CASE C
where RN.case_id = C.CASE_ID
AND C.filing_claim_deadline_date >= TRUNC(SYSDATE)
AND  RN.JIRA_ID = JT.KEY(+)
AND RN.COMPLETED_BY IS NULL
group by RN.client_name,RN.case_id,RN.product_type,RN.completed_by, JT.ASSIGNEE,RN.JIRA_ID,C.filing_claim_deadline_date,C.CASE_SHORT_NAME
),
DATA_REQUESTS AS
(
select JTCI.CASE_ID, JT.*
from JBROWN.JIRA_TASKS JT, JBROWN.JIRA_TASK_CASE_ID JTCI
where JT.ID = JTCI.TASK_ID(+)
AND JT.project_name in ('Case Data Request 2','Case Data Request')
and case_id in (select case_id from frt.case where filing_claim_deadline_date >= TRUNC(SYSDATE))
)
SELECT OC.filing_claim_deadline_date,OC.CASE_SHORT_NAME,DR.KEY AS "DATA REQUEST TICKET",DR.ASSIGNEE AS "DATA REQUEST ASSIGNEE",OC.client_name,
                OC.case_id,OC.product_type,OC.completed_by,OC.ASSIGNEE AS "TASK OWNER",OC.JIRA_ID AS "MAIN TICKET"
FROM OUTSTANDING_CLIENTS OC, DATA_REQUESTS DR
WHERE OC.CASE_ID = DR.CASE_ID(+)
AND OC.CLIENT_NAME = DR.CLIENT(+) 
ORDER BY FILING_CLAIM_DEADLINE_DATE
)
WHERE "DATA REQUEST TICKET" IS NULL
;



--INITAL RLQA REVIEW COMPLETED DURING WEEK                
select 
rn.case_id,
c.FILING_CLAIM_DEADLINE_DATE,
rn.client_name,
rn.account_id,
rn.product_type,
rn.recon_flag,
rd.recon_description,
rn.create_date,
rn.completed_date,
rn.qa_completed_dated,
rn.jira_id
        from CASE_SPECIALISTS.RECON_NOTES rn
        left join CASE_SPECIALISTS.RECON_DESCRIPTION rd
                on rn.recon_id = rd.recon_id
        left join frt.case c
                on c.case_id = rn.case_id
        where
                product_type = 'RLQA'
                --and JIRA_ID is not null 
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE               
 AND COMPLETED_BY NOT IN ('HPHAM','MKWAK','ZKRUGMAN')
order by c.FILING_CLAIM_DEADLINE_DATE;
                
             
                
                
                
                
                
                
                
--2. Initial Data Recon Complete (WEEKLY) - PFA
select 
rn.case_id,
c.FILING_CLAIM_DEADLINE_DATE,
rn.client_name,
rn.account_id,
rn.product_type,
rn.recon_flag,
rd.recon_description,
rn.create_date,
rn.completed_date,
rn.qa_completed_dated,
rn.jira_id

        from CASE_SPECIALISTS.RECON_NOTES rn
        left join CASE_SPECIALISTS.RECON_DESCRIPTION rd
                on rn.recon_id = rd.recon_id
        left join frt.case c
                on c.case_id = rn.case_id
        where
                product_type = 'PFA'
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE
                and QA_COMPLETED_DATED is null 
                order by c.FILING_CLAIM_DEADLINE_DATE;
                
                
        
                
                
                
                
                
                
--2. Initial Data Recon Complete (WEEKLY) - DA
select 
rn.case_id,
c.FILING_CLAIM_DEADLINE_DATE,
rn.client_name,
rn.account_id,
rn.product_type,
rn.recon_flag,
rd.recon_description,
rn.create_date,
rn.completed_date,
rn.qa_completed_dated,
rn.jira_id
        from CASE_SPECIALISTS.RECON_NOTES rn
        left join CASE_SPECIALISTS.RECON_DESCRIPTION rd
                on rn.recon_id = rd.recon_id
        left join frt.case c
                on c.case_id = rn.case_id
        where
                product_type = 'DA'
AND COMPLETED_DATE BETWEEN SYSDATE - 7 AND SYSDATE  
                and QA_COMPLETED_DATED is null 
                order by c.FILING_CLAIM_DEADLINE_DATE;

--Outstanding Tasks
select C.filing_claim_deadline_date,C.CASE_SHORT_NAME,RN.CASE_ID,RN.PRODUCT_TYPE,RN.PRODUCT_TYPE,RN.COMPLETED_BY,JIRA_ID,JT.ASSIGNEE
from case_specialists.RECON_NOTES RN, FRT.CASE C,JBROWN.JIRA_TASKS JT
--WHERE RN.PRODUCT_TYPE = 'PFA'
where RN.CASE_ID = C.CASE_ID
AND JT.KEY = RN.JIRA_ID
AND C.filing_claim_deadline_date >= TRUNC(SYSDATE)
and (rn.COMPLETED_BY NOT IN ('EBARNES','HPHAM','MKWAK','ZKRUGMAN') OR RN.COMPLETED_BY IS NULL)
AND JT.ASSIGNEE <> 'Alex Sahagian'
GROUP BY RN.CASE_ID,RN.PRODUCT_TYPE,RN.COMPLETED_BY,C.filing_claim_deadline_date,C.CASE_SHORT_NAME,JIRA_ID,JT.ASSIGNEE
order by C.filing_claim_deadline_date

;
                


                
--Clients that have not been finished yet or have a CDR created:

--All clients that have atleast one null value for "Completed By" AND No CDR Created
--

SELECT case_id,CASE_SHORT_NAME,filing_claim_deadline_date, PRODUCT_TYPE,
        (filing_claim_deadline_date -  TRUNC(SYSDATE)) "DAYS TILL FILING DEADLINE",
        CASE WHEN
        
        ((filing_claim_deadline_date - 30) -  TRUNC(SYSDATE)) >= 0 THEN TO_CHAR((filing_claim_deadline_date - 30) -  TRUNC(SYSDATE))
        ELSE 'PAST SLA'
        END AS "DAYS TILL SLA",
        
        CASE WHEN       
        (filing_claim_deadline_date - 30) -  TRUNC(SYSDATE) < 0 THEN  ABS(((filing_claim_deadline_date - 30) -  TRUNC(SYSDATE)))
        ELSE NULL        
        END AS "DAYS PAST SLA",
        
        "TASK OWNER", "MAIN TICKET", CLIENT_NAME,'THIS CLIENT HAS OUTSTANDING ACCOUNTS AND NO DATA REQUEST HAS BEEN CREATED' AS NOTE
FROM
(

WITH
        OUTSTANDING_CLIENTS AS
        (
select RN.client_name,RN.case_id,RN.product_type,RN.completed_by,JT.ASSIGNEE,RN.JIRA_ID,C.filing_claim_deadline_date,C.CASE_SHORT_NAME--, count(*)
from case_specialists.recon_notes RN, JBROWN.JIRA_TASKS JT, FRT.CASE C
where RN.case_id = C.CASE_ID
AND C.filing_claim_deadline_date >= TRUNC(SYSDATE)
AND  RN.JIRA_ID = JT.KEY(+)
AND RN.COMPLETED_BY IS NULL
group by RN.client_name,RN.case_id,RN.product_type,RN.completed_by, JT.ASSIGNEE,RN.JIRA_ID,C.filing_claim_deadline_date,C.CASE_SHORT_NAME
),

DATA_REQUESTS AS
(
select JTCI.CASE_ID, JT.*
from JBROWN.JIRA_TASKS JT, JBROWN.JIRA_TASK_CASE_ID JTCI
where JT.ID = JTCI.TASK_ID(+)
AND JT.project_name in ('Case Data Request 2','Case Data Request')
and case_id in (select case_id from frt.case where filing_claim_deadline_date >= TRUNC(SYSDATE))
)

SELECT OC.filing_claim_deadline_date,OC.CASE_SHORT_NAME,DR.KEY AS "DATA REQUEST TICKET",DR.ASSIGNEE AS "DATA REQUEST ASSIGNEE",OC.client_name,
                OC.case_id,OC.product_type,OC.completed_by,OC.ASSIGNEE AS "TASK OWNER",OC.JIRA_ID AS "MAIN TICKET"
FROM OUTSTANDING_CLIENTS OC, DATA_REQUESTS DR
WHERE OC.CASE_ID = DR.CASE_ID(+)
AND OC.CLIENT_NAME = DR.CLIENT(+) 
ORDER BY FILING_CLAIM_DEADLINE_DATE

)
WHERE "DATA REQUEST TICKET" IS NULL
;


--volume of each task type per team member
SELECT assignee, project_name,count (project_name)
FROM JBROWN.JIRA_TASKS
WHERE (ASSIGNEE IN ('Elijah Barnes', 'Gabriel Slama', 'Marvin Perez', 'Tim Cooley', 'andrewtran', 'Stephano Barrios'))
and status not in ('Closed','Done','Resolved')
group by assignee,project_name
;


/*
WITH QA_CDR AS

(
SELECT *
FROM JBROWN.JIRA_TASKS
WHERE (SUMMARY LIKE 'QA -%'  AND ISSUE_TYPE = 'Sub-task')
AND (ASSIGNEE IN ('Elijah Barnes', 'Gabriel Slama', 'Marvin Perez', 'Tim Cooley', 'andrewtran', 'Stephano Barrios'))
and status not in ('Closed','Done','Resolved')
);
SUMMARY LIKE 'DATA REQUEST%') 
SELECT * --NVL(SUBSTR("KEY", 0, INSTR("KEY", '-')-1), "KEY") AS output
FROM JBROWN.JIRA_TASKS
--WHERE (PROJECT_NAME IN ('Data Anomalies', 'RL QA', 'Pre Filing Analysis'))
WHERE (ASSIGNEE IN ('Elijah Barnes', 'Gabriel Slama', 'Marvin Perez', 'Tim Cooley', 'andrewtran', 'Stephano Barrios'));
and status not in ('Closed','Done','Resolved')
WHERE 
;
*/


--Tickets for Upcoming Domestic Deadlines
SELECT C.CASE_ID,C.CASE_SHORT_NAME, C.filing_claim_deadline_date, JT.PROJECT_NAME, JT.KEY, JT.ASSIGNEE,STATUS
FROM JBROWN.JIRA_TASKS JT, JBROWN.JIRA_TASK_CASE_ID JTCI, FRT.CASE C
where JT.ID = JTCI.TASK_ID(+)
AND JTCI.CASE_ID = C.CASE_ID
AND C.filing_claim_deadline_date >= TRUNC(SYSDATE)
AND (JT.PROJECT_NAME IN ('CUSIP Client Work', 'Pre Filing Analysis', 'RL QA', 'Data Anomalies'))
AND UPPER(SUMMARY) NOT LIKE '%RUN SET%'
and status not in ('Closed','Done','Resolved')
ORDER BY FILING_CLAIM_DEADLINE_DATE

;

select *
from  JBROWN.JIRA_TASKS
WHERE (ASSIGNEE IN ('Elijah Barnes', 'Gabriel Slama', 'Marvin Perez', 'Tim Cooley', 'andrewtran', 'Stephano Barrios'))
and status <> 'Closed'
;


--2. Initial Data Recon Complete (WEEKLY)
select 
rn.case_id,
c.FILING_CLAIM_DEADLINE_DATE,
rn.client_name,
rn.account_id,
rn.product_type,
rn.recon_flag,
rd.recon_description,
rn.completed_by,
rn.completed_date,
rn.create_date,
rn.qa_completed_dated,
rn.jira_id

        from CASE_SPECIALISTS.RECON_NOTES rn
        left join CASE_SPECIALISTS.RECON_DESCRIPTION rd
                on rn.recon_id = rd.recon_id
        left join frt.case c
                on c.case_id = rn.case_id
        --where
                --product_type = 'PFA'
                where COMPLETED_DATE BETWEEN to_date('11/29/2021','MM/DD/YYYY') and to_date('12/03/2021','MM/DD/YYYY')
                and QA_COMPLETED_DATED is null 
                order by c.FILING_CLAIM_DEADLINE_DATE;
                

select product_type,completed_by,count(completed_by)
from CASE_SPECIALISTS.RECON_NOTES
where COMPLETED_DATE BETWEEN to_date('11/29/2021','MM/DD/YYYY') and to_date('12/03/2021','MM/DD/YYYY')
group by product_type,completed_by
;


--outstanding DAs to make
SELECT DISTINCT CASE_ID,CASE_SHORT_NAME,FRT_STATUS,CASE_STATUS,FILING_CLAIM_DEADLINE_DATE
FROM FRT.CASE
WHERE FILING_CLAIM_DEADLINE_DATE >= TRUNC(SYSDATE)
AND FRT_STATUS <> 'INACTIVE'
AND FRT_EDITS = 3

MINUS

SELECT C.CASE_ID,C.CASE_SHORT_NAME,FRT_STATUS,CASE_STATUS, C.filing_claim_deadline_date--, JT.PROJECT_NAME, JT.KEY, JT.ASSIGNEE,STATUS
FROM JBROWN.JIRA_TASKS JT, JBROWN.JIRA_TASK_CASE_ID JTCI, FRT.CASE C
where JT.ID = JTCI.TASK_ID(+)
AND JTCI.CASE_ID = C.CASE_ID
AND C.filing_claim_deadline_date >= TRUNC(SYSDATE)
AND (JT.PROJECT_NAME IN ('Data Anomalies'))
ORDER BY FILING_CLAIM_DEADLINE_DATE
;


SELECT DISTINCT CASE_ID,CASE_SHORT_NAME,FRT_STATUS,CASE_STATUS,FILING_CLAIM_DEADLINE_DATE
FROM FRT.CASE
WHERE FILING_CLAIM_DEADLINE_DATE >= TRUNC(SYSDATE)
AND FRT_STATUS <> 'INACTIVE'
AND FRT_EDITS = 3;


MINUS

SELECT DISTINCT C.CASE_ID,C.CASE_SHORT_NAME,C.FRT_STATUS,C.CASE_STATUS,FILING_CLAIM_DEADLINE_DATE
FROM CASE_SPECIALISTS.RECON_NOTES RN, FRT.CASE C
WHERE RN.PRODUCT_TYPE = 'DA'
AND RN.CASE_ID = C.CASE_ID
;












