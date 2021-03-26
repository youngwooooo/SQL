-- [서브쿼리 실습 6]
-- cycle 테이블을 이용하여 cid=1인 고객이 애음하는 제품중 cid=2인 고객도 애음하는 제품의 애음정보를 조회하는 쿼리를 작성하세요.
SELECT *
FROM cycle
WHERE cid = 1;
2번 고객이 먹는 제품에 대해서만 1번 고객이 먹는 애음 정보 조회

SELECT *
FROM cycle
WHERE cid = 2;

SELECT *
FROM cycle
WHERE cid = 1
  AND pid IN(SELECT pid
             FROM cycle
             WHERE cid = 2);
             
-- [서브쿼리 실습 7]
-- 6번 문제에 customer, product 테이블을 추가로 조회하여 고객명과 제품명까지 포함하는 쿼리 작성
SELECT *
FROM cycle, customer, product
WHERE cycle.cid = 1
  AND cycle.cid = customer.cid
  AND cycle.pid = product.pid
  AND cycle.pid IN(SELECT s.pid
                   FROM cycle s
                   WHERE cid = 2);
                   
                   
EXISTS 서브쿼리 연산자 : 단항 연산자
EXISTS : WHERE EXISTS (서브쿼리)
            ==> 서브쿼리의 실행결과로 조회되는 행이 있으면 TRUE, 없으면 FALSE
            EXISTS 연산자와 사용되는 서브쿼리는 상호연관, 비상호연관 서브쿼리를 둘 다 사용 가능하지만
            행을 제한하기 위해서 상호관련 서브쿼리와 사용되는경우가 일반적.
            
            서브쿼리에서 EXISTS 연산자를 만족하는 행을 하나라도 발견을 하면 더이상 진행하지 않고 효율적으로 일을 끊어 버린다.
            서브쿼리가 1000건이라 하더라도 10번째 행에서 EXISTS 연산을 만족하는 행을 발견하면 나머지 999건 정도의 데이터는 확인 안한다.
            
-- 매니저가 존재하는 직원
SELECT *
FROM emp
WHERE mgr IS NOT NULL;

SELECT *
FROM emp e
WHERE EXISTS (SELECT empno
              FROM emp m
              WHERE e.mgr = m.empno);
              
SELECT *
FROM emp e
WHERE EXISTS (SELECT 'X'
              FROM emp m
              WHERE e.mgr = m.empno);  --> 행의 값이 중요하지 않음. 존재하기만 하면 됨!              

SELECT COUNT(*) cnt
FROM emp
WHERE deptno = 10;

SELECT *
FROM dual
WHERE EXISTS (SELECT 'X' FROM emp WHERE deptno = 10); 

-- [서브쿼리 실습9]
-- cycle, product 테이블 이용 cid=1인 고객이 애음하는 제품을 조회하는 쿼리를 EXISTS 연산자를 이용하여 작성
SELECT *
FROM product
WHERE EXISTS (SELECT 'X'
              FROM cycle
              WHERE cid = 1
               AND product.pid = cycle.pid);

SELECT *
FROM product
WHERE NOT EXISTS (SELECT 'X'
                  FROM cycle
                  WHERE cid = 1
                   AND product.pid = cycle.pid);
                   
<집합연산>
- 데이터를 확장하는 sql의 한 방법
- 수학에서 배우는 집합의 개념과 동일
- 행(row)를 확장 : 위 아래 집합의 col개수와 타입이 일치해야 한다.

1. UNION / UNION ALL (합집합)
- UNION : {a,b} U {a,c} = {a,b,c}
          수학에서 말하는 일반적인 합집합(중복 제거)
          두 개의 SELECT 결과를 하나로 합친다.
SELECT empno, ename
FROM emp
WHERE empno IN(7369, 7499)

UNION

SELECT empno, ename
FROM emp
WHERE empno IN(7369, 7521);

- UNION ALL : {a,b} U {a,c} = {a,a,b,c}
              중복을 허용하는 합집합, 중복 제거 로직이 없기 때문에 속도가 빠름.
              합집합 하려는 집합간 중복이 없다는 것을 알고 있을 경우 UNION 연산자 보다 UNION ALL 연산자가 유리하다.
SELECT empno, ename
FROM emp
WHERE empno IN(7369, 7499)

