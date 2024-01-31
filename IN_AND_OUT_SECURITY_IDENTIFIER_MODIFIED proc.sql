CREATE OR REPLACE PROCEDURE "OPS_APP"."IN_AND_OUT_SECURITY_IDENTIFIER_MODIFIED" (

P_CASE_ID  NUMBER,
P_CLIENT_NAME VARCHAR2

)
AS
begin

DECLARE
        COUNTWHILE NUMBER;
BEGIN
       SELECT  MAX (LOOPCOUNT) INTO COUNTWHILE 
       FROM 
       (SELECT T.CASE_ID, T.client_id, T.ACCOUNT_ID ,  T.TRADE_DATE, T.QUANTITY, T.PRICE, T.SECURITY_IDENTIFIER_MODIFIED,
                  LEAST(SUM(CASE WHEN BT.BUY_SELL = 'B' THEN 1 ELSE 0 END),
                  SUM(CASE WHEN BT.BUY_SELL = 'S' THEN 1 ELSE 0 END)) LOOPCOUNT
        FROM PREFILING.CASE_TRANSACTION T, FRT.BROKER_FRT_TRANS_TYPE BT, FRT.client cl
        
        WHERE T.TRANS_TYPE = BT.TRANS_TYPE
        AND cl.short_name =  BT.SOURCE
        and t.client_id = cl.client_id
        AND SHORT_NAME IN (P_CLIENT_NAME)
        
        AND T.CASE_ID = P_CASE_ID
        AND T.EXCLUDE_REASON IS NULL
        AND T.SECURITY_IDENTIFIER IS NOT NULL
        AND T.QUANTITY <> 0
        AND BT.BUY_SELL IN ('B','S')
        GROUP BY T.CASE_ID, T.client_id, T.ACCOUNT_ID , T.SECURITY_IDENTIFIER_MODIFIED, T.TRADE_DATE, T.QUANTITY, T.PRICE
        HAVING COUNT(DISTINCT BT.BUY_SELL)=2);
       
       WHILE COUNTWHILE > 0
       LOOP 
        FOR I IN 
        (
        SELECT  T.CASE_ID, T.client_id, T.ACCOUNT_ID ,  T.TRADE_DATE, T.QUANTITY, T.PRICE, T.SECURITY_IDENTIFIER_MODIFIED,
        MAX(CASE WHEN BT.BUY_SELL = 'B' THEN TRANSACTION_ID ELSE 0 END) BUYID,
        MAX(CASE WHEN BT.BUY_SELL = 'S' THEN TRANSACTION_ID ELSE 0 END) SELLID
        FROM PREFILING.CASE_TRANSACTION T, FRT.BROKER_FRT_TRANS_TYPE BT, FRT.client cl
        
        WHERE T.TRANS_TYPE = BT.TRANS_TYPE
        AND cl.short_name =  BT.SOURCE
        and t.client_id = cl.client_id
        AND SHORT_NAME IN (P_CLIENT_NAME)
        
        AND T.CASE_ID = P_CASE_ID
        AND T.EXCLUDE_REASON IS NULL
        AND T.SECURITY_IDENTIFIER IS NOT NULL
        AND T.QUANTITY <> 0
        AND BT.BUY_SELL IN ('B','S')
        GROUP BY T.CASE_ID, T.client_id, T.ACCOUNT_ID , T.SECURITY_IDENTIFIER_MODIFIED, T.TRADE_DATE, T.QUANTITY, T.PRICE
        HAVING COUNT(DISTINCT BT.BUY_SELL)=2     
        )     
        LOOP                           
                        UPDATE PREFILING.CASE_TRANSACTION
                        SET EXCLUDE_REASON='IN & OUT SECURITY_IDENTIFIER_MODIFIED - '|| sysdate
                        WHERE CASE_id= I.CASE_ID
                        AND EXCLUDE_REASON IS NULL
                        AND TRANSACTION_ID IN (I.BUYID,I.SELLID);
                                       
                     COMMIT;                  
                END LOOP;
            COUNTWHILE := COUNTWHILE -1;
            END LOOP;
END;

  end  ;







        
        
        