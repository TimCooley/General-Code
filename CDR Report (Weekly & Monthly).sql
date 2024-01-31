
--******************************************************************************************************************
---------------------------------------------- MAIN CDR TRACKING ----------------------------------------------
--******************************************************************************************************************


-------------------------------------------- CASE TYPE

SELECT DISTINCT CM.CASE_ID,C.COMPLAINT_SHORT_NAME,CTL.COMPLAINT_TYPE, C.PARTICIPATION_TYPE
FROM CASE_MASTER.case_complaint_mapping CM, CASE_MASTER.COMPLAINT_TYPE_LOOKUP CTL, CASE_MASTER.COMPLAINT C
WHERE CM.CASE_ID IN ( 24045, 18896, 17258, 19593)
AND CTL.COMPLAINT_TYPE_ID = C.COMPLAINT_TYPE_ID
AND CM.COMPLAINT_ID = C.COMPLAINT_ID
;


--------------------------------------------  ALL CURRENT GLOBAL CASES 

select *
from (
Select  C.case_ID, C.CASE_NAME,C.FILING_CLAIM_DEADLINE_DATE,CC.processed_date,CC.CASE_STATUS,CC.PARTICIPATION_STATUS, rank() over (partition by CC.case_id order by cC.processed_date desc) rnk
FROM CASE C, CASE_MASTER.CASE_CHANGES CC
--WHERE CASE_ID = &CASE_ID_VAR
where C.case_name like ('%Master Case%')
and C.frt_edits = 3
AND C.FRT_STATUS = 'ACTIVE'
AND C.CASE_ID = CC.CASE_ID
and C.country_code not in ('US','CA')
AND C.UPDATE_DATE > SYSDATE -180
--GROUP BY C.CASE_ID
order by C.UPDATE_date desc
)
where rnk = 1
;



--------------------------------------------  ALL FUTURE CASES

Select case_ID, CASE_NAME,FILING_CLAIM_DEADLINE_DATE, PARTICIPATION
FROM CASE
--WHERE FILING_CLAIM_DEADLINE_DATE >= round (SYSDATE)-- and FILING_CLAIM_DEADLINE_DATE <= ROUND (SYSDATE) +90
--WHERE (CASE_ID IN (25236, 20822, 23513, 24998, 15853))
ORDER BY FILING_CLAIM_DEADLINE_DATE
;





--------- CDR TICKETS PAST CFD THAT NEED TO BE CLOSED

select key,case_id,summary,claim_deadline,assignee,status, UPDATE_DATE, due_date
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID ci
where project_name in ('Case Data Request')
AND STATUS NOT IN ( 'Done')
AND (CLAIM_DEADLINE < SYSDATE - 1)
and JT.ID = CI.TASK_ID
AND CASE_ID  NOT IN (25092,25516) --------------FF
AND CI.CASE_ID NOT IN (
select CASE_ID
from (
Select  C.case_ID, C.CASE_NAME,C.FILING_CLAIM_DEADLINE_DATE,Cc.processed_date,CC.CASE_STATUS,CC.PARTICIPATION_STATUS, rank() over (partition by CC.case_id order by cC.processed_date desc) rnk
FROM CASE C, CASE_MASTER.CASE_CHANGES CC
where C.case_name like ('%Master Case%')
and C.frt_edits = 3
AND C.FRT_STATUS = 'ACTIVE'
AND C.CASE_ID = CC.CASE_ID
and C.country_code not in ('US','CA')
AND C.UPDATE_DATE > SYSDATE -180)
)
order by claim_deadline
;







--*********************************************************************
---------------------------- START OF WEEKLY CDR REPORT 
--*********************************************************************












--------- COUNT OF ALL CDR TICKETS EVER
select COUNT (*) 
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID CI
where project_name in ('Case Data Request')
and JT.ID = CI.TASK_ID
and client is not null
;

--------- COUNT OF ALL CLOSED CDR TICKETS EVER
select COUNT (*) 
from jbrown.jira_tasks
where project_name in ('Case Data Request')
and client is not null
AND STATUS IN ('Done')
;

--------- COUNT CDR TICKETS CREATED YTD
select COUNT (*)   
from jbrown.jira_tasks
where project_name in ('Case Data Request')
and client is not null
and created > '01-JAN-2024'
;

--------- COUNT OF ALL CLOSED CDR TICKETS YTD
select COUNT (*) 
from jbrown.jira_tasks
where project_name in ('Case Data Request')
and client is not null
AND STATUS IN ('Done')
and created > '01-JAN-2024'
;

--------- COUNT OF ALL CDR TICKETS CREATED IN THE LAST 7 DAYS
select COUNT (*) 
from jbrown.jira_tasks
where project_name in ('Case Data Request')
--and SUMMARY NOT LIKE '%Master%'
and created > SYSDATE - 7
;



