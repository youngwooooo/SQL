-- date
-- 날짜 조작 관련 함수
-- MONTHS_BETWEEN : 두 일자 사이의 떨어져있는 개월 수 / 인자 - start date, end date, 반환 값 /
-- ADD_MONTHS : 인자 - date, number n : date로부터 n개월 뒤의 날짜
-- NEXT_DAY : 인자 - date, number(weekday, 주간일자) : date 이후의 가장 첫번째 주간일자에 해당하는 date를 변환
-- LAST_DAY(DATE) : 인자 - date : date가 속한 월의 마지막 일자를 date로 반환

-- MONTHS_BETWEEN
SELECT ename, TO_CHAR(hiredate, 'yyyy/mm/dd hh24:mi:ss') hiredate,
       MONTHS_BETWEEN(sysdate, hiredate) month_between,
       -- ==> 개월 수가 딱 떨어지지 않고 소숫점자리까지 나오는데 소숫점을 반올림하던 절삭해서 사용한다. 잘 사용하지 않는다.
       -- 회사 근속 년수를 알고 싶을 때 사용함.
       ADD_MONTHS(sysdate, 5) ADD_MONTHS,
       ADD_MONTHS(TO_DATE('2021-02-15', 'YYYY/MM/DD'), - 5),
       NEXT_DAY(sysdate, 1) NEXT_DAY,
       -- 다음 주 일요일을 알려줌
       LAST_DAY(sysdate) LAST_DAY
FROM emp;

-- SYSDATE를 이용하여 SYSDATE가 속한 월의 첫번째 날자 구하기
SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM') || '01', 'YYYYMMDD') FIRST_DAY
FROM dual;

SELECT TO_DATE('2021', 'YYYY'),
        -- 월, 일을 정하지 않았기 때문에 현재 시간의 당월, 당일을 기본 값으로 함. 
       TO_DATE('2021' || '0101', 'YYYYMMDD')
FROM dual;

-- [DATE 종합 실습 3]
-- 파라미터로 YYYYMM형식의 문자열을 사용하여 (ex : yyyymm = 201912) 해당 년월에 해당하는 일자 수(마지막일)를 구해보세요
SELECT :yyyymm PARAM, 
        TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'yyyymm')), 'DD') DT
FROM dual;

-- 1. 형변환
-- 1) 명시적 형변환
--    TO_DATE, TO_CAHR, TO_NUMBER
-- 2) 묵시적 형변환
SELECT *
FROM emp
WHERE empno = '7369';

-- NUMBER의 FORMAT
-- 9 : 숫자
-- 0 : 강제로 0 표시
-- , : 1000자리 표시
-- . : 소수점
-- L : 화폐 단위(사용자 지역)
-- $ : 달러 화폐 표시

-- NULL 처리 함수
-- 1. NVL(expr1, expr2) : 컬럼 or 가공된 값 다 올 수 있음 / expr1이 NULL 값이 아니면 expr1을 사용하고 expr1이 NULL값이면 expr2로 대체해서 사용한다.
-- emp 테이블에서 comm 컬럼의 값이 NULL일 경우 0으로 대체 해서 조회하기
SELECT empno, sal, comm, NVL(comm, 0), 
       sal + NVL(comm, 0) nvl_sal_comm,
       NVL(sal+comm, 0) nvl_sal_comm2
FROM emp;

-- 2. NVL2(expr1, expr2, expr3) : expr1이 NULL 값이아니면 expr2를 사용하고 expr1이 null이면 expr3을 사용한다.
-- comm이 null이 아니면 sal+comm을 반환,
-- comm이 null이면 sal을 반환
SELECT empno, sal, comm,
       NVL2(comm, sal+comm, sal) nvl2
FROM emp;

-- 3. NULLIF(expr1, expr2) : 두개의 인자가 같으면 null값을 생성하고, 두개의 인자가 다르면 expr1을 사용한다.
SELECT empno, sal,
       NULLIF(sal, 1250)
FROM emp;

-- 4. COALESCE(expr1, expr2, expr3, .....) : 인자의 개수는 사용자가 정함(무한대로도 가능).
--                                         : expr1의 값이 null이 아니면 expr1을 사용하고 exp1의 값이 null이면 COALESCE(expr2, expr3, ....) 다시 호출해서 사용(재귀함수)
--                                         : 인자들 중에 가장먼저 등장하는 NULL이 아닌 인자를 반환
SELECT empno, sal, comm, COALESCE()
FROM emp;

