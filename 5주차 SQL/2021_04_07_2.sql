< 저장 프로시져(Stored Procedure : Procedure) >
  - 특정 결과를 산출하기 위한 코드의 집합(모듈)
  - 반환값이 없음 <-> FUNCTION(반환값 존재)
  - 독립적으로 실행
  - 컴파일되어 서버에 보관(실행속도 증가, 은닉성, 보안성) => 필요할 때 꺼내서 사용하면 된다.
  - 특정한 결과를 산출하기 위해 사용
  (사용형식)
  CREATE [OR REPLACE] PROCEDURE 프로시져명[(매개변수명[IN | OUT | INOUT] 데이터 타입 [[:= | DEFAULT] expr],  -- 데이터타입의 크기를 정하면 절대안됨! 딱 타입만!
                                           매개변수명[IN | OUT | INOUT] 데이터 타입 [[:= | DEFAULT] expr],  -- []의 내용이 생략되면 시스템은 IN으로 인식함
                                           매개변수명[IN | OUT | INOUT] 데이터 타입 [[:= | DEFAULT] expr],
                                                                    :
                                           매개변수명[IN | OUT | INOUT] 데이터 타입 [[:= | DEFAULT] expr])]
  AS | IS
    선언영역;
  BEGIN
    실행영역:
  END;

저장 프로시져 EX 1) 오늘이 2005년 1월 31일이라고 가정하고 오늘까지 발생된 상품입고 정보를 이용하여 재고 수불테이블을 UPDATE하는 프로시져를 생성하시오.
                  1. 프로시져명 : PROC_REMAIN_IN
                  2. 매개변수 : 상품코드, 매입수량
                  3. 처리 내용 : 해당 상품코드에 대한 입고수량, 현재입고수량, 날짜 UPDATE

** 1. 2005년 상품별 매입수량 집계 -- 프로시져 받아 커리
   2. 1의 결과 각 행을 PROCEDURE에 전달
   3. PROCEDURE에서 재고 수불테이블 UPDATE
   
   (PROCEDURE 생성)
   CREATE OR REPLACE PROCEDURE PROC_REMAIN_IN(
                                    P_CODE IN PROD.PROD_ID%TYPE,
                                    P_CNT IN NUMBER)
    IS
    BEGIN
        UPDATE REMAIN
        SET (REMAIN_I, REMAIN_J_99, REMAIN_DATE) = (SELECT REMAIN_I+P_CNT,
                                                           REMAIN_J_99+P_CNT,
                                                           TO_DATE('20050131')
                                                    FROM REMAIN
                                                    WHERE REMAIN_YEAR = '2005'
                                                      AND PROD_ID = P_CODE)

        WHERE REMAIN_YEAR = '2005'
          AND PROD_ID = P_CODE;
    END;
 -------------------------------------------------------------------------------------------------------------------------------   
        
    2. 프로시져 실행명령
    EXEC|EXECUTE 프로시져명[(매개변수 list)];
    - 단, 익명블록 등 또 다른 프로시져나 함수에서 프로시져 호출 시 'EXEC|EXECUTE'는 생략해야한다.
     
     (2005년 1월 상품별 매입집계) -- '~별' = GROUP BY 써야함.
     SELECT BUY_PROD BCODE, SUM(BUY_QTY) BAMT
     FROM BUYPROD
     WHERE BUY_DATE BETWEEN '20050101' AND '20050131'
     GROUP BY BUY_PROD;
    
     (익명블록 작성)
    DECLARE
        CURSOR CUR_BUY_AMT
        IS
        SELECT BUY_PROD BCODE, SUM(BUY_QTY) BAMT
        FROM BUYPROD
        WHERE BUY_DATE BETWEEN '20050101' AND '20050131'
        GROUP BY BUY_PROD;
    BEGIN
        FOR REC01 IN CUR_BUY_AMT
        LOOP
            PROC_REMAIN_IN(REC01.BCODE, REC01.BAMT);
        
        END LOOP;
    END;
    
    ** REMAIN 테이블의 내용을 VIEW로 구성
    CREATE OR REPLACE VIEW V_REMAIN01
    AS
        SELECT *
        FROM REMAIN;
        
    CREATE OR REPLACE VIEW V_REMAIN02
    AS
        SELECT *
        FROM REMAIN;
        
SELECT * FROM V_REMAIN01;        
SELECT * FROM V_REMAIN02;

저장 프로시져 EX 2) 회원아이디를 입력받아 그 회원의 이름, 주소, 직업을 반환하는 프로시져를 작성
                    1. 프로시져명 : PROC_MEM_INFO
                    2. 매개변수 : 입력용 : 회원아이디
                                 출력용 : 이름, 주소, 직업
                                 
(프로시져 생성)
CREATE OR REPLACE PROCEDURE PROC_MEM_INFO(
                P_ID MEMBER.MEM_ID%TYPE,
                P_NAME OUT MEMBER.MEM_NAME%TYPE,
                P_ADDR OUT VARCHAR2,
                P_JOB OUT MEMBER.MEM_JOB%TYPE)