--------- COUNT OF ALL OPEN CDR ASSIGNED TO DI TEAM
select COUNT (*) 
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID CI
where project_name in ('Case Data Request')
AND STATUS NOT IN ( 'Done')
and client is not null
AND (ASSIGNEE IN ('******)) --- DI TEAM
AND CI.CASE_ID NOT IN (25516,25092)--------------FF
and JT.ID = CI.TASK_ID
order by created
;



--------- COUNT OF ALL "TO DO" CDR ASSIGNED TO DI
select COUNT (*)
from jbrown.jira_tasks
where project_name in ('Case Data Request')
and client is not null
--AND (ASSIGNEE IN (*****))-- ETL TEAM
AND (ASSIGNEE IN (******)) --- DI TEAM
AND STATUS = 'To Do'
--AND DUE_DATE <= SYSDATE - 1
;




--------- DOMESTIC NOT STARTED OVER DUE & ASSIGNED TO DI TEAM
--------- THIS RESULT GETS EXPORTED TO EXCEL & INSERTED INTO SECOND TAB "PRIORITY CDRS"

select KEY, CASE_ID, summary,CLAIM_DEADLINE, ASSIGNEE, STATUS, due_date,round (sysdate - created) as "DAYS SINCE CREATION"
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID CI
where project_name in ('Case Data Request')
and client is not null
AND (ASSIGNEE IN (******)) --- DI TEAM
AND STATUS = 'To Do'
AND (DUE_DATE <= SYSDATE)-- or DUE_DATE >= SYSDATE )
and JT.ID = CI.TASK_ID
and CLAIM_DEADLINE >= SYSDATE -1
AND CI.CASE_ID NOT IN (
select CASE_ID
from (
Select  C.case_ID, C.CASE_NAME,C.FILING_CLAIM_DEADLINE_DATE,Cc.processed_date,CC.CASE_STATUS,CC.PARTICIPATION_STATUS, rank() over (partition by CC.case_id order by cC.processed_date desc) rnk
FROM CASE C, CASE_MASTER.CASE_CHANGES CC
where C.case_name like ('%Master Case%')
and C.frt_edits = 3
AND C.FRT_STATUS = 'ACTIVE'
AND C.CASE_ID = CC.CASE_ID
and C.country_code not in ('US','CA')
AND C.UPDATE_DATE > SYSDATE -180)
)
order by CLAIM_DEADLINE
;







--------- OPEN DOMESTIC CDRS WITH CLAIM DEADLINE IN THE NEXT 14 DAYS & ASSIGNED TO DI TEAM
--------- THIS RESULT GETS EXPORTED TO EXCEL & INSERTED INTO SECOND TAB "PRIORITY CDRS"

select key,case_id,summary,claim_deadline,assignee,status, due_date, round (sysdate - created) as "DAYS SINCE CREATION"
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID CI
where project_name in ('Case Data Request')
and client is not null
AND (ASSIGNEE IN (******)) --- DI TEAM
AND STATUS not in 'Done'
AND (CLAIM_DEADLINE <= SYSDATE + 14 and CLAIM_DEADLINE >= SYSDATE -1)
and JT.ID = CI.TASK_ID
AND CI.CASE_ID NOT IN (
select CASE_ID
from (
Select  C.case_ID, C.CASE_NAME,C.FILING_CLAIM_DEADLINE_DATE,Cc.processed_date,CC.CASE_STATUS,CC.PARTICIPATION_STATUS, rank() over (partition by CC.case_id order by cC.processed_date desc) rnk
FROM CASE C, CASE_MASTER.CASE_CHANGES CC
where C.case_name like ('%Master Case%')
and C.frt_edits = 3
AND C.FRT_STATUS = 'ACTIVE'
AND C.CASE_ID = CC.CASE_ID
and C.country_code NOT in ('US','CA')
AND C.UPDATE_DATE > SYSDATE -180)
)
order by claim_deadline 
;



-------- OPEN CDRS FOR CURRENT GLOBAL CASE
--------- THIS RESULT GETS EXPORTED TO EXCEL & INSERTED INTO SECOND TAB "PRIORITY CDRS"

select key, CASE_ID,summary,claim_deadline,assignee,status, due_date, round (sysdate - created) as "DAYS SINCE CREATION"
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID CI
where project_name in ('Case Data Request')
AND STATUS NOT IN ( 'Done')
AND (ASSIGNEE IN (******)) --- DI TEAM
AND CI.CASE_ID IN (
select CASE_ID
from (
Select  C.case_ID, C.CASE_NAME,C.FILING_CLAIM_DEADLINE_DATE,Cc.processed_date,CC.CASE_STATUS,CC.PARTICIPATION_STATUS, rank() over (partition by CC.case_id order by cC.processed_date desc) rnk
FROM CASE C, CASE_MASTER.CASE_CHANGES CC
where C.case_name like ('%Master Case%')
and C.frt_edits = 3
AND C.FRT_STATUS = 'ACTIVE'
AND C.CASE_ID = CC.CASE_ID
and C.country_code not in ('US','CA')
AND C.UPDATE_DATE > SYSDATE -180)
)
and JT.ID = CI.TASK_ID
order by CREATED
;




--------- ALL FAIR FUND CDR ASSIGNED TO DI TEAM
--------- THIS RESULT GETS EXPORTED TO EXCEL & INSERTED INTO SECOND TAB "PRIORITY CDRS"

select key,case_id,summary,claim_deadline,assignee,status, due_date, round (sysdate - created) as "DAYS SINCE CREATION"
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID CI
where project_name in ('Case Data Request')
AND STATUS NOT IN ( 'Done')
and client is not null
AND (ASSIGNEE IN (******)) --- DI TEAM
AND CI.CASE_ID IN (25573)--------------FF
and JT.ID = CI.TASK_ID
order by created
;











--------- CDR TOP 10 CLIENTS BY VOLUME YTD
select client, count  (client)
from jbrown.jira_tasks
where project_name in ('Case Data Request')
and created > '01-JAN-2024'
group by client
order by COUNT(CLIENT) DESC
FETCH FIRST 10 ROWS ONLY
;


--------- CDR TOP 20 CLIENTS BY VOLUME ALL TIME
select client, count  (client)
from jbrown.jira_tasks
where project_name in ('Case Data Request')
group by client
order by COUNT(CLIENT) DESC
FETCH FIRST 20 ROWS ONLY
;













------------------------ CCW TRACKING SECTION

--------- ALL OPEN CCW 
select COUNT (distinct key) 
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID CI
where project_name in ('CUSIP Client Work')
AND STATUS not in ('Done', 'Closed','Resolved')
and JT.ID = CI.TASK_ID
order by key
;




--------- OPEN CCW WITH EXPIRED CLAIM FILING DEADLINE 
--------- THIS RESULT GETS EXPORTED TO EXCEL & INSERTED INTO THIRD TAB "CCW WEEKLY"

select DISTINCT jt.key ,jt.summary,MIN (FILING_CLAIM_DEADLINE_Date) over (partition by key) as "FIRST_UPCOMING_CLAIM_FILING_DEADLINE" ,jt.assignee,jt.status,  round (sysdate - jt.update_date) as "DAYS_SINCE_UPDATED", round (sysdate - jt.created) as "DAYS_SINCE_CREATION"
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID CI, frt.case c
where project_name in ('CUSIP Client Work')
and c.case_id = ci.case_id
and c.FILING_CLAIM_DEADLINE_Date < trunc(sysdate)
and c.FILING_CLAIM_DEADLINE_Date > '1-JAN-2023'
AND C.FRT_EDITS = '3'
AND STATUS not in ('Done', 'Closed','Resolved')
and JT.ID = CI.TASK_ID
AND C.FILING_CLAIM_DEADLINE_DATE > SYSDATE - 90
order BY FIRST_UPCOMING_CLAIM_FILING_DEADLINE
;



--------- OPEN CCW WITH CLAIM FILING DEADLINE IN THE NEXT 14 DAYS
--------- THIS RESULT GETS EXPORTED TO EXCEL & INSERTED INTO THIRD TAB "CCW WEEKLY"

select  DISTINCT JT.key ,JT.summary,MIN (FILING_CLAIM_DEADLINE_Date) over (partition by key) as "FIRST_UPCOMING_CLAIM_FILING_DEADLINE" ,JT.assignee,JT.status,  round (sysdate - JT.update_date) as "DAYS_SINCE_UPDATED",round (sysdate - JT.created) as "DAYS_SINCE_CREATION"
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID CI, FRT.CASE C
where project_name in ('CUSIP Client Work')
AND STATUS not in ('Done', 'Closed','Resolved')
AND C.CASE_ID = CI.CASE_ID
AND C.FILING_CLAIM_DEADLINE_DATE <= SYSDATE +14
AND C.FILING_CLAIM_DEADLINE_DATE >= TRUNC(SYSDATE)
AND C.FRT_EDITS = '3'
and JT.ID = CI.TASK_ID
order BY FIRST_UPCOMING_CLAIM_FILING_DEADLINE

;





------------------------ RECON NOTES TABLE CDR TRACKING 

-- CDR TRACKING FROM THE RECON NOTES TABLE IS MOST ACCURATE AFTER 10/01/22
-- RECON NOTES TABLES DOES NOT INCLUDE GLOBAL CASES
-- RECORD BEFORE 10/01/22 HAVE A STANDARD DEVIATION OF AROUND 30%


---------------------- 1. COUNT OF ACCOUNT_IDs REQUESTED PER CLIENT YTD

select RN.CLIENT_NAME, /**//*RN.ACCOUNT_ID,*//* */COUNT (ACCOUNT_ID) AS "ACCOUNT_IDS_REQUESTED"
from case_specialists.RECON_NOTES RN
WHERE RN.CDR_CREATED = 'Y'
--and CLIENT_NAME IN ('******')
and COMPLETED_DATE > '01-JAN-2024'
AND CASE_ID NOT IN (25573,25092,25516) ---- FF
GROUP BY RN.CLIENT_NAME/*,RN.ACCOUNT_ID*/
ORDER BY ACCOUNT_IDS_REQUESTED DESC
;
/*

------------- 2. NUMBER OF ACCOUNT_IDs MADE PER CDR YTD

SELECT CLIENT_NAME, PRODUCT_TYPE, CASE_ID, COUNT ( ACCOUNT_ID) AS "ACCTS_IN_CDR", TRUNC(CREATE_DATE) AS "CREATE_DATE" 
FROM case_specialists.RECON_NOTES RN
WHERE RN.CDR_CREATED = 'Y'
--AND CLIENT_NAME IN ('******')
AND RECON_ID IS NOT NULL AND PRODUCT_TYPE IS NOT NULL AND CREATE_DATE IS NOT NULL
and COMPLETED_DATE > '01-JAN-2024'
AND CASE_ID NOT IN (25573,25092,25516) ---- FF
AND PRODUCT_TYPE IN ('PFA', 'RLQA','DA')
GROUP BY CLIENT_NAME, PRODUCT_TYPE, CASE_ID, TRUNC(CREATE_DATE)
--ORDER BY COUNT ( ACCOUNT_ID) DESC
ORDER BY TRUNC(CREATE_DATE) DESC
;

*/


------------------------------------- 3. COUNT OF CDRS MADE PER ACCOUNT_NUMBER YTD
-- ADD DATA PROVIDER FOR EACH ACCOUNT NUMBER


WITH A AS(
SELECT DISTINCT RN.CLIENT_NAME, RN.CASE_ID,RN.ACCOUNT_ID, AC.CLIENT_REF_NUMBER/*,A.NAME*/
from case_specialists.RECON_NOTES RN, FRT.ACCOUNT AC
WHERE RN.CDR_CREATED = 'Y'
AND AC.ACCOUNT_ID = RN.ACCOUNT_ID 
and RN.COMPLETED_DATE > '01-JAN-2024'
),
B AS(
SELECT  A.CLIENT_NAME, AC.CLIENT_REF_NUMBER, /*AC.NAME, */
case when ((ac.name like '%INTERNAL%' or ac.name like '%Internal%') and ac.name not in ('******')) or short_name like '%******%' then '******'
when (ac.NAME IN ('******', '******', '******')) then '******'
when short_name like '%******%' or ac.name like '%******%' then 'INTERNAL_CLIENT'
when ac.name in ('******', '******', '******', '****** ****** ******', '****** ****** ******') then 'US ******'
when ac.name in ('******','******') then '******'
when ac.name in ('****** ****** TRANSACTIONS REFRESH',  '****** Data Upload Client') then '******'
when ac.name in ('******','******') then '******'
when ac.name in ( '******', '****** ****** Services') then '******'
when  substr(ac.name,0,3) = '******' or short_name = '******' or ac.name = '******' then '******'
when ac.name like '%******%' or ac.name like '%******%' then '******'
when (ac.name like '%******%' or ac.name like '%******%') then '****** TRUST'
when ((substr(ac.CLIENT_REF_NUMBER,0,2) = 'P ' or substr(ac.CLIENT_REF_NUMBER,0,2) = 'S '  and length(ac.CLIENT_REF_NUMBER) = 7)) or ((substr(ac.CLIENT_REF_NUMBER,0,1) = 'E' and length(ac.CLIENT_REF_NUMBER) = 5)) then '******'
-- when (length(a.account_number) = 7  or length(a.account_number) = 9) and REGEXP_LIKE(a.account_number, '^[[:digit:]]+$') then '******'
when length(ac.CLIENT_REF_NUMBER) = 4 then '******'
when substr(ac.CLIENT_REF_NUMBER,4,1) = 'F' and substr(ac.CLIENT_REF_NUMBER,-1) = '2'  or ac.CLIENT_REF_NUMBER = 'AGGREGATE' then '******'
-- when length(a.account_number) = 6   then '******'  
WHEN ac.NAME like ('%******%') or ac.name like '%******%' or ac.name like '%******%' then '******'
else 'INTERNAL_CLIENT_OR_UNKNOWN' end   
as likely_data_source_name

FROM A.A,FRT.ACCOUNT AC
WHERE AC.ACCOUNT_ID = A.ACCOUNT_ID 
)
SELECT DISTINCT A.CLIENT_NAME,A.CLIENT_REF_NUMBER,B.LIKELY_DATA_SOURCE_NAME,COUNT (DISTINCT A.CASE_ID) AS "TOTAL_REQUESTS"
FROM A,B
WHERE A.CLIENT_NAME <> '******'--- EXCLUDED FOR RUN TIME
AND A.CLIENT_REF_NUMBER = B.CLIENT_REF_NUMBER
GROUP BY A.CLIENT_NAME, A.CLIENT_REF_NUMBER,B.LIKELY_DATA_SOURCE_NAME
ORDER BY TOTAL_REQUESTS DESC
;






--*********************************************************************
---------------------------- END OF WEEKLY CDR REPORT 
--*********************************************************************





















--*********************************************************************
---------------------------------------------- START OF MONTHLY CDR REPORT
--*********************************************************************
/*
	1. Count of clients that required at least 1 CDR in the month
	2. Average CDRs per Case for the month
	3. CDRs on time fulfillment rate for the month
	4. Open CDRs assigned to AM (whatever frequency is best)
	5. Open CDRs assigned to CDM (whatever frequency is best)
 
*/


------------------------------------------1. Count of clients that required at least 1 CDR in the month

select DISTINCT CLIENT AS "Distinct Clients Reached Out to in the Last 30 Days"
from jbrown.jira_tasks
where project_name in ('Case Data Request')
--AND SUMMARY NOT LIKE '%Master Case%'
and created > SYSDATE - 30
ORDER BY CLIENT
;




------------------------------------------2. Average CDRs per Case for the month ** BASED OFF OF CFD DATE**

WITH CDR_COUNT AS(
select COUNT (*) AS "CDRS_LAST_MONTH"
from jbrown.jira_tasks
where project_name in ('Case Data Request')
AND SUMMARY NOT LIKE '%Master Case%'
and created > SYSDATE - 35
--AND CLIENT IN (&CLIENT_NAME_VAR)
),
CASE_COUNT AS(
SELECT COUNT (DISTINCT FILING_CLAIM_DEADLINE_DATE) AS "CASES_LAST_MONTH"
FROM frt.case
WHERE CASE_STATUS||FRT_STATUS IN ('SETTLEDACTIVE', 'DISBURSEMENTDISBURSED')
AND FRT_EDITS = 3
and country_code in ('US','CA')
AND case_name NOT like ('%Master Case%')
AND FILING_CLAIM_DEADLINE_DATE  < SYSDATE 
AND FILING_CLAIM_DEADLINE_DATE  > SYSDATE - 30 -- 30 DAYS AGO
)
SELECT CDRS_LAST_MONTH,CASES_LAST_MONTH, ROUND((CDRS_LAST_MONTH / CASES_LAST_MONTH),1) AS "AVG CDR PER CASE"
FROM CDR_COUNT, CASE_COUNT
;


------------------------------------------ 2. Total CDRs in Respect to Case Vol & All CDR Vol. GLOBAL AND DOMESTIC


--DISBURSION OF CDRs BY MONTH
WITH A AS (
SELECT DISTINCT EXTRACT(YEAR FROM CREATED) AS YY, EXTRACT(MONTH FROM CREATED) AS MM,COUNT(*) AS CNT
FROM jbrown.jira_tasks
WHERE (PROJECT_NAME IN ('Case Data Request'))
and client is not null
--AND CLIENT = &CLIENT_NAME_VAR -------- CLIENT NAME
AND SUMMARY NOT LIKE '%Master%' -------------- DOMESTIC ONLY
AND EXTRACT(YEAR FROM CREATED)<=EXTRACT(YEAR FROM TRUNC(SYSDATE))
 GROUP BY EXTRACT(YEAR FROM CREATED) , EXTRACT(MONTH FROM CREATED)       
)SELECT  YY,SUM(DECODE(MM,1,CNT)) "JAN",SUM(DECODE(MM,2,CNT)) "FEB",SUM(DECODE(MM,3,CNT)) "MAR", SUM(DECODE(MM,4,CNT)) "APR", SUM(DECODE(MM,5,CNT)) "MAY", SUM(DECODE(MM,6,CNT)) "JUN",SUM(DECODE(MM,7,CNT)) "JUL",SUM(DECODE(MM,8,CNT)) "AUG",SUM(DECODE(MM,9,CNT)) "SEP",SUM(DECODE(MM,10,CNT)) "OCT",SUM(DECODE(MM,11,CNT)) "NOV",SUM(DECODE(MM,12,CNT)) "DEC",SUM(DECODE(YY,MM,1,CNT,YY,MM,2,CNT)) "YY TOTAL"       
FROM A 
GROUP BY YY
ORDER BY YY;


-- DISBURSION OF DOMESTIC CASES BY VOLUME AND DATE
/*
INTERCHANGE THE FOLLOWING VARIABLES TO FIND NUMBER OF ____ IN EACH MONTH
SETTLEMENT_DATE
FILING_CLAIM_DEADLINE_DATE
FILING_CLAIM_DEADLINE_DATE - 30   = SLA DATE
*/
WITH A AS (
SELECT DISTINCT EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE) AS YY, EXTRACT(MONTH FROM FILING_CLAIM_DEADLINE_DATE) AS MM,COUNT(*) AS CNT
            FROM frt.case
            WHERE CASE_STATUS||FRT_STATUS IN ('SETTLEDACTIVE', 'DISBURSEMENTDISBURSED')
AND FILING_CLAIM_DEADLINE_DATE IS NOT NULL
AND FRT_EDITS = 3
AND PARTICIPATION = 'OPT_OUT'            
            AND FILING_CLAIM_DEADLINE_DATE >'1-AUG-2021' 
            AND FILING_CLAIM_DEADLINE_DATE < SYSDATE 
AND EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE)<=EXTRACT(YEAR FROM TRUNC(SYSDATE+365))
            GROUP BY EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE) , EXTRACT(MONTH FROM FILING_CLAIM_DEADLINE_DATE)
        
        )
