asdf;a;
--常用 dml dcl ddl sql语句
sqlplus / as sysdba;

---
---oracle管理 
---

--查看字符编码
select userenv('language') from dual;
select * from V$NLS_PARAMETERS;
SELECT VALUE FROM nls_database_parameters WHERE parameter='NLS_CHARACTERSET'


--会话 进程 连接数 监控
select count(*) from v$process; --查看进程数量
SELECT * FROM v$process;
select count(*) from v$session; --查看会话
SELECT * FROM v$session;
SELECT * FROM v$session 
where status='ACTIVE'; --并发连接数
--concat join with ','
select vm_concat(name) from test;


--查看会话连接 锁 关闭会话 sysdba
select session_id from v$locked_object;
select sid, serial#, username, osuser from v$session;-- where sid=783;
alter system kill session '783,18455'; --关闭会话

select b.owner, b.object_name, a.session_id, a.locked_mode 
from v$locked_object a, dba_objects b
where b.object_id = a.object_id;

select value from v$parameter where name = 'processes'; --数据库允许的最大连接数
show parameter processes; --最大连接
alter system set processes=500 scope=spfile; --设置进程数量
alter system set sessions=500 scope=spfile;--设置会话数量
shutdown immediate;           --关闭  
startup;     --启动 

---
---用户管理
---角色管理
---权限管理
---

--1、给用户解锁 
alter user scott account unlock; 
--2、注销、断开、切换当前用户连接 
quit
conn scott/tiger
--3、用户权限查询
select * from dba_users; --查看数据库里面所有用户，前提是你是有dba权限的帐号，如sys,system
select * from all_users; --查看你能管理的所有用户！
select * from user_users; --查看当前用户信息 ！
--B.查看用户或角色系统权限(直接赋值给用户或角色的系统权限)：
select * from dba_sys_privs;
select * from user_sys_privs;
--C.查看角色(只能查看登陆用户拥有的角色)所包含的权限
select * from role_sys_privs;
--D.查看用户对象权限：
select * from dba_tab_privs;
select * from all_tab_privs;
select * from user_tab_privs;
--E.查看所有角色：
select * from dba_roles;
--F.查看用户或角色所拥有的角色：
select * from dba_role_privs; s
elect * from user_role_privs;
--G.查看哪些用户有sysdba或sysoper系统权限(查询时需要相应权限)
select * from V$PWFILE_USERS
--4、用户管理
--A、创建用户
create user username identified by password;
create user username identified by password default tablespace users quota 10M on users;
--B、修改密码
alter user username identified by pass;--密码就从password改成pass了；同样登陆后输入password也可以修改密码
--C、删除用户
drop user username;
drop user username cascade; --级联





---
--oracle sql 操作模板
---


--表集合
SELECT count(*) from user_tables;
---查看表列名
SELECT COLUMN_NAME FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = upper('student') ORDER BY COLUMN_ID

--建表
create table test(id varchar(20), time date);
create table test ( id varchar(20) primary key, time date, num number(3, 1), test varchar(20) not null, value varchar(20) default 'about' );
--1. 复制表结构及其数据： 
create table table_name_new as select * from table_name_old 
--2. 只复制表结构： 
create table table_name_new as select * from table_name_old where 1=2; 
create table table_name_new like table_name_old 

--删除表
drop  table test  ;

--修改表 外码 外键
alter table tb_a add  FOREIGN KEY(id ) REFERENCES tb_b(id);

--修改表添加列 默认值
alter table tb_group add( checked varchar(10) default 'true' );
alter table tb_group rename column checked to newName;

---
---表数据管理
---
--查询插入
insert into table_name_new select * from table_name_old 
--查询插入2 
insert into table_name_new(column1,column2...) select column1,column2... from table_name_old
--单条插入
insert into test(id, time, test, num) values ('1', sysdate, 'test', '12.1');
insert into test(id, time, test, num) values ('3', sysdate, 'test3', '12.2');
insert into test(id, time, test, num) 
values ('2', to_date('1000-12-12 22:22:22','yyyy-mm-dd hh24:mi:ss'), 'test', '12.1');
insert into test2 values('1212', '1', 'name1');
--update
update  test set pwd=MD5('cc'||id||MD5('cc'||id||'qwer')) where id='admin';
--查润update 单行操作
update test
SET(id,test,value)=(SELECT 'No.'||rownum newId,num,value FROM test WHERE 1=1 and id='1')
WHERE id='1';
SELECT * FROM test;

--删除数据
DELETE FROM test where 1=1 and id = 'aaa';
--删除所有表数据
truncate table test;
--查询表
SELECT t.*,to_char(t.time, 'yyyy-mm-dd hh24:mi:ss') tochar FROM test t;
--count group having 关联查询
SELECT tid, count(tid)  FROM 
(
SELECT t1.*,t2.id ttid,t2.tid,t2.name FROM test t1, test2 t2
where 1=1
and t1.id>0 
and t1.id=t2.tid(+)
) t 
where 1=1
group by tid
having count(tid) >= 0

