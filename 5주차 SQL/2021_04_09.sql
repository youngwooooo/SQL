< USER DEFINED FUNCTION (FUNCTION) >
  - 사용자가 정의한 함수
  - 반환값이 존재 => SELECT문의 SELECT 절, WHERE 절에서 사용가능!
  - 자주 사용되는 복잡한 QUERY 들을 모듈화시켜 컴파일 한 후 호출하여 사용한다.
  - 데이터를 불러올 때 커서와 같이 함수가 한 번씩 호출되어 하나씩 읽어서 불러오기 때문에 함수를 사용 시 커서를 사용할 필요가 없다.(프로시져와의 차이점)
   (사용형식)
   CREATE [OR REPLACE] FUNCTION 함수명[
        (매개변수 [IN|OUT|INOUT] 데이터타입 [(:= | DEFAULT)] expr][,]
                                  :
        (매개변수 [IN|OUT|INOUT] 데이터타입 [(:= | DEFAULT)] expr])])
         RETURN 데이터타입
    AS|IS
        선언영역;  -- 변수, 상수, 커서
    BEGIN
        실행문;
        RETURN 변수|수식;
        [EXCEPTION
            예외처리문;]
    END;            
  
FUNCTION EX 1) 장바구니테이블에서 2005년 6월 5일 판매된 상품코드를 입력받아 상품명을 출력하는 함수를 작성하시오.
                1. 함수명 : FN_PNAME_OUTPUT
                2. 매개변수 : 입력용 = 상품코드
                3. 반환값 : 상품명
                
CREATE OR REPLACE FUNCTION FN_PNAME_OUTPUT(
                           P_CODE IN PROD.PROD_ID%TYPE)
                           RETURN PROD.PROD_NAME%TYPE
IS
    V_PNAME PROD.PROD_NAME%TYPE;
BEGIN
    SELECT PROD_NAME INTO V_PNAME
    FROM PROD
    WHERE PROD_ID = P_CODE;
    
    RETURN V_PNAME;
END;   

(실행)
SELECT CART_MEMBER, FN_PNAME_OUTPUT(CART_PROD)
  FROM CART
 WHERE CART_NO LIKE '20050605%';
 
FUNCTION EX 2) 2005년 5월 모든 상품별에 대한 매입현황을 조회하시오.
               alias는 상품코드, 상품명, 매입수량, 매입금액
               
(OUTER JOIN 사용)
-- OUTER JOIN : 양 쪽에 모두 해당되는 컬럼이면 많은 쪽을 쓸 것, COUNT함수에 *를 쓰지말 것.
SELECT B.PROD_ID 상품코드,
       B.PROD_NAME 상품명,
       SUM(A.BUY_QTY) 매입수량,
       SUM(A.BUY_QTY*B.PROD_COST) 매입금액
  FROM BUYPROD A, PROD B
 WHERE A.BUY_PROD(+) = B.PROD_ID
   AND A.BUY_DATE BETWEEN '20050501' AND '20050531'  -- 이 조건절로 내부 조인이 되버림
 GROUP BY B.PROD_ID, B.PROD_NAME;               

(ANSI OUTER JOIN 사용)
SELECT B.PROD_ID 상품코드,
       B.PROD_NAME 상품명, 
       NVL(SUM(A.BUY_QTY), 0) 매입수량, 
       NVL(SUM(A.BUY_QTY*B.PROD_COST), 0) 매입금액
  FROM BUYPROD A 
 RIGHT OUTER JOIN PROD B ON (A.BUY_PROD = B.PROD_ID
   AND A.BUY_DATE BETWEEN '20050501' AND '20050531')  
 GROUP BY B.PROD_ID, B.PROD_NAME;

(서브쿼리 사용)
SELECT B.PROD_ID 상품코드,
       B.PROD_NAME 상품명,
       NVL(A.QAMT, 0) 매입수량,
       NVL(A.HAMT, 0) 매입금액
  FROM (SELECT BUY_PROD BID,
           SUM(BUY_QTY) QAMT,
           SUM(BUY_QTY*BUY_COST) HAMT
          FROM BUYPROD
         WHERE BUY_DATE BETWEEN '20050501' AND '20050531'
         GROUP BY BUY_PROD) A, PROD B
 WHERE A.BID(+) = B.PROD_ID;
 