SELECT  YY,SUM(DECODE(MM,1,CNT)) "JAN",SUM(DECODE(MM,2,CNT)) "FEB",SUM(DECODE(MM,3,CNT)) "MAR", SUM(DECODE(MM,4,CNT)) "APR", SUM(DECODE(MM,5,CNT)) "MAY", SUM(DECODE(MM,6,CNT)) "JUN",SUM(DECODE(MM,7,CNT)) "JUL",SUM(DECODE(MM,8,CNT)) "AUG",SUM(DECODE(MM,9,CNT)) "SEP",SUM(DECODE(MM,10,CNT)) "OCT",SUM(DECODE(MM,11,CNT)) "NOV",SUM(DECODE(MM,12,CNT)) "DEC",SUM(DECODE(YY,MM,1,CNT,YY,MM,2,CNT)) "YY TOTAL"        
FROM A
GROUP BY YY
ORDER BY YY
;



------------------------------------------3. CDRs on time fulfillment rate for the month

WITH CDRS_PAST_DUE AS (
select COUNT (*) AS "CDRS_COMPLETED_POST_CFD"
from jbrown.jira_tasks
where project_name in ('Case Data Request')
AND SUMMARY NOT LIKE '%Master Case%'
and created > SYSDATE - 30 -- 30 DAYS AGO
AND CREATED < CLAIM_DEADLINE
AND (TRUNC(RESOLUTION) > TRUNC(CLAIM_DEADLINE) OR RESOLUTION IS NULL )
AND CLAIM_DEADLINE < SYSDATE 
) ,
CDRS_ON_TIME AS (
select COUNT (*) AS "CDRS_COMPLETED_PRE_CFD"
from jbrown.jira_tasks
where project_name in ('Case Data Request')
AND SUMMARY NOT LIKE '%Master Case%'
and created > SYSDATE - 30 -- 30 DAYS AGO
AND RESOLUTION < CLAIM_DEADLINE + 1
)
SELECT CDRS_COMPLETED_POST_CFD,CDRS_COMPLETED_PRE_CFD, ROUND((CDRS_COMPLETED_PRE_CFD/(CDRS_COMPLETED_PRE_CFD + CDRS_COMPLETED_POST_CFD)),2) AS "ON_TIME_FULFILLMENT_RATE"
FROM CDRS_PAST_DUE, CDRS_ON_TIME
;



