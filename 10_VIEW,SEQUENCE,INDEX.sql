/* VIEW
 * 
 * 	- 논리적 가상 테이블
 * 	-> 테이블 모양을 하고는 있지만, 실제로 값을 저장하고 있진 않음.
 * 
 *  - SELECT문의 실행 결과(RESULT SET)를 저장하는 객체
 * 
 * 
 * ** VIEW 사용 목적 **
 *  1) 복잡한 SELECT문을 쉽게 재사용하기 위해.
 *  2) 테이블의 진짜 모습을 감출 수 있어 보안상 유리.
 * 
 * ** VIEW 사용 시 주의 사항 **
 * 	1) 가상의 테이블(실체 X)이기 때문에 ALTER 구문 사용 불가.
 * 	2) VIEW를 이용한 DML(INSERT,UPDATE,DELETE)이 가능한 경우도 있지만
 *     제약이 많이 따르기 때문에 조회(SELECT) 용도로 대부분 사용.
 * 
 * 
 *  ** VIEW 작성법 **
 *  CREATE [OR REPLACE] [FORCE | NOFORCE] VIEW 뷰이름 [컬럼 별칭]
 *  AS 서브쿼리(SELECT문)
 *  [WITH CHECK OPTION]
 *  [WITH READ OLNY];
 * 
 * 
 * 
 *  1) OR REPLACE 옵션 : 
 * 		기존에 동일한 이름의 VIEW가 존재하면 이를 변경
 * 		없으면 새로 생성
 * 
 *  2) FORCE | NOFORCE 옵션 : 
 *    FORCE : 서브쿼리에 사용된 테이블이 존재하지 않아도 뷰 생성
 *    NOFORCE(기본값): 서브쿼리에 사용된 테이블이 존재해야만 뷰 생성
 *    
 *  3) 컬럼 별칭 옵션 : 조회되는 VIEW의 컬럼명을 지정
 * 
 *  4) WITH CHECK OPTION 옵션 : 
 * 		옵션을 지정한 컬럼의 값을 수정 불가능하게 함.
 * 
 *  5) WITH READ OLNY 옵션 :
 * 		뷰에 대해 SELECT만 가능하도록 지정.
 * */

/* VIEW 를 생성하기 위해서는 권한이 필요하다 */

-- (SYS 관리자 계정 접속)
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
--> 계정명이 언급되는 상황에서는 이 구문 필수적으로 진행

-- VIEW 생성 권한 부여
GRANT CREATE VIEW TO kh;

-- ORA-01031: 권한이 불충분합니다


-- kh 계정으로 접속
-- VIEW 구문 실행
CREATE VIEW V_EMP
AS SELECT * FROM EMPLOYEE;
--> VIEW 생성 구문 기초 문법

SELECT * FROM V_EMP;

-- 사번, 이름, 부서명, 직급명 조회하기 위한 VIEW 셍성
--> OR REPLACE 옵션을 사용
CREATE OR REPLACE VIEW V_EMP
AS SELECT EMP_ID 사번, EMP_NAME 이름, NVL(DEPT_TITLE, '없음') 부서명,
JOB_NAME 직급명
FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON(DEPT_CODE = DEPT_ID)
ORDER BY 사번;
-- 기존의 객체가 이름을 사용하고 있습니다

SELECT * FROM V_EMP;

-- V_EMP에서 대리 직원들을 이름 오름차순으로 조회
-- VIEW 조회 결과로 보이는 컬럼명을 이용해야한다
SELECT * FROM V_EMP
WHERE 직급명 = '대리'
ORDER BY 이름;

----------------------------------------------------------------

/* VIEW를 이용해서 DML 사용하기 + 문제점 확인 */

-- DEPARTMENT 테이블을 복사한 DEPT_COPY2 생성(테이블)
CREATE TABLE DEPT_COPY2
AS SELECT * FROM DEPARTMENT;

-- DEPT_COPY2 테이블에서 DEPT_ID, LOCATION_ID 컬럼만 이용해서
-- V_DCOPY2 VIEW 생성
CREATE OR REPLACE VIEW V_DCOPY2
AS SELECT DEPT_ID, LOCATION_ID FROM DEPT_COPY2;


-- V_DCOPY2 VIEW 생성 확인하기
SELECT * FROM V_DCOPY2;

-- 원본테이블
SELECT * FROM DEPT_COPY2;

