DECLARE
  type client_list is table of varchar2(100);
  max_trade_date DATE;
  difference_value NUMBER;
  account_id_var NUMBER ;
  case_id_var NUMBER := &case_id_var;

  
  security_id VARCHAR2(200);
  frt_transaction_type VARCHAR2(2);
  trans_type VARCHAR2(200);
  h_quantity NUMBER;
  t_amount NUMBER;
  SYNTH_TRADE_DATE DATE;
  exists_flag NUMBER := 0;
 
  good_clients client_list := client_list(
  
  
'******'


  );




BEGIN
  FOR i in 1..good_clients.COUNT LOOP
    DECLARE
      CURSOR c_account_security IS
        SELECT account_id,SECURITY_IDENTIFIER_MODIFIED, client_id
        FROM PREFILING.CASE_TRANSACTION 
        WHERE CASE_ID = case_id_var
          and account_id in (                    
          
      
4062476, 4062571, 4062572, 4062751, 4062752, 4062769, 4062780, 4062788, 4062795, 4062808, 4062809, 4062812, 4062866, 4062889, 4062917, 4062919, 4062965, 4062975, 4062983, 4062997
        
          )
          AND client_id = (SELECT CLIENT_ID FROM CLIENT WHERE SHORT_NAME = good_clients(i))
        GROUP BY account_id, SECURITY_IDENTIFIER_MODIFIED, client_id;
    BEGIN
      FOR rec in c_account_security LOOP
        account_id_var := rec.account_id;
        security_id := rec.SECURITY_IDENTIFIER_MODIFIED;

    
    
      SELECT MAX(trade_DATE) INTO max_trade_date
      FROM prefiling.case_holding_position
       WHERE  trade_DATE <= 
      
      '******' --************************************************** ENTER MERGER DATE HERE
      

        AND client_id = rec.client_id
        AND account_id = account_id_var 
        AND CASE_ID = &case_id_var
        and SECURITY_IDENTIFIER_MODIFIED = security_id
        and exclude_reason is null;
        
        DBMS_OUTPUT.PUT_LINE('---');
        DBMS_OUTPUT.PUT_LINE('Client ID' || rec.client_id);
        DBMS_OUTPUT.PUT_LINE('Account ID: ' || account_id_var);
        DBMS_OUTPUT.PUT_LINE('Max Trade Date: ' || TO_CHAR(max_trade_date, 'YYYY-MM-DD'));
        
SELECT SUM(DISTINCT h.QUANTITY) INTO h_quantity  -- this is now distinct because duplicate holding have been discovered
FROM prefiling.case_holding_position h
WHERE h.TRADE_DATE = (
      SELECT MAX(trade_DATE)
      FROM prefiling.case_holding_position
      WHERE trade_DATE <= max_trade_date
          AND client_id = rec.client_id
          AND account_id = account_id_var
          AND CASE_ID  = case_id_var
          and exclude_reason is null
  )
  AND CASE_ID  = case_id_var
  and SECURITY_IDENTIFIER_MODIFIED = security_id
  AND account_id = account_id_var
  and exclude_reason is null;

DBMS_OUTPUT.PUT_LINE('Holding Quantity: ' || TO_CHAR(h_quantity));
  
  
  SELECT COALESCE(SUM(
    CASE 
      WHEN t.FRT_TRANSACTION_TYPE = 'B' THEN t.quantity 
      WHEN t.FRT_TRANSACTION_TYPE = 'S' THEN -1 * t.quantity 
    END
  ),0) INTO t_amount
  FROM prefiling.case_transaction t
  WHERE client_id = rec.client_id
    AND trade_DATE <= (max_trade_date
/*      SELECT MAX(trade_DATE)
      FROM prefiling.case_holding_position 
      WHERE trade_DATE <= max_trade_date
        AND client_id = (SELECT client_id FROM client WHERE short_name = client_name_var)
        AND account_id = account_id_var 
        AND CASE_ID  = case_id_var*/
    )
    AND account_id = account_id_var
    and SECURITY_IDENTIFIER_MODIFIED = security_id
    and SECURITY_IDENTIFIER_MODIFIED = security_id
    AND EXCLUDE_REASON IS NULL
    AND CASE_ID  = case_id_var;
    
DBMS_OUTPUT.PUT_LINE('Trade Quantity: ' || TO_CHAR(t_amount));

  difference_value := h_quantity - t_amount;
  