------------------------------------------4. Open CDRs assigned to AM

select key,case_id,summary,claim_deadline,assignee,status, due_date, round (sysdate - created) as "DAYS SINCE CREATION" 
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID CI
where project_name in ('Case Data Request')
AND STATUS NOT IN ( 'Done')
and created > SYSDATE - 30 -- 30 DAYS AGO
AND (ASSIGNEE like '%******' or ASSIGNEE like '%******' or ASSIGNEE like'%******' or ASSIGNEE like'%******' or ASSIGNEE like'%******'  or ASSIGNEE like'%******' or ASSIGNEE like'%******' or ASSIGNEE like'%******' or ASSIGNEE like'%******' or ASSIGNEE like'%******' or ASSIGNEE like'%******')
and JT.ID = CI.TASK_ID
;



------------------------------------------ 5. Open CDRs assigned to CDM

select key,case_id,summary,claim_deadline,assignee,status, due_date, round (sysdate - created) as "DAYS SINCE CREATION" 
from jbrown.jira_tasks JT,jbrown.JIRA_TASK_CASE_ID CI
where project_name in ('Case Data Request')
AND STATUS NOT IN ( 'Done')
and created > SYSDATE - 30 -- 30 DAYS AGO
AND (ASSIGNEE like '%******' or ASSIGNEE like '%******' or ASSIGNEE like'%******' or ASSIGNEE like'%******' or ASSIGNEE like'%******'  or ASSIGNEE like'%******' or ASSIGNEE like'%******')
and JT.ID = CI.TASK_ID
;


