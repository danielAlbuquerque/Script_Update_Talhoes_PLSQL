create or replace PROCEDURE P_ATUALIZA_TALHOES_SN1 IS
-- CODIFICADO POR DANIEL ALBUQUERQUE

    -- NOVOS TALHOES
    CURSOR TALHOES IS
    select WBS, CD_ATIVO_PROTHEUS, DESC_ATIVO, CERT_FSC, CERT_CERFLOR from v_amc_talhoes@DBL_FLORESTAL;
    TAL TALHOES %ROWTYPE;
    -- FIM NOVOS TALHOES
    
    
    -- DECLARAÇÃO DE VARIÁVEIS
    V_WBS     VARCHAR(40);
    V_CBASE   VARCHAR(40);
    V_RECNO   VARCHAR(50);
    V_TOT_WBS INTEGER;
    V_TOT_ATU INTEGER;
    V_CERFLOR CHAR(1);
    V_FSC     CHAR(1);
    -- FIM DECLARAÇÃO
BEGIN

    DBMS_OUTPUT.ENABLE(1000000);
    V_TOT_WBS := 0;
    V_TOT_ATU := 0;
		OPEN   TALHOES;
      LOOP
        FETCH  TALHOES  INTO   TAL;
        EXIT   WHEN   TALHOES%NOTFOUND;
          BEGIN
              DBMS_OUTPUT.put_line('===================================================================');
              DBMS_OUTPUT.put_line('');
              DBMS_OUTPUT.put_line('VERIFICANDO A WBS -> '||tal.WBS);
          
              V_CBASE   := TRIM(TAL.CD_ATIVO_PROTHEUS);
              V_WBS     := TRIM(TAL.WBS);
              V_RECNO   := NULL;
              V_CERFLOR := TRIM(TAL.CERT_CERFLOR);
              V_FSC     := TRIM(TAL.CERT_FSC);
              
              IF V_FSC IS NULL THEN
                V_FSC := ' ';
              END IF;
              
              IF V_CERFLOR IS NULL THEN
                V_CERFLOR := ' ';
              END IF;
              
              BEGIN
                -- CONSULTA A TABELA SN1 PARA VERIFICAR SE A WBS JÁ EXISTE
                SELECT R_E_C_N_O_ INTO V_RECNO FROM SN1010 WHERE D_E_L_E_T_ = ' ' AND TRIM(N1_WBSSAP) = V_WBS;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  DBMS_OUTPUT.PUT_LINE('WBS NAO CADASTRADA');
                  V_RECNO := NULL;
                WHEN TOO_MANY_ROWS THEN
                  DBMS_OUTPUT.PUT_LINE('REGISTRO DUPLICADO');
                  NULL;
                WHEN OTHERS THEN
                  DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS');
                -- FIM DA CONSULTA
              END;
            
              
            
              
              
              /* SEM COMENTÁRIOS NEH --' */
              IF V_RECNO IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('WBS -> ' || V_WBS || ' JÁ EXISTE');
                DBMS_OUTPUT.put_line('ATUALIZANDO...');
                
                -- EXECUTA A ATUALIZAÇÃO
                BEGIN
                 UPDATE SN1010 SET N1_CERFLOR = V_CERFLOR, N1_FSC = V_FSC WHERE D_E_L_E_T_ = ' ' AND TRIM(N1_WBSSAP) = V_WBS;
                END;
                -- FIM DA ATUALIZAÇÃO
                V_TOT_ATU := V_TOT_ATU + 1;       
                DBMS_OUTPUT.put_line('ATUALIZADO COM SUCESSO!');    
              ELSE
                DBMS_OUTPUT.PUT_LINE('WBS -> ' || V_WBS || ' NÃO EXISTE E NÃO SERÁ ATUALIZADA, SOMENTE APÓS A IMPORTAÇÃO DOS TALHÕES');
              END IF;
          
          END; 
     
      
     
      
        
          V_TOT_WBS := V_TOT_WBS + 1;
		
          DBMS_OUTPUT.put_line('===================================================================');
          DBMS_OUTPUT.put_line('');
      
      
      
      END LOOP;
    CLOSE TALHOES;

    --SALVA AS ALTERAÇÕES
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('TOTAL DE REGISTRO            -> '||V_TOT_WBS);
    DBMS_OUTPUT.PUT_LINE('TOTAL DE REGISTRO ATUALIZADO -> '||V_TOT_ATU);

END P_ATUALIZA_TALHOES_SN1;