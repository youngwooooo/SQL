< 조건문 >
1. IF문
  - 개발언어의 조건문(IF문)과 동일 기능 제공
  
  (사용형식 1)
IF 조건식 THEN
    명령문1;
[ELSE
    명령문2;]
END IF;

 (사용형식 2)
IF 조건식1 THEN
    명령문1;
ELSIF 조건식2 THEN
    명령문2;
[ELSIF 조건식3 THEN
    명령문3;
    :
ELSE
    명령문 n;]
END IF

 (사용형식 3)
IF 조건식1 THEN
    명령문1;
    IF 조건식2 THEN
        명령문2;
    ELSE
        명령문 3;
    END IF;
ELSE
    명령문 4;
END IF

조건문 EX 1) 상품테이블에서 'P201'분류에 속한 상품들의 평균단가를 구하고 해당 분류에 속한 상품들의 판매단가를 비교하여
            같으면 '평균가격 상품'
            적으면 '평균가격 이하 상품'
            많으면 '평균가격 이상 상품'을 출력
            출력은 상품코드, 상품명, 가격, 비고
            
DECLARE 
    V_PCODE PROD.PROD_ID%TYPE;
    V_PNAME PROD.PROD_NAME%TYPE;
    V_PRICE PROD.PROD_PRICE%TYPE;
    V_REMARKS VARCHAR2(50);
    V_AVG_PRICE PROD.PROD_PRICE%TYPE;

CURSOR CUR_PROD_PRICE
IS
    SELECT PROD_ID, PROD_NAME, PROD_PRICE
    FROM PROD
    WHERE PROD_LGU = 'P201';

BEGIN
    SELECT ROUND(AVG(PROD_PRICE)) INTO V_AVG_PRICE
    FROM PROD
    WHERE PROD_LGU = 'P201';

OPEN CUR_PROD_PRICE;
LOOP
    FETCH CUR_PROD_PRICE INTO V_PCODE, V_PNAME, V_PRICE;
    EXIT WHEN CUR_PROD_PRICE%NOTFOUND;
    IF V_PRICE > V_AVG_PRICE THEN
        V_REMARKS:= '평균가격 이상 상품';
    ELSIF V_PRICE < V_AVG_PRICE THEN
        V_REMARKS:= '평균가격 이하 상품';
    ELSE
        V_REMARKS:= '평균가격 상품';
    END IF;
    DBMS_OUTPUT.PUT_LINE(V_PCODE||', '||V_PNAME||', '||V_PRICE||', '||V_REMARKS);
END LOOP;
CLOSE CUR_PROD_PRICE;
END;
--------------------------------------------------------------------------------------------------------------------------------

2. CASE문
  - JAVA의 SWITCH CASE문과 유사기능 제공
  - 다방향 분기 기능 제공
  (사용형식)
  CASE 변수명|수식
    WHEN 값1 THEN
        명령1;
    WHEN 값2 THEN
        명령2;
          :
    ELSE
        명령n;
  END CASE;
  
  CASE WHEN 조건식1 THEN
            명령1;
       WHEN 조건식2 THEN
            명령2;
              :
       ELSE
            명령n;
  END CASE;          
  
CASE EX 1) 수도요금 계산
           물 사용요금(톤당 단가)
           1 ~ 10 : 350원
          11 ~ 20 : 550원
          21 ~ 30 : 900원
           그 이상 : 1500원
           
           하수도 사용료
           사용량 * 450원
           
           26톤 사용 시 요금 : (10*350) + (10*550) + (6*900) + (26 * 450) = 3500 + 5500 + 5400 + 11,700 = 26,100원
           
ACCEPT P_AMOUNT PROMPT '물 사용량 : '
DECLARE
    V_AMT NUMBER:= TO_NUMBER('&P_AMOUNT');
    V_WA1 NUMBER:= 0;  -- 물 사용요금
    V_WA2 NUMBER:= 0;  -- 하수도 사용료
    V_HAP NUMBER:= 0;  -- 요금합계
BEGIN
    CASE WHEN V_AMT BETWEEN 1 AND 10 THEN
              V_WA1:= V_AMT*350;
         WHEN V_AMT BETWEEN 11 AND 20 THEN
              V_WA1:= 3500 + (V_AMT-10)*550;
         WHEN V_AMT BETWEEN 21 AND 30 THEN
              V_WA1:= 3500 + 5500 + (V_AMT-20)*900;
         ELSE
              V_WA1:= 3500 + 5500 + 9000 + (V_AMT-30)*1500;
    END CASE;
    V_WA2:= V_AMT*450;
    V_HAP:= V_WA1 + V_WA2;
    
    DBMS_OUTPUT.PUT_LINE(V_AMT||'톤의 수도요금 : '||V_HAP);
END;    
              