/*
------------------------------------------ 2. Total CDRs PER CLIENT in Respect to Case Vol & All CDR Vol.


--DISBURSION OF CDRs BY MONTH
WITH A AS (
SELECT DISTINCT EXTRACT(YEAR FROM CREATED) AS YY, EXTRACT(MONTH FROM CREATED) AS MM,COUNT(*) AS CNT
FROM jbrown.jira_tasks
WHERE (PROJECT_NAME IN ('Case Data Request'))
and client = &CLIENT_NAME_VAR
--AND CLIENT = &CLIENT_NAME_VAR -------- CLIENT NAME
AND SUMMARY NOT LIKE '%Master%' -------------- DOMESTIC ONLY
AND EXTRACT(YEAR FROM CREATED)<=EXTRACT(YEAR FROM TRUNC(SYSDATE))
 GROUP BY EXTRACT(YEAR FROM CREATED) , EXTRACT(MONTH FROM CREATED)       
)SELECT  YY,SUM(DECODE(MM,1,CNT)) "JAN",SUM(DECODE(MM,2,CNT)) "FEB",SUM(DECODE(MM,3,CNT)) "MAR", SUM(DECODE(MM,4,CNT)) "APR", SUM(DECODE(MM,5,CNT)) "MAY", SUM(DECODE(MM,6,CNT)) "JUN",SUM(DECODE(MM,7,CNT)) "JUL",SUM(DECODE(MM,8,CNT)) "AUG",SUM(DECODE(MM,9,CNT)) "SEP",SUM(DECODE(MM,10,CNT)) "OCT",SUM(DECODE(MM,11,CNT)) "NOV",SUM(DECODE(MM,12,CNT)) "DEC",SUM(DECODE(YY,MM,1,CNT,YY,MM,2,CNT)) "YY TOTAL"       
FROM A 
GROUP BY YY
ORDER BY YY;


------------------------------------------ DISBURSION OF DOMESTIC CASES BY VOLUME AND DATE
*//*
INTERCHANGE THE FOLLOWING VARIABLES TO FIND NUMBER OF ____ IN EACH MONTH
SETTLEMENT_DATE
FILING_CLAIM_DEADLINE_DATE
FILING_CLAIM_DEADLINE_DATE - 30   = SLA DATE
*//*
WITH A AS (
SELECT DISTINCT EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE) AS YY, EXTRACT(MONTH FROM FILING_CLAIM_DEADLINE_DATE) AS MM,COUNT(*) AS CNT
            FROM frt.case
            WHERE CASE_STATUS||FRT_STATUS IN ('SETTLEDACTIVE', 'DISBURSEMENTDISBURSED')
AND FILING_CLAIM_DEADLINE_DATE IS NOT NULL
AND FRT_EDITS = 3
AND PARTICIPATION = 'OPT_OUT'
            AND FILING_CLAIM_DEADLINE_DATE IS NOT NULL
            AND FILING_CLAIM_DEADLINE_DATE >'1-AUG-2021'  
AND EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE)<=EXTRACT(YEAR FROM TRUNC(SYSDATE+365))
            GROUP BY EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE) , EXTRACT(MONTH FROM FILING_CLAIM_DEADLINE_DATE)
        
        )
SELECT  YY,SUM(DECODE(MM,1,CNT)) "JAN",SUM(DECODE(MM,2,CNT)) "FEB",SUM(DECODE(MM,3,CNT)) "MAR", SUM(DECODE(MM,4,CNT)) "APR", SUM(DECODE(MM,5,CNT)) "MAY", SUM(DECODE(MM,6,CNT)) "JUN",SUM(DECODE(MM,7,CNT)) "JUL",SUM(DECODE(MM,8,CNT)) "AUG",SUM(DECODE(MM,9,CNT)) "SEP",SUM(DECODE(MM,10,CNT)) "OCT",SUM(DECODE(MM,11,CNT)) "NOV",SUM(DECODE(MM,12,CNT)) "DEC",SUM(DECODE(YY,MM,1,CNT,YY,MM,2,CNT)) "YY TOTAL"        
FROM A
GROUP BY YY
ORDER BY YY
;
*/