--左连接
SELECT t1.*,count(t2.tid) FROM test t1 
left join test2 t2
on t1.id=t2.tid
where 1=1
and t1.id>0  
group by t2.tid


--分组查询 每组取第一条
select * from (
select 
row_number() over ( partition by t.test order by time desc) rn
,t.* 
from test t ) tt
where 1=1
and rn=1;



--临时表查询
with 
tempTable as (SELECT * FROM test),
tempTable2 as (SELECT * FROM test)
SELECT * FROM tempTable,tempTable2 whre a=1;

--exists 存在判断
select * from T1 where exists(select 1 from T2 where T1.a=T2.a) ;



---
--- 存储过程 触发器 任务 序列
---

--触发器
CREATE OR REPLACE TRIGGER tr_info 
   BEFORE insert --指定触发时机为删除操作前触发
   ON info 
   FOR EACH ROW   --说明创建的是行级触发器 
BEGIN
   --将修改前数据插入到日志记录表 del_emp ,以供监督使用。
   update  info set about='1' where id like '%'||to_number(to_char(sysdate,'ss'))||'%' ;  
   update  info set about='0' where id like '%'||to_number(to_char(sysdate,'mi'))||'%' ;  
END; 
--触发
insert into info(id,userid) values(seq_info.nextval, 'test1');
 

--循环存储过程
--详见plsql.sql
create or replace procedure p_createRoomTest(cc in integer) as
i integer;
begin
  i := cc;     
  WHILE i > 0 LOOP
  begin
    insert into   kfgl_fj(id,roomnum,roomtype,curpeople,roomstat,stationid) values(SEQ_test.Nextval, 'T-' || SEQ_test1.Nextval,'43eb189e-a2be-4538-8276-94bc27c2a2b1','0','0','5103211993' ) ;

    i:= i - 1;
  end;
  end LOOP;

end p_createRoomTest; 


--调用存储过程
begin
  p_createRoomTest(800);
  commit;
end;


--序列
create sequence SEQ_file_down_up
minvalue 1
maxvalue 99999999
start with 1
increment by 1
cache 20;

--job 任务
VAR job1 NUMBER; 
BEGIN 
  dbms_job.submit(:job1,'P_JOB1_TEST;',sysdate,'sysdate+1/1440'); 
  COMMIT; 
END; 

BEGIN 
  dbms_job.run(:job1); 
END; 





---
---常用函数 
---

--定长位数补齐 lpad
select 'SCJS' || lpad(SEQ_T_CONTRACT_THREE.nextval,3, '0') from dual 

--判断 nvl nvl2 case when
select 
 nvl(t.id,'id is null') idnull
,nvl2(t.id,'not null','id is null') idnull
,(case when t.id='1' then '省公司1' when t.id='2' then '省公司2' else '分公司' end) name
 from test t;

--自定义函数 文件大小计算文本
CREATE OR REPLACE FUNCTION FILE_SIZE(n IN VARCHAR2) RETURN VARCHAR2 IS retval varchar2(32);
BEGIN
 retval := '';
 select
(case
when n>1024*1024*1024*1024 then trunc(n*10/1024/1024/1024/1024)/10||'TB'
when n>1024*1024*1024 then trunc(n*10/1024/1024/1024)/10||'GB'
when n>1024*1024 then trunc(n*10/1024/1024)/10||'MB'
when n>1024 then trunc(n*10/1024)/10||'KB'
else n||'B' 
  end) res  into retval
from dual  ;
 RETURN retval;
END;

--md5加密函数 DBMS_OBFUSCATION_TOOLKIT.MD5
CREATE OR REPLACE FUNCTION MD5(passwd IN VARCHAR2) RETURN VARCHAR2 IS retval varchar2(32);
BEGIN
 retval := Lower(utl_raw.cast_to_raw( DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT_STRING => passwd)) );
 RETURN retval;
END;

select md5('123456') from  dual;


--计算百分比
SELECT * FROM round(100 / 200, 4) * 100 || '%' from dual;
--随机数
SELECT  DBMS_RANDOM.VALUE(1,100) from dual;



--时间格式转换
insert into test values('0002', to_date('1000-12-12','yyyy-mm-dd hh24:mi:ss') );
SELECT  to_char(time, 'yyyy-mm-dd hh24:mi:ss' ), id  FROM test;
SELECT substr(to_char(systimestamp, 'yyyy-mm-dd hh24:mi:ss:ff'), 0, 23 ) FROM dual; --毫秒 截取
SELECT  to_char(  to_date('1000-12-12','yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss') FROM dual
--时间差值
select to_char(add_months(trunc(sysdate),1),'yyyy-mm') from dual;
--当前时间减去7分钟的时间
select  sysdate,sysdate - interval '7' MINUTE  from dual
--当前时间减去7小时的时间
select  sysdate - interval '7' hour  from dual
--当前时间减去7天的时间
select  sysdate - interval '7' day  from dual
--当前时间减去7月的时间
select  sysdate,sysdate - interval '7' month from dual
--当前时间减去7年的时间
select  sysdate,sysdate - interval '7' year   from dual
--时间间隔乘以一个数字
select  sysdate,sysdate - 8 *interval '2' hour   from dual



