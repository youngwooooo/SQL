-- 월별 실적
                반도체     핸드폰     냉장고
 2021년 1월 :     500        300      400
 2021년 2월 :     0           0       0
 2021년 3월 :   500         300      400
 .
 .
 .
 .
 .
 2021년 12월 :   500          300     400
-- [outer join 실습 1] 
SELECT buy_date, buy_prod, prod_id, prod_name, NVL(buy_qty, 0)
FROM buyprod, prod
WHERE buyprod.buy_prod(+) = prod.prod_id
  AND buy_date(+) = TO_DATE('2005/01/25', 'YYYY/MM/DD');

-- [outer join 실습 2~3]
-- 실습1에서 작업시작, buy_date 컬럼이 null인 항목이 안나오도록 다음처럼 데이터를 채워지도록 쿼리 작성
-- buy_qty가 null값이면 0으로 나오게 쿼리 작성
SELECT TO_DATE(:yyyymmdd, 'YYYY/MM/DD'), buy_prod, prod_id, prod_name, NVL(buy_qty, 0)
FROM buyprod, prod
WHERE buyprod.buy_prod(+) = prod.prod_id
  AND buy_date(+) = TO_DATE(:yyyymmdd, 'YYYY/MM/DD');
  
-- [outer joint 실습 4]
-- cycle, product 테이블을 이용하여 고객이 애음하는 제품 명칭을 표현하고, 애음하지 않는 제품도 다음과 같이 조회되도록 쿼리 작성
-- 고객은 cid=1인 고객만 나오도록 제한, null 처리
SELECT *
FROM cycle;

SELECT *
FROM product;

SELECT product.*, cycle.day, cycle.cnt
FROM product LEFT OUTER JOIN cycle ON(product.pid = cycle.pid AND cid = 1);

SELECT product.*, :cid, NVL(cycle.day, 0), NVL(cycle.cnt, 0) cnt
FROM product LEFT OUTER JOIN cycle ON(product.pid = cycle.pid AND cid = :cid);

과제 : OUTER JOINT 실습 5
OUTER JOINT 실습 4를 바탕으로 고객 이름 컬럼 추가하기

SELECT *
FROM cycle, product, customer
WHERE cycle.pid = product.pid
  AND cycle.cid = customer.cid; 


SELECT product.*, cycle.day, cycle.cnt, customer.cnm
FROM cycle RIGHT OUTER JOIN product ON(product.pid = cycle.pid AND cid = 1)
           LEFT OUTER JOIN customer ON(cycle.cid = customer.cid);
--------------------------------------------------------------------------------------------------------------------------------

WHRER, GROUP BY(그룹핑), JOIN

JOIN
문법 : ANSI / ORACLE
논리적 형태 : SELF JOIN, NON-EQUI-JOIN <==> EQUI-JOIN
연결조건 성공, 실패에 따라 조회여부 결정 : OUTER JOIN <==> INNER JOIN : 연결이 성공적으로 이루어진 행에 대해서만 조회가 되는 조인

SELECT *
FROM dept INNER JOIN emp ON(dept.deptno = emp.deptno);

CROSS JOIN : 별도의 연결 조건이 없는 조인
             묻지마 조인
             두 테이블의 행간 연결가능한 모든 경우의 수로 연결
             ==> CROSS JOIN의 결과는 두 테이블의 행의 수를 곱한 값과 같은 행이 변환된다.
             데이터 복제를 위해 사용!

SELECT *
FROM emp CROSS JOIN dept;

-- [CROSS JOIN 실습 1]
-- customer, product 테이블을 이용하여 고객이 애음 가능한 모든 제품의 정보를 결합하여 다음과 같이 조회하도록 쿼리 작성
SELECT *
FROM customer CROSS JOIN product;

-- 대전 중구의 버거지수 구하기
-- 도시발전지수 : (kfc + 맥도날드 + 버거킹) / 롯데리아
-- 행을 컬럼으로 변경(FIVOT)
SELECT sido, sigungu,
    ROUND( (SUM(DECODE(storecategory, 'BURGER KING', 1, 0)) +
    SUM(DECODE(storecategory, 'KFC', 1, 0)) +
    SUM(DECODE(storecategory, 'MACDONALD', 1, 0)) ) /
    DECODE(SUM(DECODE(storecategory, 'LOTTERIA', 1, 0)), 0, 1, SUM(DECODE(storecategory, 'LOTTERIA', 1, 0))), 2) ldx
FROM burgerstore
GROUP BY sido, sigungu
ORDER BY ldx DESC;




  