------------------------------------------ 6
--See Pivot Table

-- POPULATE CLIENT CDRS IN PIVOT TABLE'S DATA SET
select ID as "CDR", KEY, ISSUE_TYPE, STATUS, PROJECT_NAME, TRUNC(CREATED) AS "CREATED", DUE_DATE, CLIENT, RESOLUTION
from jbrown.jira_tasks
where project_name in ('Case Data Request')
AND CLIENT IS NOT NULL AND CREATED IS NOT NULL
--AND SUMMARY NOT LIKE '%Master Case%'
ORDER BY CLIENT
;

-- POPUALTE CASES IN PIVOT TABLE'S DATA SET
Select 
CASE WHEN C.CASE_ID IS NOT NULL THEN 1 END AS "FORMATING",
CASE WHEN C.CASE_ID IS NOT NULL THEN ' ' END AS "FORMATING",
CASE WHEN C.CASE_ID IS NOT NULL THEN ' ' END AS "FORMATING",
CASE WHEN C.CASE_ID IS NOT NULL THEN ' ' END AS "FORMATING",
CASE WHEN C.CASE_ID IS NOT NULL THEN ' ' END AS "FORMATING",
C.FILING_CLAIM_DEADLINE_DATE,
CASE WHEN C.CASE_ID IS NOT NULL THEN ' ' END AS "FORMATING",
CASE WHEN C.CREATED_BY IS NOT NULL THEN 'CASES' END AS "FORMATING" 

FROM CASE C, CASE_MASTER.COMPLAINT_TYPE_LOOKUP CTL , CASE_MASTER.case_complaint_mapping CM, CASE_MASTER.COMPLAINT CMC
WHERE C.FILING_CLAIM_DEADLINE_DATE >'1-AUG-2021'
AND C.FILING_CLAIM_DEADLINE_DATE < SYSDATE
and  (CTL.COMPLAINT_TYPE NOT IN ('DIRECT', 'ANTI-TRUST'))
AND C.frt_edits = 3
AND C.CASE_ID = CM.CASE_ID
AND CTL.COMPLAINT_TYPE_ID = CMC.COMPLAINT_TYPE_ID
AND CM.COMPLAINT_ID = CMC.COMPLAINT_ID
ORDER BY C.FILING_CLAIM_DEADLINE_DATE
;















--*********************************************************************
---------------------------------------------- START OF YEARLY CDR REPORT
--*********************************************************************
/*
	1. Count of clients that required at least 1 CDR in the month
	2. Average CDRs per Case for the year
	3. CDRs on time fulfillment rate for the year
	4. Open CDRs assigned to AM (whatever frequency is best)
	5. Open CDRs assigned to CDM (whatever frequency is best)
 
*/


------------------------------------------1. Count of clients that required at least 1 CDR in the month

select DISTINCT CLIENT AS "Distinct Clients Reached Out to in the Last 365 Days"
from jbrown.jira_tasks
where project_name in ('Case Data Request')
--AND SUMMARY NOT LIKE '%Master Case%'
and created > SYSDATE - 365
ORDER BY CLIENT
;




------------------------------------------2. Average CDRs per Case for the month ** BASED OFF OF CFD DATE**

WITH CDR_COUNT AS(
select COUNT (*) AS "CDRS_LAST_MONTH"
from jbrown.jira_tasks
where project_name in ('Case Data Request')
AND SUMMARY NOT LIKE '%Master Case%'
and created > SYSDATE - 35
--AND CLIENT IN (&CLIENT_NAME_VAR)
),
CASE_COUNT AS(
SELECT COUNT (DISTINCT FILING_CLAIM_DEADLINE_DATE) AS "CASES_LAST_MONTH"
FROM frt.case
WHERE CASE_STATUS||FRT_STATUS IN ('SETTLEDACTIVE', 'DISBURSEMENTDISBURSED')
AND FRT_EDITS = 3
and country_code in ('US','CA')
AND case_name NOT like ('%Master Case%')
AND FILING_CLAIM_DEADLINE_DATE  < SYSDATE 
AND FILING_CLAIM_DEADLINE_DATE  > SYSDATE - 365 -- DAYS AGO
)
SELECT CDRS_LAST_MONTH,CASES_LAST_MONTH, ROUND((CDRS_LAST_MONTH / CASES_LAST_MONTH),1) AS "AVG CDR PER CASE"
FROM CDR_COUNT, CASE_COUNT
;


