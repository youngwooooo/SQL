< SYNONYM 객체 >
  - 동의어를 의미함
  - 오라클에서 생성된 객체에 별도의 이름을 부여
  - 긴 이름의 객체를 쉽게 사용하기 위한 용도로 주로 사용

< SYNONYM 사용형식 >
CREATE [OR REPLACE] SYNONYM 동의어이름
    FOR 객체명;
    
  - '객체'에 별도의이름인 '동의어 이름'을 부여
  
SYNONYM EX 1) HR계정의 REGIONS테이블의 내용을 조회
SELECT hr.regions.region_id 지역코드,
       hr.regions.region_name 지역명
FROM hr.regions;

1-1) 테이블 별칭을 사용한 경우(쿼리를 빠져나오면 별칭은 사라짐.)
SELECT A.region_id 지역코드,
       A.region_name 지역명
FROM hr.regions A;

1-2) 동의어를 사용한 경우(해당 데이터베이스를 사용하는 동안 계속 변해있다.)
CREATE OR REPLACE SYNONYM reg FOR hr.regions;

SELECT A.region_id 지역코드,
       A.region_name 지역명
FROM reg A;