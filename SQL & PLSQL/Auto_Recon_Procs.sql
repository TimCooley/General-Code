

BEGIN
-- P1 INELIGIBLE INSTRUMENTS
    FOR i IN (SELECT DISTINCT cl.client_id, p.case_id 
              FROM PREFILING.CASE_TRANSACTION p, client cl 
              WHERE p.CASE_ID IN (&CASE_ID_VAR) 
              AND p.client_id = cl.client_id 
              AND cl.short_name IN (SELECT SHORT_NAME FROM FRT.CLIENT WHERE STATUS IN ('ACTIVE','APPROVAL'))) 
    LOOP
        OPS_APP.INELIGIBLE_INTRUMENTS(P_CASE_ID => i.CASE_ID, P_CLIENT_NAME => i.CLIENT_ID);
    END LOOP;
    
    -- P2 DF DUPES TRANSACTIONS
    FOR i IN (SELECT DISTINCT cl.client_id, p.case_id 
              FROM PREFILING.CASE_TRANSACTION p, client cl 
              WHERE p.CASE_ID IN (&CASE_ID_VAR) 
              AND p.client_id = cl.client_id 
              AND cl.short_name IN (SELECT SHORT_NAME FROM FRT.CLIENT WHERE STATUS IN ('ACTIVE','APPROVAL'))) 
    LOOP 
        OPS_APP.DIFF_FILE_DUPE(P_CASE_ID => i.CASE_ID, P_CLIENT_NAME => i.CLIENT_ID);
    END LOOP;
    
    -- P3 IN AND OUT
/*    FOR i IN (SELECT DISTINCT cl.client_id, p.case_id 
              FROM PREFILING.CASE_TRANSACTION p, client cl 
              WHERE p.CASE_ID IN (&CASE_ID_VAR) 
              AND p.client_id = cl.client_id 
              AND cl.short_name IN (SELECT SHORT_NAME FROM FRT.CLIENT WHERE STATUS IN ('ACTIVE','APPROVAL'))) 
    LOOP 
        OPS_APP.IN_AND_OUT_SECURITY_IDENTIFIER_MODIFIED(P_CASE_ID => i.CASE_ID, P_CLIENT_NAME => i.CLIENT_ID);
    END LOOP;*/
    
    -- P4 DF DUPES HOLDINGS
     FOR i IN (SELECT DISTINCT cl.client_id, p.case_id 
              FROM prefiling.case_holding_position p, client cl 
              WHERE p.CASE_ID IN (&CASE_ID_VAR) 
              AND p.client_id = cl.client_id 
              AND cl.short_name IN (SELECT SHORT_NAME FROM FRT.CLIENT WHERE STATUS IN ('ACTIVE','APPROVAL'))) 
    LOOP 
        OPS_APP.DIFF_FILE_DUPE_HOLDING (P_CASE_ID => i.CASE_ID, P_CLIENT_NAME => i.CLIENT_ID);
    END LOOP;
    
END;