(FUNCTION 사용)
CREATE OR REPLACE FUNCTION FN_BUYPROD_AMT(
    P_CODE IN PROD.PROD_ID%TYPE)
    RETURN VARCHAR2
IS
    V_RES VARCHAR2(100);  -- 매입수량과 매입금액을 문자열로 변환하여 기억
    V_QTY NUMBER:= 0;  -- 매입수량 합계
    V_AMT NUMBER:= 0;  -- 매입금액 합계
BEGIN
    SELECT SUM(BUY_QTY),SUM(BUY_QTY*BUY_COST) INTO V_QTY, V_AMT
      FROM BUYPROD
     WHERE BUY_PROD = P_CODE
       AND BUY_DATE BETWEEN '20050501' AND '20050531';
    IF V_QTY IS NULL THEN
       V_RES:= '0';
    ELSE
    V_RES:= '수량 : '||V_QTY||', '||'구매금액 :'||TO_CHAR(V_AMT, '99,999,999');
    END IF;
    RETURN V_RES;
END;    

(실행)
SELECT PROD_ID 상품코드,
       PROD_NAME 상품명,
       FN_BUYPROD_AMT(PROD_ID) 구매내역
  FROM PROD;       
  
FUNCTION EX 3) 상품코드를 입력받아 2005년도 평균판매횟수, 전체판매수량, 판매금액합계를 출력할 수 있는 함수를 작성하시오.
               1. 함수명 : FN_CART_QAVG -- 평균판매횟수
                          FN_CART_QAMT -- 판매수량합계
                          FN_CART_FAMT -- 판매금액합계
               2. 매개변수 : 입력 = 상품코드, 년도

CREATE OR REPLACE FUNCTION FN_CART_QAVG(
    P_CODE IN PROD.PROD_ID%TYPE,
    P_YEAR IN CHAR)
    RETURN NUMBER
AS
    V_QAVG NUMBER:= 0;
    V_YEAR CHAR(5):= P_YEAR||'%';
BEGIN
    SELECT ROUND(AVG(CART_QTY)) INTO V_QAVG
      FROM CART
     WHERE CART_NO LIKE V_YEAR
       AND CART_PROD = P_CODE;
     
     RETURN V_QAVG;
END;     

(실행)
SELECT PROD_ID,
       PROD_NAME,
       FN_CART_QAVG(PROD_ID, '2005')
  FROM PROD;       
       
FUNCTION 문제 1) 2005년 2~3월 제품별 매입수량을 구하여 재고수불테이블을 UPDATE 하시오. BUYPROD / REMAIN
                처리일자는 2005년 3월 마지막일임.(함수이용)

CREATE OR REPLACE FUNCTION FN_REMAIN_UPDATE(
    P_PID IN PROD.PROD_ID%TYPE,
    P_QTY BUYPROD.BUY_QTY%TYPE,
    P_DATE IN DATE)
    RETURN VARCHAR2
AS
    V_CNT NUMBER:= 0;
    V_MESSAGE VARCHAR2(100);
BEGIN
    UPDATE REMAIN
       SET (REMAIN_I, REMAIN_J_99, REMAIN_DATE)=(SELECT REMAIN_I+P_QTY,
                                                        REMAIN_J_99+P_QTY,
                                                        P_DATE
                                                   FROM REMAIN
                                                  WHERE REMAIN_YEAR = '2005'
                                                    AND PROD_ID = P_PID)
     WHERE REMAIN_YEAR = '2005'
       AND PROD_ID = P_PID;
       V_MESSAGE:= P_PID||'제품 입고처리 완료';
    RETURN V_MESSAGE;
END;    

DECLARE
    CURSOR CUR_BUYPROD
    IS
        SELECT BUY_PROD, SUM(BUY_QTY) AMT
        FROM BUYPROD
        WHERE BUY_DATE BETWEEN '20050201' AND '20050331'
        GROUP BY BUY_PROD;
        
        V_RES VARCHAR2(100);
BEGIN
    FOR REC_BUYPROD IN CUR_BUYPROD
    LOOP
        V_RES:=FN_REMAIN_UPDATE(REC_BUYPROD.BUY_PROD,RED_BUYPROD.AMT,LAST_DAY('20050331'));
      DBMS_OUTPUT.PUT_LINE(V_RES);
  END LOOP;
END;

SELECT * 
  FROM REMAIN;
                
                
    
