< SEQUENCE 객체 >
- 자동으로 증가되는 값을 반환할 수 있는 객체
- 테이블에 독립적(다수의 테이블에서 동시 참조 가능)
- 기본키로 설정할 적당한 컬럼이 존재하지 않는 경우 자동으로 증가되는 컬럼의 속성으로 주로 사용됨

< SEQUENCE 사용형식 >
CREATE SEQUENCE 시퀀스명
    [START WITH n]  -- 시작 값, 생략하면 MINVALUE
    [INCREMENT BY n]  -- 증감값, 생략하면 1  
    [MAXVALUE n | NOMAXVALUE]  -- 사용하는 최대값, default는 NOMAXVALU이고 10^27까지 사용
    [MINVALUE n | NOMINVALUE]  -- 사용하는 최소값, default는 NOMINVALUE이고 1
    [CYCLE | NOCYCLE]  -- 최대(최소)까지 도달한 후 다시 시작할 것인지 여부, default는 NOCYCLE
    [CACHE n | NOCACHE]  -- 생성할 값을 캐시에 미리 만들어 사용, default는 CACHE 20
    [ORDER | NOORDER]  -- 여기서의 ORDER의 의미는 '명령', 정의된대로 시퀀스 생성 강제, default는 NOORDER
    
    -- ** 한 번 건너뛴 숫자는 다시 뒤로 올 수 없다!(재사용 불가)
    
< SEQUENCE 객체 의사(Pseudo Column)컬럼 >
1. 시퀀스명.NEXTVAL : '시퀀스'의 다음 값 변환
2. 시퀀스명.CURRVAL : '시퀀스'의 현재 값 반환
-- 시퀀스가 생성되고 해당 세션의 첫 번째 명령은 반드시 시퀀스명.NEXTVAL여야 함!

SEQUNECE EX 1) LPROD테이블에 다음 자료를 삽입하시오(단, 시퀀스를 이용할 것)
    [자료]
    LPROD_ID: 10번부터
    LPROD_GU : P501     P502      P503    
    LPROD_NM : 농산물    수산물     임산물

1) 시퀀스 생성
CREATE SEQUENCE seq_lprod
    START WITH 10;
    
SELECT seq_lprod.CURRVAL  --> 시퀀스를 생성하고 CURRVAL를 확인하면 첫 번째 값이 배정되지 않아서 알 수가 없어 오류가 난다!
FROM dual;

2) 자료 삽입
INSERT INTO lprod VALUES(seq_lprod.NEXTVAL, 'P501', '농산물')
INSERT INTO lprod VALUES(seq_lprod.NEXTVAL, 'P502', '수산물')
INSERT INTO lprod VALUES(seq_lprod.NEXTVAL, 'P503', '임산물')

SELECT *
FROM lprod;

SEQUENCE EX 2) 오늘이 2005년 7월 28일인 경우 'm001'회원이 제품 'P201000004'을 5개 구입했을 때 CART 테이블에 해당 자료를 삽입하는 쿼리를 작성하시오.
               (먼저 날짜를 2005년 7월 28일로 변경 후 작성할 것)
1. 매출 저장(CART)
2. 재고 조정
--> 위 동작(EVENT)들을 자동적으로 실행해주는 것 : TRIGGER 

1) cart_no 생성
-- SELECT TO_CHAR(TO_CHAR(SYSDATE, 'YYYYMMDD') || MAX(SUBSTR(cart_no, 9))+1)
-- FROM cart;

-- SELECT TO_CHAR(MAX(cart_no)+1) -- 컬럼이 숫자로만 이루어져서 이런식으로 할 수 있다. ORACLE은 문자보다 숫자를 우선시 함
-- FROM cart;

1-1) 순번 확인
SELECT MAX(SUBSTR(cart_no, 9))
FROM cart;

1-2) 시퀀스 생성
CREATE SEQUENCE seq_cart
    START WITH 5;

INSERT INTO cart(cart_member, cart_no, cart_prod, cart_qty)
    VALUES ('m001', (TO_CHAR(SYSDATE, 'YYYYMMDD')||TRIM(TO_CHAR(seq_cart.NEXTVAL, '00000'))), 'P201000004', 5);

SELECT *
FROM cart;

< SEQUENCE가 사용되는 곳 >
  - SELECT문의 SELECT절(단, 서브쿼리인 경우 제외)
  - INSERT문의 SELECT절(서브쿼리), VALUES절  -- INSERT문에 서브쿼리쓸 때는 ()를 안쓴다!
  - UPDATE문의 SET절
  
< SEQUENCE의 사용이 제한되는 곳 >
  - SELECT, DELETE, UPDATE문에서 사용되는 서브쿼리
  - VIEW를 대상으로 사용하는 쿼리
  - DISTINCT가 사용된 SELECT절
  - GROUP BY / ORDER BY가 사용된 SELECT문
  - 집합연산자(UNION, MINUS, INTERSECT)가 사용된 SELECT문
  - SELECT문의 WHERE절