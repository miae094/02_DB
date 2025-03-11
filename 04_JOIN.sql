/*
[JOIN 용어 정리]
  오라클                                   SQL : 1999표준(ANSI)
----------------------------------------------------------------------------------------------------------------
등가 조인                               내부 조인(INNER JOIN), JOIN USING / ON
                                            + 자연 조인(NATURAL JOIN, 등가 조인 방법 중 하나)
----------------------------------------------------------------------------------------------------------------
포괄 조인                             왼쪽 외부 조인(LEFT OUTER), 오른쪽 외부 조인(RIGHT OUTER)
                                            + 전체 외부 조인(FULL OUTER, 오라클 구문으로는 사용 못함)
----------------------------------------------------------------------------------------------------------------
자체 조인, 비등가 조인                             JOIN ON
----------------------------------------------------------------------------------------------------------------
카테시안(카티션) 곱                        교차 조인(CROSS JOIN)
CARTESIAN PRODUCT


- 미국 국립 표준 협회(American National Standards Institute, ANSI) 미국의 산업 표준을 제정하는 민간단체.
- 국제표준화기구 ISO에 가입되어 있음.
*/
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- JOIN
-- 하나 이상의 테이블에서 데이터를 조회하기 위해 사용.
-- 수행 결과는 하나의 Result Set으로 나옴.


-- (참고) JOIN은 서로 다른 테이블의 행을 하나씩 이어 붙이기 때문에
--       시간이 오래 걸리는 단점이 있다!


/*
- 관계형 데이터베이스에서 SQL을 이용해 테이블간 '관계'를 맺는 방법.


- 관계형 데이터베이스는 최소한의 데이터를 테이블에 담고 있어
  원하는 정보를 테이블에서 조회하려면 한 개 이상의 테이블에서
  데이터를 읽어와야 되는 경우가 많다.
  이 때, 테이블간 관계를 맺기 위한 연결고리 역할이 필요한데,
  두 테이블에서 같은 데이터를 저장하는 컬럼이 연결고리가됨.  
*/


-----------------------------------------------------------------------------------

-- 사번, 이름, 부서코드, 부서명 조회

-- 사번, 이름, 부서코드는 EMPLOYEE 테이블에서 조회가능
SELECT EMP_ID, EMP_NAME, DEPT_CODE
FROM EMPLOYEE;

SELECT * FROM EMPLOYEE;

-- 부서명은 DEPARTMENT 테이블에서 조회
SELECT * FROM DEPARTMENT;

-- EMPLOYEE 테이블의 DEPT_CODE와
-- DEPARTMENT 테이블의 DEPT_ID를 연결고리로 지정
SELECT EMP_ID, EMP_NAME, DEPT_CODE, DEPT_TITLE
FROM EMPLOYEE
JOIN DEPARTMENT ON(DEPT_CODE = DEPT_ID);

-- 1. 내부 조인(INNER JOIN) (== 등가조인(EQUAL JOIN))
--> 연결되는 컬럼의 값이 일치하는 행들만 조인됨
--> 일치하는 값이 없는 행은 조인에서 제외됨.

-- 작성 방법은 크게 ANSI 구문과 오라클 구문으로 나뉘고
-- ANSI에서 USING 과 ON을 쓰는 방법으로 나뉜다.

-- 1) 연결에 사용할 두 컬럼명이 다른 경우(ON)

-- ANSI
-- 연결에 사용할 컬럼명이 다른 경우(ON)을 사용
SELECT EMP_ID, EMP_NAME, DEPT_CODE, DEPT_TITLE
FROM EMPLOYEE
JOIN DEPARTMENT ON(DEPT_CODE = DEPT_ID);

-- 오라클(등가 조인)
SELECT EMP_ID, EMP_NAME, DEPT_CODE, DEPT_TITLE
FROM EMPLOYEE, DEPARTMENT
WHERE DEPT_CODE = DEPT_ID;

-- DEPARTMENT테이블, LOCATION 테이블을 참조하여
-- 부서명, 지역명 조회

