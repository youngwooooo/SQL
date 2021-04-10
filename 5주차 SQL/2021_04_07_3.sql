 < 테이블 생성 및 기초자료 삽입 >
 ** 다음 조건에 맞는 재고수불 테이블을 생성하시오
    1. 테이블명 : REMAIN
    2. 컬럼
    -----------------------------------------------------
     컬럼명             데이터타입               제약사항
    -----------------------------------------------------
    REMAIN_YEAR         CHAR(4)                 PK
    PROD_ID             VARCHAR2(10)            PK & FK
    REMAIN_J_00         NUMBER(5)               DEFAULT 0  -- 기초재고
    REMAIN_I            NUMBER(5)               DEFAULT 0  -- 입고수량
    REMAIN_O            NUMBER(5)               DEFAULT 0  -- 출고수량
    REMAIN_J_99         NUMBER(5)               DEFAULT 0  -- 기말재고
    REMAIN_DATE         DATE                    DEFAULT SYSDATE  -- 처리일자
    
  ** 테이블 생성명령
  CREATE TABLE 테이블명(
    컬럼명1 데이터타입[(크기)] [NOT NULL][DEFAULT 값|수식] [,] 
    컬럼명2 데이터타입[(크기)] [NOT NULL][DEFAULT 값|수식] [,]
                            :
    컬럼명n 데이터타입[(크기)] [NOT NULL][DEFAULT 값|수식] [,]
    
    CONSTRAINT 기본키설정명 PRIMARY KEY (컬럼명1[, 컬럼명2, ....]) [,]  -- 기본키설정명 PK_테이블명
    CONSTRAINT 외래키설정명1 FOREIGN KEY (컬럼명1[, 컬럼명2, ....])     -- 외래키설정명 FK_테이블명_참조테이블
        REFERENCES 테이블명1(컬럼명1[, 컬럼명2, ....])[,]
                            :
     CONSTRAINT 외래키설정명n FOREIGN KEY (컬럼명1[, 컬럼명2, ....])
        REFERENCES 테이블명1(컬럼명1[, 컬럼명2, ....]);
 
 CREATE TABLE REMAIN(
    REMAIN_YEAR         CHAR(4),
    PROD_ID             VARCHAR2(10),
    REMAIN_J_00         NUMBER(5) DEFAULT 0,
    REMAIN_I            NUMBER(5) DEFAULT 0,
    REMAIN_O            NUMBER(5) DEFAULT 0,
    REMAIN_J_99         NUMBER(5) DEFAULT 0,
    REMAIN_DATE         DATE);
    
 ALTER TABLE REMAIN
    ADD
    CONSTRAINT pk_remain PRIMARY KEY(REMAIN_YEAR, PROD_ID);
        
 ALTER TABLE REMAIN
    ADD
    CONSTRAINT fk_remain_prod FOREIGN KEY(PROD_ID)
        REFERENCES PROD(PROD_ID);
 
  ** REMAIN 테이블에 기초자료 삽입
  년도 : 2005
  상품코드: 상품테이블의 상품코드
  기초재고 : 상품테이블의 적정재고(PROD_PROPERSTOCK)
  입고수량/출고수량 : 없음
  처리일자 : 2004/12/31
  
INSERT INTO REMAIN(REMAIN_YEAR, PROD_ID, REMAIN_J_00,  REMAIN_J_99, REMAIN_DATE)  -- INSERT절에 서브쿼리는 ()를 쓰지 않는다.
    SELECT '2005', PROD_ID, PROD_PROPERSTOCK, PROD_PROPERSTOCK, TO_DATE('20041231')
    FROM PROD;
    
  ** 테이블 컬럼명 변경
  ALTER TABLE 테이블명
    RENAME COLUMN 변경대상컬럼명 TO 변경컬럼명;
테이블 컬럼명 변경 EX 1) TEMP 테이블의 ABC를 QAZ라는 컬럼명으로 변경
ALTER TABLE TEMP
    RENAME COLUMN ABC TO QAZ;
    
  ** 컬럼 데이터타입(크기) 변경
  ALTER TABLE 테이블명
    MODIFY 컬럼명 데이터타입(크기);
    
    데이터타입(크기) 변경 EX 1) TMEP 테이블의 ABC컬럼을 NUMBER(10)으로 변경하는 경우
    ALTER TABLE TEMP
        MODIFY ABC NUMBER(10);
        -- 해당컬럼의 내용을 모두 지워야 변경 가능
  