UNION ALL

SELECT empno, ename
FROM emp
WHERE empno IN(7369, 7521);

2. INTERSECT (교집합) : 두 개의 집합 중 중복되는 부분만 조회
SELECT empno, ename
FROM emp
WHERE empno IN(7369, 7499)

INTERSECT

SELECT empno, ename
FROM emp
WHERE empno IN(7369, 7521);

3. MINUS (차집합) : 왼쪽 집합에서 다른 한쪽 집합을 제외한 나머지 요소들을 반환
                   왼쪽 집합과 다른 한쪽 집합과 중복 값이 있으면 중복 제거
SELECT empno, ename
FROM emp
WHERE empno IN(7369, 7499)

MINUS

SELECT empno, ename
FROM emp
WHERE empno IN(7369, 7521);

<교환 법칙>
A U B == B U A (UNION, UNION ALL)
A ^ B == B ^ A 
A - B != B - A  ==> 집합의 순서에 따라 결과가 달라질 수 있다!!

<집합연산의 특징>
1. 집합연산의 결과로 조회되는 데이터의 컬럼 이름은 첫 번째 집합의 컬럼을 따른다.
SELECT empno e, ename enm
FROM emp
WHERE empno IN(7369, 7499)

UNION

SELECT empno, ename
FROM emp
WHERE empno IN(7369, 7521);

2. 집합연산의 결과를 정렬하고 싶으면 가장 마지막 집합 뒤에 ORDER BY를 기술한다.
    - 개별 집합에 ORDER BY를 사용한 경우 에러
    - 단, ORDER BY를 적용한 인라인 뷰를 사용하는 것은 가능(일반적으로 사용 X)
SELECT e, enm
FROM
(SELECT empno e, ename enm
FROM emp
WHERE empno IN(7369, 7499)
ORDER BY e)

UNION

SELECT empno, ename
FROM emp
WHERE empno IN(7369, 7521)
ORDER BY e;

3. 중복된 값은 제거 된다.(UNION ALL은 예외)

4. ORACLE 9i 이전 버전에서 그룹연산을 하게 되면 자동으로 오름차순으로 정렬되어 나온다.
             이후 버전부터는 정렬을 보장하지 않는다.
             
<DML>
- SELECT
- 데이터 신규 입력 : INSERT
- 기존 데이터 수정 : UPDATE
- 기존 데이터 삭제 : DELETE

1. INSERT 문법
- INSERT INTO 테이블명 (컬럼명1, 컬럼명2, 컬럼명3, ....)
               VALUES (값1, 값2, 값3, ....)
- 만약 테이블에 존재하는 모든 컬럼에 데이터를 입력하는 경우 컬럼명은 생략 가능하고,
  값을 기술하는 순서를 테이블에 정의된 컬럼 순서와 일치시킨다. DESC를 통해 테이블 조회해서 알아보기
  INSERT INTO 테이블명 VALUES (값1, 값2, 값3, ....)     

SELECT *
FROM emp;

INSERT INTO emp (empno, ename, job, hiredate, sal, comm) 
            VALUES (9998, 'sally', 'RANGER', TO_DATE('2021-03-24', 'YYYY-MM-DD'), 1000, NULL);
            
- 여러 건을 한 번에 입력하기
INSERT INTO 테이블명
SELECT 쿼리

INSERT INTO dept
SELECT 90, 'DDIT', '대전' FROM dual UNION ALL
SELECT 80, 'DDIT8', '대전' FROM dual;       

SELECT *
FROM dept;

2. UPDATE : 테이블에 존재하는 기존 데이터의 값을 변경

UPDATE 테이블명 SET 컬럼명1=값1, 컬럼명2=값2, 컬럼명3=값3, ....
WHERE

SELECT *
FROM dept;

- 부서번호 99번 부서정보를 부서명=대덕IT로, loc=영민빌딩으로 변경

UPDATE dept SET dnmae = '대덕IT', loc = '영민빌딩'  ==> X

WHERE절이 누락되었는지 확인!
WEERE절이 누락 된 경우 테이블의 모든 행에 대해 업데이트를 진행, 모든 행의 컬럼이 바뀌어버린다!

UPDATE dept SET dname = '대덕IT', loc = '영민빌딩'
WHERE deptno = 99;

SELECT *
FROM dept;