AS
BEGIN
    SELECT MEM_NAME, MEM_ADD1||' '||MEM_ADD2, MEM_JOB
        INTO P_NAME, P_ADDR, P_JOB
    FROM MEMBER
    WHERE MEM_ID = P_ID;
END;

(프로시져 실행)
ACCEPT PID PROMPT '회원아이디 : '
DECLARE
    V_NAME MEMBER.MEM_NAME%TYPE;
    V_ADDR VARCHAR(200);
    V_JOB MEMBER.MEM_JOB%TYPE;
BEGIN
    PROC_MEM_INFO('&PID', V_NAME, V_ADDR, V_JOB);
    DBMS_OUTPUT.PUT_LINE('회원아이디 : '||'&PID');
    DBMS_OUTPUT.PUT_LINE('이름 : '||V_NAME);
    DBMS_OUTPUT.PUT_LINE('주소 : '||V_ADDR);
    DBMS_OUTPUT.PUT_LINE('직업 : '||V_JOB);
END;    

저장 프로시져 문제 1) 년도를 입력받아 해당년도에 구매를 가장 많이한 회원이름, 구매액을 반환하는 프로시져를 작성하시오.
                    1. 프로시져명 : PROC_MEM_PTOP
                    2. 매개변수 : 입력용 : 년도(2005년) 
                                 출력용 : 회원이름, 구매액
                                 
** 2005년도 회원별 구매금액
SELECT M.MEM_NAME, A.AMT
FROM(SELECT C.CART_MEMBER MID, SUM(C.CART_QTY*P.PROD_PRICE) AMT
     FROM CART C, PROD P
     WHERE C.CART_PROD = P.PROD_ID
       AND SUBSTR(C.CART_NO, 1, 4) = '2005'
     GROUP BY C.CART_MEMBER
     ORDER BY 2 DESC) A, MEMBER M
WHERE M.MEM_ID = A.MID
  AND ROWNUM = 1;

** 프로시져 생성
CREATE OR REPLACE PROCEDURE PROC_MEM_PTOP(
                            P_YEAR IN CHAR,
                            P_NAME OUT MEMBER.MEM_NAME%TYPE,
                            P_AMT OUT NUMBER)
AS
BEGIN
    SELECT M.MEM_NAME, A.AMT INTO P_NAME, P_AMT
    FROM(SELECT C.CART_MEMBER MID, SUM(C.CART_QTY*P.PROD_PRICE) AMT
         FROM CART C, PROD P
         WHERE C.CART_PROD = P.PROD_ID
           AND SUBSTR(C.CART_NO, 1, 4) = P_YEAR
         GROUP BY C.CART_MEMBER
         ORDER BY 2 DESC) A, MEMBER M
    WHERE M.MEM_ID = A.MID
      AND ROWNUM = 1;
END;

** 프리시져 실행
DECLARE
    V_NAME MEMBER.MEM_NAME%TYPE;
    V_AMT NUMBER:= 0;
BEGIN
    PROC_MEM_PTOP('2005', V_NAME, V_AMT);
    
    DBMS_OUTPUT.PUT_LINE('회원이름 : '||V_NAME);
    DBMS_OUTPUT.PUT_LINE('구매금액 : '||TO_CHAR(V_AMT, '99,999,999'));    
END;


저장 프로시져 문제 2) 2005년도 구매금액이 없는 회원을 찾아 회원테이블(MEMBER)의 삭제여부 컬럼(MEM_DELETE)의 값을 'Y'로 변경하는 프로시저를 작성하시오.
1. 2005년 구매금액이 없는 사람을 찾는다. (여러명이면 커서)
2. 회원번호를 커서에서 생성해서 하나씩 읽어서 MEMBER테이블과 비교해서 MEM_DELETE 를 Y로 업데이트 시킨다.
  
  (프로시져 생성 : 입력받은 회원번호로 해당 회원의 삭제여부 컬럼값을 변경)
  CREATE OR REPLACE PROCEDURE PROC_MEM_UPDATE(
                              P_MID IN MEMBER.MEM_ID%TYPE)
  AS
  BEGIN
    UPDATE MEMBER 
       SET MEM_DELETE = 'Y'
    WHERE MEM_ID = P_MID;
    COMMIT;
  END;
  
  (구매금액이 없는 회원)
  DECLARE
    CURSOR CUR_MID
    IS  
        SELECT MEM_ID
          FROM MEMBER
         WHERE MEM_ID NOT IN (SELECT CART_MEMBER
                                FROM CART A
                               WHERE CART_NO LIKE '2005%');
  BEGIN
    FOR REC_MID IN CUR_MID
    LOOP
        PROC_MEM_UPDATE(REC_MID.MEM_ID);
    END LOOP;
  END;    