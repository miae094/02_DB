-- 한 줄 주석
/*
 * 
 * 범위주석
 * 
 * */


-- 선택한 SQL 수행 : 구문에 커서 두고 ctrl+enter 
-- 전체 SQL 수행 : 전체 구문 활성화 시킨 채로(==전체선택(ctrl + a)) alt + x

-- 12c 버전 이전 문법 허용구문
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

-- 계정 생성 구문(username : kh / password : kh1234)
CREATE USER kh IDENTIFIED BY kh1234;


-- 사용자 계정 권한 부여 설정
-- RESOURCE : 테이블이나 인덱스 같은 DB객체를 생성할 권한
-- COnnect : DB에 연결하고 로그인 할 수 있는 권한
GRANT RESOURCE, CONNECT TO kh;


ALTER USER kh DEFAULT TABLESPACE SYSTEM QUOTA UNLIMITED ON SYSTEM ;
-- 객체가 생성될 수 있는 공간 할당량 무제한 지정