------------------------------------------ 2. Total CDRs in Respect to Case Vol & All CDR Vol. GLOBAL AND DOMESTIC


--DISBURSION OF CDRs BY MONTH
WITH A AS (
SELECT DISTINCT EXTRACT(YEAR FROM CREATED) AS YY, EXTRACT(MONTH FROM CREATED) AS MM,COUNT(*) AS CNT
FROM jbrown.jira_tasks
WHERE (PROJECT_NAME IN ('Case Data Request'))
and client is not null
--AND CLIENT = &CLIENT_NAME_VAR -------- CLIENT NAME
AND SUMMARY NOT LIKE '%Master%' -------------- DOMESTIC ONLY
AND EXTRACT(YEAR FROM CREATED)<=EXTRACT(YEAR FROM TRUNC(SYSDATE))
 GROUP BY EXTRACT(YEAR FROM CREATED) , EXTRACT(MONTH FROM CREATED)       
)SELECT  YY,SUM(DECODE(MM,1,CNT)) "JAN",SUM(DECODE(MM,2,CNT)) "FEB",SUM(DECODE(MM,3,CNT)) "MAR", SUM(DECODE(MM,4,CNT)) "APR", SUM(DECODE(MM,5,CNT)) "MAY", SUM(DECODE(MM,6,CNT)) "JUN",SUM(DECODE(MM,7,CNT)) "JUL",SUM(DECODE(MM,8,CNT)) "AUG",SUM(DECODE(MM,9,CNT)) "SEP",SUM(DECODE(MM,10,CNT)) "OCT",SUM(DECODE(MM,11,CNT)) "NOV",SUM(DECODE(MM,12,CNT)) "DEC",SUM(DECODE(YY,MM,1,CNT,YY,MM,2,CNT)) "YY TOTAL"       
FROM A 
GROUP BY YY
ORDER BY YY;


-- DISBURSION OF DOMESTIC CASES BY VOLUME AND DATE
/*
INTERCHANGE THE FOLLOWING VARIABLES TO FIND NUMBER OF ____ IN EACH MONTH
SETTLEMENT_DATE
FILING_CLAIM_DEADLINE_DATE
FILING_CLAIM_DEADLINE_DATE - 30   = SLA DATE
*/
WITH A AS (
SELECT DISTINCT EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE) AS YY, EXTRACT(MONTH FROM FILING_CLAIM_DEADLINE_DATE) AS MM,COUNT(*) AS CNT
            FROM frt.case
            WHERE CASE_STATUS||FRT_STATUS IN ('SETTLEDACTIVE', 'DISBURSEMENTDISBURSED')
AND FILING_CLAIM_DEADLINE_DATE IS NOT NULL
AND FRT_EDITS = 3
AND PARTICIPATION = 'OPT_OUT'            
            AND FILING_CLAIM_DEADLINE_DATE >'1-AUG-2021' 
            AND FILING_CLAIM_DEADLINE_DATE < SYSDATE 
AND EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE)<=EXTRACT(YEAR FROM TRUNC(SYSDATE+365))
            GROUP BY EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE) , EXTRACT(MONTH FROM FILING_CLAIM_DEADLINE_DATE)
        
        )
SELECT  YY,SUM(DECODE(MM,1,CNT)) "JAN",SUM(DECODE(MM,2,CNT)) "FEB",SUM(DECODE(MM,3,CNT)) "MAR", SUM(DECODE(MM,4,CNT)) "APR", SUM(DECODE(MM,5,CNT)) "MAY", SUM(DECODE(MM,6,CNT)) "JUN",SUM(DECODE(MM,7,CNT)) "JUL",SUM(DECODE(MM,8,CNT)) "AUG",SUM(DECODE(MM,9,CNT)) "SEP",SUM(DECODE(MM,10,CNT)) "OCT",SUM(DECODE(MM,11,CNT)) "NOV",SUM(DECODE(MM,12,CNT)) "DEC",SUM(DECODE(YY,MM,1,CNT,YY,MM,2,CNT)) "YY TOTAL"        
FROM A
GROUP BY YY
ORDER BY YY
;



------------------------------------------3. CDRs on time fulfillment rate for the year

WITH CDRS_PAST_DUE AS (
select COUNT (*) AS "CDRS_COMPLETED_POST_CFD"
from jbrown.jira_tasks
where project_name in ('Case Data Request')
AND SUMMARY NOT LIKE '%Master Case%'
and created > SYSDATE - 365 --  DAYS AGO
AND CREATED < CLAIM_DEADLINE
AND (TRUNC(RESOLUTION) > TRUNC(CLAIM_DEADLINE) OR RESOLUTION IS NULL )
AND CLAIM_DEADLINE < SYSDATE 
) ,
CDRS_ON_TIME AS (
select COUNT (*) AS "CDRS_COMPLETED_PRE_CFD"
from jbrown.jira_tasks
where project_name in ('Case Data Request')
AND SUMMARY NOT LIKE '%Master Case%'
and created > SYSDATE - 365 -- DAYS AGO
AND RESOLUTION < CLAIM_DEADLINE + 1
)
SELECT CDRS_COMPLETED_POST_CFD,CDRS_COMPLETED_PRE_CFD, ROUND((CDRS_COMPLETED_PRE_CFD/(CDRS_COMPLETED_PRE_CFD + CDRS_COMPLETED_POST_CFD)),2) AS "ON_TIME_FULFILLMENT_RATE"
FROM CDRS_PAST_DUE, CDRS_ON_TIME
;