-- [NULL 실습 4]
-- emp 테이블의 정보를 다음과 같이 조회되도록 쿼리를 작성하세요
SELECT empno, ename, mgr,
       NVL(mgr, 9999) mgr_n,
       NVL2(mgr, mgr, 9999) mgr_1,
       COALESCE(mgr, null, 9999) mgr_2
FROM emp;

-- [NULL 실습 5]
-- user 테이블의 정보를 다음과 같이 조회되도록 쿼리를 작성하세요
-- reg_dt가 null일 경우 sysdate를 적용
SELECT userid, usernm, reg_dt,
       NVL(reg_dt, SYSDATE) n_reg_dt
FROM users
WHERE userid IN('cony', 'james', 'moon', 'sally');
--------------------------------------------------------------------------------------------------------------------------------

-- <조건분기>
-- 1. CASE절
--    WHEN expr1 비교식(참, 거짓을 판단할 수 있는 수식) THEN 사용할 값  ==> if
--    WHEN expr2 비교식(참, 거짓을 판단할 수 있는 수식) THEN 사용할 값2  ==> else if
--    WHEN expr3 비교식(참, 거짓을 판단할 수 있는 수식) THEN 사용할 값3  ==> else if
--    ELSE 사용할 값4  ==> else
--   END

-- 직원들의 급여를 인상하려고 한다.
-- job이 SALESMAN이면 현재 급여에서 5%를 인상
-- job이 MANAGER이면 현재 급여에서 10%를 인상
-- job이 PRESIDENT이면 현재 급여에서 20%를 인상
-- 그 외의 직군은 현재 급여를 유지
SELECT ename, job, sal, 
       CASE
            WHEN job = 'SALESMAN' THEN sal * 1.05
            WHEN job = 'MANAGER' THEN sal * 1.10
            WHEN job = 'PRESIDENT' THEN sal * 1.20
            ELSE sal * 1.0
       END sal_bonus
FROM emp;

-- 2. DECODE 함수 => COALESCE 함수 처럼 가변인자 사용
--  DECODE(expr1, search1, return1, search2, return2, search3, return3, ....[, default]), 무조건 동등비교(=)만 사용
-- --  DECODE(expr1, 
--      search1, return1, 
--      search2, return2, 
--      search3, return3, 
--      ....[, default])
if(expr1 == search1)
    System.out.println(return1)
else if(expr1 == search2)
    System.out.println(return2)
else if(expr1 == search3)
    System.out.println(return3)
else
    System.out.println(default)
    
SELECT ename, job, sal, 
       DECODE(job,
              'SALESMAN', sal * 1.05,
              'MANAGER', sal * 1.10,
              'PRESIDENT', sal * 1.20,
              sal * 1.0) sal_bonus_decode
FROM emp;

-- [codition 실습 1]
-- emp 테이블을 이용하여 deptno에 따라 부서명으로 변경해서 다음과 같이 조회되는 쿼리를 작성하세요.
SELECT empno, ename, deptno,
        DECODE(deptno,
                10, 'ACCOUNTING',
                20, 'RESEARCH',
                30, 'SALES',
                40, 'OPERATIONS', 
                'DDIT') dname_decode, 
                job
FROM emp;

SELECT empno, ename, deptno,
        CASE
            WHEN deptno = 10 THEN 'ACCOUNTING'
            WHEN deptno = 20 THEN 'RESEARCH'
            WHEN deptno = 30 THEN 'SALES'
            WHEN deptno = 40 THEN 'OPERATIONS'
            ELSE 'DDIT'
            END dname_case,
            job
FROM emp;

-- [condition 실습 2]
-- emp 테이블을 이용하여 hiredate에 따라 올해 건강보험 검진 대상자인지 조회하는 쿼리를 작성하세요.
SELECT empno, ename, hiredate, 
    CASE
        WHEN MOD(SUBSTR(hiredate, 1, 4), 2) = MOD(SUBSTR(SYSDATE, 1, 4), 2) THEN '건강검진 대상자'
        ELSE '건강검진 비대상자'
        END CONTACT_TO_DOCTOR
FROM emp;