DBMS_OUTPUT.PUT_LINE('Difference: ' || TO_CHAR(difference_value));

  SELECT MAX(trade_DATE)-2 INTO synth_trade_date
  FROM prefiling.case_holding_position 
  WHERE trade_DATE <= max_trade_date
    AND account_id = account_id_var
    AND case_id = case_id_var
    and SECURITY_IDENTIFIER_MODIFIED = security_id
    and exclude_reason is null;
    
    
DBMS_OUTPUT.PUT_LINE('Synth trade date: ' || TO_CHAR(synth_trade_date, 'YYYY-MM-DD'));
/*    
  SELECT DISTINCT(SECURITY_IDENTIFIER_MODIFIED) INTO security_id
  FROM PREFILING.CASE_TRANSACTION WHERE CASE_ID = case_id_var 
  and account_id = account_id_var
  and client_id = (select client_id from client where short_name = client_name_var);*/
  
  
DBMS_OUTPUT.PUT_LINE('Security ID: ' || security_id);


  SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END INTO exists_flag
  FROM prefiling.case_holding_position
  WHERE trade_DATE <= max_trade_date
    AND client_id = rec.client_id
    AND account_id = account_id_var
    AND CASE_ID  = case_id_var
    and SECURITY_IDENTIFIER_MODIFIED = security_id
    and exclude_reason is null;

DBMS_OUTPUT.PUT_LINE('Holding Exist flag: ' || exists_flag);
DBMS_OUTPUT.PUT_LINE('---');

  IF difference_value >= 0 THEN 
    frt_transaction_type := 'B';
    trans_type := '******';
  ELSE
    frt_transaction_type := 'S';
    trans_type := '******';
  END IF;

      
      IF exists_flag = 1 and difference_value <> 0 
      THEN -- List of client we should not auto insert
      BEGIN
        INSERT INTO prefiling.case_transaction(
          account_id, 
          trade_date, 
          quantity,
          transaction_id, 
          TRANS_TYPE, 
          FRT_TRANSACTION_TYPE, 
          CLIENT_ID, 
          SECURITY_IDENTIFIER_MODIFIED, 
          SECURITY_IDENTIFIER,
          case_id,
          Load_date,
          update_date,
          updated_by, 
          price,
          addition_type_id,
        transaction_description
        )
        VALUES (
          account_id_var, 
          synth_trade_date, 
          abs(difference_value),
          TRANSACTION_SEQ.NEXTVAL,
          trans_type,
          frt_transaction_type,
          rec.client_id,
          security_id,
          security_id,
          &case_id_var,
          trunc(sysdate),
          trunc(sysdate),
          User,
          0,
          6, 
         'synth script insert'
        );
     END;  
        END IF;  

      END LOOP; 
      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Uncaught exception in inner block: ' || SQLERRM);
        RAISE;
    END; 

  END LOOP; 

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Uncaught exception in outer block: ' || SQLERRM);
    RAISE;
END; 







/*


SELECT C.SHORT_NAME, PRE.*
FROM PREFILING.CASE_TRANSACTION PRE, FRT.CLIENT C
WHERE PRE.TRANSACTION_DESCRIPTION IN ('synth script insert')
AND PRE.CASE_ID IN ( 22136 )
AND PRE.CLIENT_ID = C.CLIENT_ID
AND PRE.CLIENT_ID IN (SELECT CLIENT_ID FROM FRT.CLIENT WHERE SHORT_NAME IN ( ******))
--AND ACCOUNT_ID IN (3472611, 4062520, 4062528, 4062533, 4062535, 4062536, 4062536, 4062539, 4062539, 4062540, 4062540, 4062555, 4062578, 4062579, 4062616, 4062715, 4062715, 4062826, 4062826, 4062895, 5862429, 5862451, 5862451, 5862517, 5873333, 5873372, 5873385, 5873417, 110769355, 110769356, 110769361, 110769368, 110769383, 110769409, 110769411, 110769626, 110769704, 800845, 5938896, 5938896, 5938948, 5938954, 5938977, 5938985, 5865265, 13671747, 2043569, 2043571, 649957, 750939, 750939, 3434060, 1384732, 1534137, 1534182, 3418277, 3418278, 629458, 629464)
AND PRE.UPDATE_DATE > SYSDATE - 2
;

SELECT *
FROM PREFILING.CASE_TRANSACTION
WHERE(TRANSACTION_ID IN (12588399023, 12588399024, 12588911226, 12588911227, 12588911228, 12588911229, 12588911230, 12588911231, 12588911232, 12588911233, 12588911234, 12588911235, 12588911236, 12588911237, 12588911238, 12588911239, 12588911240, 12588911241, 12588911242, 12588911243, 12588911244, 12588911245, 12588911246, 12588911247, 12588911248))
AND CASE_ID IN ( 22136 )
;


*/