-- V_DCOPY2 VIEW를 이용해서 INSERT 수행
INSERT INTO V_DCOPY2
VALUES('D0', 'L2');
-- 가상 테이블인 VIEW 인데도 INSERT 가 성공함
SELECT * FROM V_DCOPY2;
-- D0 L2

SELECT * FROM DEPT_COPY2;
-- D0 NULL L2

-- VIEW에 INSERT를 수행했지만
-- VIEW 생성시 사용한 원본테이블에
-- 값이 함께 INSERT 됨 확인

--> 모든 컬럼값이 INSERT 된것이 아니라
-- VIEW 를 생성할 때 사용된 컬럼에만 데이터가 삽입되었고
-- 사용되지 않은 컬럼(DEPT_TITLE)에는 NULL 이 들어감
--> NULL은 DB에 무결성을 약하게 만드는 주요원인중 하나
-- 가능하면 의도되지 않은 NULL은 존재하지 않게 해야한다.

/* 무결성 : 데이터베이스에서 데이터를 정확하고 일관되게
 * 				유지하기 위한 중요한 개념
 * 
 * 데이터의 정확성, 일관성, 신뢰성을 보장함
 * */


/* WITH READ ONLY 옵션 사용하기 */

-- 왜 사용할까?
--> VIEW를 이용해서 DML(INSERT/UPDATE/DELETE) 하는것을 DML 막기 위해


CREATE OR REPLACE VIEW V_DCOPY2
AS SELECT DEPT_ID, LOCATION_ID
FROM DEPT_COPY2
WITH READ ONLY; -- 읽기전용


-- INSERT 수행
INSERT INTO V_DCOPY2
VALUES('D0', 'L2');
-- ORA-42399: 읽기 전용 뷰에서는 DML 작업을 수행할 수 없습니다.

--------------------------------------------------------------------

/* SEQUENCE(순서, 연속)
 * - 순차적으로 일정한 간격의 숫자(번호)를 발생시키는 객체
 *   (번호 생성기)
 * 
 * *** SEQUENCE 왜 사용할까?? ***
 * PRIMARY KEY(기본키) : 테이블 내 각 행을 구별하는 식별자 역할
 * 						 NOT NULL + UNIQUE의 의미를 가짐
 * 
 * PK가 지정된 컬럼에 삽입될 값을 생성할 때 SEQUENCE를 이용하면 좋다!
 * 
 *   [작성법]
  CREATE SEQUENCE 시퀀스이름
  [STRAT WITH 숫자] -- 처음 발생시킬 시작값 지정, 생략하면 1이 기본
  [INCREMENT BY 숫자] -- 다음 값에 대한 증가치, 생략하면 1이 기본
  [MAXVALUE 숫자 | NOMAXVALUE(기본값)] -- 발생시킬 최대값 지정, 생략하면 기본값은 10^27 - 1 (즉, 매우 큰 값)입니다 / NOMAXVALUE를 사용하면 최대값 제한이 없음을 의미
  [MINVALUE 숫자 | NOMINVALUE(기본값)] -- 최소값 지정 , 기본값은 -10^26 /  NOMINVALUE를 사용하면 최소값 제한이 없음을 의미
  [CYCLE | NOCYCLE(기본값)] -- 값 순환 여부 지정 , 기본값은 NOCYCLE
		-- CYCLE: 값이 최대값에 도달하면 다시 최소값부터 순환
		-- NOCYCLE: 값을 순환하지 않고, 최대값에 도달하면 오류를 발생시킴
  
  [CACHE 시퀀스개수 | NOCACHE] -- 기본값은 20
	-- 시퀀스의 캐시 메모리는 할당된 크기만큼 미리 다음 값들을 생성해 저장해둠
	--> 시퀀스 호출 시 미리 저장되어진 값들을 가져와 반환하므로 
	--  매번 시퀀스를 생성해서 반환하는 것보다 DB속도가 향상됨.
 * 
 * 
 * ** 사용법 **
 * 
 * 1) 시퀀스명.NEXTVAL : 다음 시퀀스 번호를 얻어옴.
 * 						 (INCREMENT BY 만큼 증가된 수)
 * 						 단, 생성 후 처음 호출된 시퀀스인 경우
 * 						 START WITH에 작성된 값이 반환됨.
 * 
 * 2) 시퀀스명.CURRVAL : 현재 시퀀스 번호를 얻어옴.
 * 						 단, 시퀀스가 생성 되자마자 호출할 경우 오류 발생.
 * 						== 마지막으로 호출한 NEXTVAL 값을 반환
 * */