-- 선생님 풀이
SELECT empno, ename, hiredate,
       CASE
            WHEN
                MOD(TO_CHAR(hiredate, 'yyyy'), 2) =
                MOD(TO_CHAR(SYSDATE, 'yyyy'), 2) THEN '건강검진 대상자'
                ELSE '건강검진 비대상자'
                END CONTACT_TO_DOCTOR
FROM emp;

-- [condition 실습 3]
-- users 테이블을 이용하여 reg_dt에 따라 올해 건강보험 검진 대상자인지 조회하는 쿼리를 작성하세요.
SELECT userid, usernm, reg_dt,
CASE
            WHEN
                MOD(TO_CHAR(reg_dt, 'yyyy'), 2) =
                MOD(TO_CHAR(SYSDATE, 'yyyy'), 2) THEN '건강검진 대상자'
                ELSE '건강검진 비대상자'
                END CONTACT_TO_DOCTOR
FROM users
WHERE userid IN('brown', 'cony', 'james', 'moon', 'sally');

-- <그룹함수(group fucntion)>
-- : 여러 행을 그룹으로 하여 하나의 행으로 결과값을 반환하는 함수
-- ** 그룹 함수에서 NULL컬럼은 계산에서 제외된다!!
-- ** group by절에 작성된 컬럼 이외의 컬럼이 select절에 올 수 없다!!
-- ** where절에 그룹 함수를 조건으로 사용할 수 없다!!
--    ==> HAVING절 사용!
--        WHERE SUM(sal) > 3000 (X)
--        HAVING SUM(sal) > 3000 (X)
-- 1. AVG : 평균
-- 2. COUNT : 건수
-- 3. MAX : 최대값
-- 4. MIN : 최소값
-- 5. SUM : 합
SELECT *
FROM emp;

SELECT deptno, MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal),
        COUNT(sal), -- 그룹핑 된 행 중에 sal 컬럼의 값이 null이 아닌 행의 건수
        COUNT(mgr), -- 그룹핑 된 행 중에 mgr 컬럼의 값이 null이 아닌 행의 건수
        COUNT(*), -- 그룹핑 된 행 건수
        SUM(comm),
        -- SUM이 알아서 null값을 제외하고 합을 구한다.
        SUM(NVL(comm, 0)),
        NVL(SUM(comm), 0)
FROM emp
-- WHERE COUNT(*) >= 4  ==> WHERE절에 그룹함수를 쓰면 오류 HAVING절을 써야함!
HAVING COUNT(*) >= 4
GROUP BY deptno;
-- ** GROUP BY절에 나온 컬럼이 SELECT절에 그룹함수가 적용되지 않은채로 기술되면 에러!!
-- ** 중복되지 않는 값이 있으면 그룹핑이 하나하나씩 된다.

-- GROUP BY를 사용하지 않을 경우 테이블의 모든 행을 하나의 행으로 그룹핑한다.
SELECT COUNT(*), MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal)
FROM emp;

-- [GROUP FUNCTINO 실습 1]
-- emp 테이블을 이용하여 다음을 구하시오.
-- 1) 직원 중 가장 높은 급여
-- 2) 직원 중 가장 낮은 급여
-- 3) 직원의 급여 평균(소수점 두자리까지 나오도록 반올림)
-- 4) 직원의 급여 합
-- 5) 직원 중 급여가 있는 직원의 수(null 제외)
-- 6) 직원 중 상급자가 있는 직원의 수(null 제외)
-- 7) 전체 직원의 수
SELECT MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal), count(sal), count(mgr), count(*)
FROM emp;

-- [GROUP FUNCTINO 실습 2]
-- emp 테이블을 이용하여 다음을 구하시오.
-- 1) 부서기준 직원 중 가장 높은 급여
-- 2) 부서기준 직원 중 가장 낮은 급여
-- 3) 부서기준 직원 급여 평균(소수점 두자리까지 나오도록 반올림)
-- 4) 부서기준 직원 급여 합
-- 5) 부서기준 직원 중 급여가 있는 직원의 수(null 제외)
-- 6) 부서기준직원 중 상급자가 있는 직원의 수(null 제외)
-- 7) 전체 직원의 수
SELECT MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal), count(sal), count(mgr), count(*)
FROM emp
GROUP BY deptno;