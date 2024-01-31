CREATE OR REPLACE PROCEDURE "OPS_APP"."DIFF_FILE_DUPE" (

P_CASE_ID  NUMBER,
P_CLIENT_NAME  VARCHAR2

)
AS
begin




update prefiling.case_transaction U
set exclude_reason = 'INTER-FILE DUPE - '|| sysdate
where exists (
    with 
        -- Subsetting the data 
        subtran as (
            select * from PREFILING.CASE_transaction
            where CLIENT_ID IN (SELECT CLIENT_ID FROM FRT.CLIENT WHERE SHORT_NAME IN (P_CLIENT_NAME))
            AND exclude_reason is null
            AND CASE_iD IN ( P_CASE_ID )
        ),
        -- Join subtran to itself to group dupes
        transaction_groups as (
            select B.transaction_id as high_transaction
            from subtran A, subtran B
            
            -- Where dupe characteristics match...
            -- Not concerned about client_trans_id, or settle_date if the dupes are across different files.
            where A.CLIENT_ID = B.CLIENT_ID
            AND   A.SECURITY_IDENTIFIER_MODIFIED = B.SECURITY_IDENTIFIER_MODIFIED
            AND   A.ACCOUNT_ID = B.ACCOUNT_ID
            AND   ROUND(A.TRADE_DATE) = ROUND(B.TRADE_DATE)
            AND   A.QUANTITY = B.QUANTITY
            AND   A.FRT_TRANSACTION_TYPE = B.FRT_TRANSACTION_TYPE
            --AND   round(A.PRICE, 2) = round(B.PRICE, 2) --COMMENT OUT HERE FOR DIFFERENT PRICED DUPLICATES
            
         -- a.TRANSACTION_ID > b.TRANSACTION_ID = EXCLUDING THE FIFO TRANSACTIONS
        -- a.TRANSACTION_ID < b.TRANSACTION_ID = EXCLUDING LIFO TRANSACTIONS
            and A.TRANSACTION_ID > B.TRANSACTION_ID
            
            -- ... and where the file_ids are not the same.
            --     (using < instead of <> to make sure that we know which one is the 'low' file_source)
            and (
                trunc(a.load_date) <> trunc(b.load_date) or
                a.file_NUMBER <> b.file_NUMBER
            )
        )
    select high_transaction from transaction_groups g
    where g.high_transaction = u.transaction_id
)
;

END ;





/*


-- Anonymous PL/SQL block to call the SLAMA_DUPES procedure
BEGIN
   OPS_APP.DIFF_FILE_DUPE(P_CASE_ID => 25244, P_CLIENT_NAME => 'POINT72');
END;

*/