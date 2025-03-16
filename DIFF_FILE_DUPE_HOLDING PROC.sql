
CREATE OR REPLACE PROCEDURE "OPS_APP"."DIFF_FILE_DUPE_HOLDING" (

P_CASE_ID  NUMBER,
P_CLIENT_NAME  VARCHAR2

)
AS
begin


------------------------ EXCLUDE DIFFERENT FILE HOLDING POSITIONS

update prefiling.case_holding_position U
set exclude_reason = 'INTER-FILE DUPE HOLDING - '|| sysdate

--;SELECT CLIENT_ID, HOLDING_POSITION_ID, ACCOUNT_ID, trunc(trade_date), QUANTITY,EXCLUDE_REASON FROM  prefiling.case_holding_position U

where exists (
    with 
        -- Subsetting the data 
        subtran as (
            select * from prefiling.case_holding_position
            where CLIENT_ID IN (SELECT CLIENT_ID FROM FRT.CLIENT WHERE SHORT_NAME IN (P_CLIENT_NAME))
            AND exclude_reason is null
            AND CASE_iD IN ( P_CASE_ID)
        ),
        -- Join subtran to itself to group dupes
        transaction_groups as (
            select B.HOLDING_POSITION_ID as high_transaction
            from subtran A, subtran B
            
            -- Where dupe characteristics match...
            -- Not concerned about client_trans_id, or settle_date if the dupes are across different files.
            where A.CLIENT_ID = B.CLIENT_ID
            AND   A.SECURITY_IDENTIFIER_MODIFIED = B.SECURITY_IDENTIFIER_MODIFIED
            AND   A.ACCOUNT_ID = B.ACCOUNT_ID
            AND   trunc(A.TRADE_DATE) = trunc(B.TRADE_DATE)
            AND   A.QUANTITY = B.QUANTITY           
                        
            -- ... are not the same transaction
            -- A.HOLDING_POSITION_ID > B.HOLDING_POSITION_ID = EXCLUDING THE FIFO TRANSACTIONS
            -- A.HOLDING_POSITION_ID < B.HOLDING_POSITION_ID = EXCLUDING LIFO TRANSACTIONS
            and A.HOLDING_POSITION_ID > B.HOLDING_POSITION_ID
            
            -- ... and where the file_ids are not the same.
            and (
                trunc(a.load_date) <> trunc(b.load_date) or
                a.file_NUMBER <> b.file_NUMBER
            )
        )
    select high_transaction from transaction_groups g
    where g.high_transaction = u.HOLDING_POSITION_ID
)
;
END ;