SELECT * FROM DEPARTMENT;
SELECT * FROM LOCATION;
-- ANSI
SELECT DEPT_TITLE, LOCAL_NAME
FROM DEPARTMENT
JOIN LOCATION ON(LOCATION_ID = LOCAL_CODE);

-- 오라클
SELECT DEPT_TITLE, LOCAL_NAME
FROM DEPARTMENT, LOCATION
WHERE LOCATION_ID = LOCAL_CODE;

-- 2) 연결에 사용할 두 컬럼명이 같은 경우
-- EMPLOYEE, JOB 테이블 참조하여
-- 사번, 이름, 직급코드, 직급명 조회

SELECT * FROM EMPLOYEE;
SELECT * FROM JOB;

-- ANSI
-- 연결에 사용할 컬럼명이 같은 경우 USING(컬럼명)을 사용할 수 있다
SELECT EMP_ID, EMP_NAME, JOB_CODE, JOB_NAME
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE);

-- 오라클 -> 테이블의 별칭 사용
SELECT EMP_ID, EMP_NAME, E.JOB_CODE, JOB_NAME
FROM EMPLOYEE E, JOB J
WHERE E.JOB_CODE = J.JOB_CODE;
-- SQL Error [918] [42000]: ORA-00918: 열의 정의가 애매합니다

SELECT EMP_ID, EMP_NAME, JOB.JOB_CODE, JOB_NAME
FROM EMPLOYEE, JOB
WHERE EMPLOYEE.JOB_CODE = JOB.JOB_CODE;

-- INNER JOIN(내부조인)의 특정
--> 연결에 사용된 컬럼의 값이 일치하지 않으면
--> 조회 결과에 포함되지 않는다

-----------------------------------------------------------------------------------

-- 2. 외부 조인(OUTER JOIN)

-- 두 테이블의 지정하는 컬럼값이 일치하지 않는 행도 조인에 포함시킴
-- * OUTER JOIN을 반드시 명시해야 한다
SELECT EMP_ID, EMP_NAME, JOB_CODE, JOB_NAME
FROM EMPLOYEE
/*INNER*/JOIN JOB USING(JOB_CODE);

-- 1) LEFT [OUTER] JOIN : 합치기에 사용한 두 테이블 중 왼편에 기술된 테이블의
-- 컬럼수를 기준으로 JOIN
--> 왼편에 작성된 테이블의 모든 행이 결과에 포함되어야 한다.
-- (JOIN이 안되는 행도 결과에 포함)

-- ANSI 표준
SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE LEFT /*OUTER*/ JOIN DEPARTMENT
ON(DEPT_CODE = DEPT_ID); -- 23행(DEPT_CODE가 NULL인 하동운, 이오리 포함)

-- 오라클 구문
SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE ,DEPARTMENT
WHERE DEPT_CODE = DEPT_ID(+);
-- 반대쪽 테이블 컬럼에 (+) 기호 작성해야 한다.

-- RIGHT[OUTER] JOIN : 합치기에 사용한 두 테이블 중
-- 오른편에 기술된 테이블의 컬럼수를 기준으로 JOIN

-- ANSI
SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE RIGHT /*OUTER*/ JOIN DEPARTMENT
ON(DEPT_CODE = DEPT_ID);
-- 마케팅부, 국내영업부, 해외영업3부와 매칭되는 사원이 EMPLOYEE 테이블에 없음

-- 오라클 구문
SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE, DEPARTMENT
WHERE DEPT_CODE(+) = DEPT_ID;

-- 3) FULL [OUTER] JOIN : 합치기에 사용한 두 테이블이 가진 모든 행을 결과에 포함
-- ** 오라클 구문 FULL OUTER JOIN 사용 못함 **

SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE FULL JOIN DEPARTMENT
ON (DEPT_CODE=DEPT_ID);

SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE, DEPARTMENT
WHERE DEPT_CODE(+) = DEPT_ID(+);
-- SQL Error [1468] [72000]: ORA-01468: outer-join된 테이블은 1개만 지정할 수 있습니다



























