/*
------------------------------------------ 2. Total CDRs PER CLIENT in Respect to Case Vol & All CDR Vol.


--DISBURSION OF CDRs BY MONTH
WITH A AS (
SELECT DISTINCT EXTRACT(YEAR FROM CREATED) AS YY, EXTRACT(MONTH FROM CREATED) AS MM,COUNT(*) AS CNT
FROM jbrown.jira_tasks
WHERE (PROJECT_NAME IN ('Case Data Request'))
and client = &CLIENT_NAME_VAR
--AND CLIENT = &CLIENT_NAME_VAR -------- CLIENT NAME
AND SUMMARY NOT LIKE '%Master%' -------------- DOMESTIC ONLY
AND EXTRACT(YEAR FROM CREATED)<=EXTRACT(YEAR FROM TRUNC(SYSDATE))
 GROUP BY EXTRACT(YEAR FROM CREATED) , EXTRACT(MONTH FROM CREATED)       
)SELECT  YY,SUM(DECODE(MM,1,CNT)) "JAN",SUM(DECODE(MM,2,CNT)) "FEB",SUM(DECODE(MM,3,CNT)) "MAR", SUM(DECODE(MM,4,CNT)) "APR", SUM(DECODE(MM,5,CNT)) "MAY", SUM(DECODE(MM,6,CNT)) "JUN",SUM(DECODE(MM,7,CNT)) "JUL",SUM(DECODE(MM,8,CNT)) "AUG",SUM(DECODE(MM,9,CNT)) "SEP",SUM(DECODE(MM,10,CNT)) "OCT",SUM(DECODE(MM,11,CNT)) "NOV",SUM(DECODE(MM,12,CNT)) "DEC",SUM(DECODE(YY,MM,1,CNT,YY,MM,2,CNT)) "YY TOTAL"       
FROM A 
GROUP BY YY
ORDER BY YY;


------------------------------------------ DISBURSION OF DOMESTIC CASES BY VOLUME AND DATE
*//*
INTERCHANGE THE FOLLOWING VARIABLES TO FIND NUMBER OF ____ IN EACH MONTH
SETTLEMENT_DATE
FILING_CLAIM_DEADLINE_DATE
FILING_CLAIM_DEADLINE_DATE - 30   = SLA DATE
*//*
WITH A AS (
SELECT DISTINCT EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE) AS YY, EXTRACT(MONTH FROM FILING_CLAIM_DEADLINE_DATE) AS MM,COUNT(*) AS CNT
            FROM frt.case
            WHERE CASE_STATUS||FRT_STATUS IN ('SETTLEDACTIVE', 'DISBURSEMENTDISBURSED')
AND FILING_CLAIM_DEADLINE_DATE IS NOT NULL
AND FRT_EDITS = 3
AND PARTICIPATION = 'OPT_OUT'
            AND FILING_CLAIM_DEADLINE_DATE IS NOT NULL
            AND FILING_CLAIM_DEADLINE_DATE >'1-AUG-2021'  
AND EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE)<=EXTRACT(YEAR FROM TRUNC(SYSDATE+365))
            GROUP BY EXTRACT(YEAR FROM FILING_CLAIM_DEADLINE_DATE) , EXTRACT(MONTH FROM FILING_CLAIM_DEADLINE_DATE)
        
        )
SELECT  YY,SUM(DECODE(MM,1,CNT)) "JAN",SUM(DECODE(MM,2,CNT)) "FEB",SUM(DECODE(MM,3,CNT)) "MAR", SUM(DECODE(MM,4,CNT)) "APR", SUM(DECODE(MM,5,CNT)) "MAY", SUM(DECODE(MM,6,CNT)) "JUN",SUM(DECODE(MM,7,CNT)) "JUL",SUM(DECODE(MM,8,CNT)) "AUG",SUM(DECODE(MM,9,CNT)) "SEP",SUM(DECODE(MM,10,CNT)) "OCT",SUM(DECODE(MM,11,CNT)) "NOV",SUM(DECODE(MM,12,CNT)) "DEC",SUM(DECODE(YY,MM,1,CNT,YY,MM,2,CNT)) "YY TOTAL"        
FROM A
GROUP BY YY
ORDER BY YY
;
*/

------------------------------------------ 6
--See Pivot Table

-- POPULATE CLIENT CDRS IN PIVOT TABLE'S DATA SET
select ID as "CDR", KEY, ISSUE_TYPE, STATUS, PROJECT_NAME, TRUNC(CREATED) AS "CREATED", DUE_DATE, CLIENT, RESOLUTION
from jbrown.jira_tasks
where project_name in ('Case Data Request')
AND CLIENT IS NOT NULL AND CREATED IS NOT NULL
--AND SUMMARY NOT LIKE '%Master Case%'
ORDER BY CLIENT
;

-- POPUALTE CASES IN PIVOT TABLE'S DATA SET
Select 
CASE WHEN C.CASE_ID IS NOT NULL THEN 1 END AS "FORMATING",
CASE WHEN C.CASE_ID IS NOT NULL THEN ' ' END AS "FORMATING",
CASE WHEN C.CASE_ID IS NOT NULL THEN ' ' END AS "FORMATING",
CASE WHEN C.CASE_ID IS NOT NULL THEN ' ' END AS "FORMATING",
CASE WHEN C.CASE_ID IS NOT NULL THEN ' ' END AS "FORMATING",
C.FILING_CLAIM_DEADLINE_DATE,
CASE WHEN C.CASE_ID IS NOT NULL THEN ' ' END AS "FORMATING",
CASE WHEN C.CREATED_BY IS NOT NULL THEN 'CASES' END AS "FORMATING" 

FROM CASE C, CASE_MASTER.COMPLAINT_TYPE_LOOKUP CTL , CASE_MASTER.case_complaint_mapping CM, CASE_MASTER.COMPLAINT CMC
WHERE C.FILING_CLAIM_DEADLINE_DATE >'1-AUG-2021'
AND C.FILING_CLAIM_DEADLINE_DATE < SYSDATE
and  (CTL.COMPLAINT_TYPE NOT IN ('DIRECT', 'ANTI-TRUST'))
AND C.frt_edits = 3
AND C.CASE_ID = CM.CASE_ID
AND CTL.COMPLAINT_TYPE_ID = CMC.COMPLAINT_TYPE_ID
AND CM.COMPLAINT_ID = CMC.COMPLAINT_ID
ORDER BY C.FILING_CLAIM_DEADLINE_DATE
;



