/* 시퀀스 생성하기 (맨 처음 줬던 리소스에 시퀀스 만드는 권한도 있어서 따로 권한 안줘도됨) */
CREATE SEQUENCE SEQ_TEST_NO
START WITH 100 -- 시작번호 100
INCREMENT BY 5 -- NEXTVAL 5씩 증가
MAXVALUE 150	 -- 증가 가능한 최대값
NOMINVALUE 		 -- 최소값 없음
NOCYCLE				 -- 반복 안함
NOCACHE;			 -- 미리 만들어둘 시퀀스 번호 없음


/* 시퀀스 삭제하기 */
DROP SEQUENCE SEQ_TEST_NO;


-- 시퀀스 테스트 할 테이블 생성
CREATE TABLE TB_TEST(
	TEST_NO NUMBER PRIMARY KEY,
	TEST_NAME VARCHAR2(30) NOT NULL
);

-- 현재 시퀀스 번호 확인
SELECT SEQ_TEST_NO.CURRVAL FROM DUAL;
-- ORA-08002: 시퀀스 SEQ_TEST_NO.CURRVAL은 이 세션에서는 정의 되어 있지 않습니다
-- 아직 가장 최근에 호출된 NEXTVAL 이 없어서 반환할 값이 없음.
--> CURRVAL의 정확한 의미는
-- 가장 최근 호출된 NEXTVAL의 값을 반환함을 뜻함
-- NEXTVAL을 호출한 적이 없어서 오류 발생

--> 해결방법 : NEXTVAL 호출하기
SELECT SEQ_TEST_NO.NEXTVAL FROM DUAL;
-- 시퀀스 생성 후 첫 NEXTVAL은 START WITH 값인 100

SELECT SEQ_TEST_NO.CURRVAL FROM DUAL; --100

-- NEXTVAL 를 호출할때마다
-- INCREMENT BY 에 작성된 수 만큼 증가하는지 확인
SELECT SEQ_TEST_NO.NEXTVAL FROM DUAL;
-- 처음 : 100
-- 1회 : 105
-- 2회 : 110
-- 3회 : 115
-- 4회 : 120

-- TB_TEST 테이블에 PK값을 SEQ_TEST_NO 시퀀스로 생성하기
INSERT INTO TB_TEST
VALUES (SEQ_TEST_NO.NEXTVAL, '짱구'); -- 125

INSERT INTO TB_TEST
VALUES (SEQ_TEST_NO.NEXTVAL, '철수'); -- 130


INSERT INTO TB_TEST
VALUES (SEQ_TEST_NO.NEXTVAL, '유리'); -- 135

SELECT * FROM TB_TEST;

------------------------------------------------------------------

-- UPDATE 에서 시퀀스 사용하기
-- '짱구'의 PK 컬럼값을
-- SEQ_TEST_NO 시퀀스의 다음 생성값으로 변경하기

UPDATE TB_TEST
SET TEST_NO = SEQ_TEST_NO.NEXTVAL
WHERE TEST_NAME = '짱구';
-- ORA-08004: 시퀀스 SEQ_TEST_NO.NEXTVAL exceeds MAXVALUE은 사례로 될 수 없습니다
--> MAXVALUE 150 보다 더 증가할 수 없다


SELECT * FROM TB_TEST;

------------------------------------------------------------------

-- SEQUENCE 변경 (ALTER)
--> START WITH 빼고 모두 변경 가능!

/*
 * [작성법]
 * ALTER SEQUENCE 시퀀스 이흠
 * [INCREMENT BY 숫자]
 * [MAXVALUE 숫자 | NOMAXVALUE]
 * [MINVALUE 숫자 | NOMINVALUE]
 * [CYCLE | NOCYCLE\
 * [CACHE 숫자 | NOCACHE]
 * 
 * */


-- SEQ_TEST_NO 의 MAXVALUE 값을 200으로 수정
ALTER SEQUENCE SEQ_TEST_NO
MAXVALUE 200;

-- 200까지 증가 시켜서 변경확인
SELECT SEQ_TEST_NO.NEXTVAL FROM DUAL;


---------------------------------------------------------------------

-- VIEW, SEQUENCE 삭제

-- V_DCOPY2 VIEW 삭제
DROP VIEW V_DCOPY2;


-- SEQ_TEST_NO SEQUENCE 삭제
DROP SEQUENCE SEQ_TEST_NO;



















