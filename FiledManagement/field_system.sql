--������ռ�field_data
drop tablespace field_data including contents and datafiles;
create tablespace field_data datafile 
'D:field_data01.dbf' size 1024M;
--������ʱ��ռ�field_temp
drop tablespace field_temp including contents and datafiles;
create temporary tablespace field_temp tempfile 
'D:\field_temp01.dbf' size 512M;
--�����û�
drop user fielduser01 cascade;
create user fielduser01 identified by adim123
default tablespace field_data
temporary tablespace field_temp;
drop user fielduser02 cascade;
create user fielduser02 identified by adim123
temporary tablespace field_temp;
--������ɫdeve_role
drop role deve_role;
create role deve_role not identified;
grant CREATE SESSION,
ALTER SESSION,
RESTRICTED SESSION,
CREATE TABLESPACE,
ALTER TABLESPACE,
MANAGE TABLESPACE,
DROP TABLESPACE,
CREATE USER,
BECOME USER,
ALTER USER,
DROP USER,
CREATE ROLLBACK SEGMENT,
ALTER ROLLBACK SEGMENT,
DROP ROLLBACK SEGMENT,
CREATE TABLE,
CREATE CLUSTER,
CREATE VIEW,
CREATE TRIGGER,
CREATE PROFILE,
ALTER PROFILE,
DROP PROFILE,
ALTER RESOURCE COST,
CREATE MATERIALIZED VIEW,
CREATE ANY LIBRARY,
CREATE INDEXTYPE,
QUERY REWRITE,
GLOBAL QUERY REWRITE,
CREATE DIMENSION,
CREATE RULE,
CREATE SEQUENCE,
create procedure,
ALTER DATABASE,
CREATE JOB,
unlimited tablespace,
CREATE ANY DIRECTORY
to deve_role
with admin option;
--����ɫ����fielduser01
grant deve_role to fielduser01;
grant unlimited tablespace to fielduser01;
create or replace directory data_dir as 'D:\data\emp\data';
create or replace directory log_dir as 'D:\data\emp\log';
create or replace directory bad_dir as 'D:\data\emp\bad';
grant read on directory data_dir to fielduser01;
grant write on directory log_dir to fielduser01;
grant write on directory bad_dir to fielduser01;
/
--����fielduser01�û�
conn fielduser01/adim123@orcl
--����������academy
drop table academy;
create  table academy(
a_number number(20) primary key,
a_name varchar2(40) not null
)
tablespace field_data;
--����������teachers
drop table teachers;
create  table teachers(
t_number number(12) ,
t_name varchar2(20) not null,
a_number number(20) not null  references academy(a_number),
t_rank varchar2(40),
constraint pk_teachers primary key(t_number,t_name)
)
tablespace field_data;
--����������major
drop table major;
create  table major(
m_number number(20) primary key,
m_name varchar2(40) not null,
a_nuber number(20)  references academy(a_number)
)
tablespace field_data;
--����������stutdents
drop table students;
create  table students(
s_number number(12),
s_name varchar2(20) not null,
s_grade varchar2(10),
a_number number(20)  references academy(a_number),
m_number number(20) ,
constraint pk_students primary key(s_number,s_name)
)
tablespace field_data;
--����������department
drop table department;
create  table department(
d_number number primary key,
d_name varchar2(40) not null,
l_name number(20),
d_phone varchar2(40)
)
tablespace field_data;
--����������leader
drop table leader;
create  table leader(
l_number number(20) primary key,
l_name varchar2(20) not null,
d_number number(20)  references department(d_number)
)
tablespace field_data;
--����������field
drop table field;
create  table field(
f_number number(20) primary key,
f_name varchar2(40) not null,
f_use varchar2(100),
f_starttime varchar2(40) not null,
f_endtime varchar2(40) not null,
l_number number(20) references leader(l_number),
f_location varchar2(40) not null
)
tablespace field_data;
--�����ⲿ��exter_workers
drop table worker;
create  table worker(
w_number number(20) primary key,
w_name varchar2(20) not null,
d_number number(20)  references department(d_number),
f_number number(20)  references field(f_number),
l_number number(20)  references leader(l_number),
w_money number(6) check(w_money>0)
)
tablespace field_data;
--����������pass
drop table pass;
create  table pass(
p_number number(11) not null,
p_password varchar2(20) not null,
constraint PK_pass primary key(p_number,p_password)
)
tablespace field_data;
--����������auto_info��������Ϣ
drop table audit_info;
create table audit_info
(
  infomation varchar2(200)
);
--�����ⲿ��exter_students
drop table exter_students;
create  table exter_students
(
s_number number(12),
s_name varchar2(20),
s_grade varchar2(10),
a_number number(20) ,
m_number number(20)
)
organization external
(
type oracle_loader
default directory data_dir
access parameters
(
records delimited by newline
badfile bad_dir:'students.bad'
logfile log_dir:'students.log'
fields terminated by ','
)
location ('studentsData.txt')
)
parallel
reject limit unlimited;
--�����ⲿ��exter_leaders
drop table exter_leaders;
create  table exter_leaders
(
l_number number(20),
l_name varchar2(20),
d_number number(20)
)
organization external
(
type oracle_loader
default directory data_dir
access parameters
(
records delimited by newline
badfile bad_dir:'leader.bad'
logfile log_dir:'leader.log'
fields terminated by ','
)
location ('leadersData.txt')
)
parallel
reject limit unlimited;
--�����ⲿ��exter_teachers
drop table exter_teachers;
create  table exter_teachers
(
t_number number(12) ,
t_name varchar2(20) ,
a_number number(20) ,
t_rank varchar2(40)
)
organization external
(
type oracle_loader
default directory data_dir
access parameters
(
records delimited by newline
badfile bad_dir:'teachers.bad'
logfile log_dir:'teachers.log'
fields terminated by ','
)
location ('teachersData.txt')
)
parallel
reject limit unlimited;
--�����ⲿ��exter_workers
drop table exter_workers;
create  table exter_workers
(
w_number number(20),
w_name varchar2(20),
d_number number(20) ,
f_number number(20),
l_number number(20),
w_money number(6) 
)
organization external
(
type oracle_loader
default directory data_dir
access parameters
(
records delimited by newline
badfile bad_dir:'workers.bad'
logfile log_dir:'workers.log'
fields terminated by ','
)
location ('workersData.txt')
)
parallel
reject limit unlimited;
--�ڱ�students�ϴ�������stu_name_idx
drop index stu_name_idx;
create index stu_name_idx
on students (s_name);
--��������department_seq
drop sequence department_seq;
create sequence department_seq
increment by 1
start with 1
maxvalue 60
nocycle
nocache;
--��������field_seq
drop sequence field_seq;
create  sequence field_seq
increment by 1
start with 1
maxvalue 50
nocycle
nocache;
--����teacher_view��ͼ
create or replace view teachers_view
("��ʦ���","��ʦ����","����ѧԺ","ְ��")
as
select t.t_number,t.t_name,a.a_name,t.t_rank
from teachers t
join academy a
on t.a_number=a.a_number;
--����field_view��ͼ
create or replace view field_view
("���ر��","��������","������;","����λ��","����ʱ��","�ر�ʱ��")
as
select f_number,f_name,f_use,f_location,f_starttime,f_endtime
from field;
--����Ա����ͼ����Ա��ƽ�����ʡ���߹��ʵ���Ϣ
create or replace view workers_view
("Ա������","��߹���","��͹���","ƽ������")
as
select
count(w_number),max(w_money),min(w_money),avg(w_money)
from worker;
--��academy���������
delete academy;
insert into academy values(01,'���ش�ѧ���ù���ѧԺ');
insert into academy values(02,'���ش�ѧ��ѧԺ');
insert into academy values(03,'���ش�ѧ��Ϣ����ѧԺ');
insert into academy values(04,'���ش�ѧ�����ѧԺ');
insert into academy values(05,'���ش�ѧ��ѧ������ѧѧԺ');
insert into academy values(06,'���ش�ѧӦ�����������ѧԺ');
insert into academy values(07,'���ش�ѧ��Ϣ����ѧԺ');
insert into academy values(08,'���ش�ѧ�����ѧԺ');
insert into academy values(09,'���ش�ѧ���繤��ѧԺ');
insert into academy values(10,'���ش�ѧ��ľ����ѧԺ');
insert into academy values(11,'���ش�ѧ��ѧ�뻷��ѧԺ');
insert into academy values(12,'���ش�ѧ��֯��װѧԺ');
insert into academy values(13,'���ش�ѧ�������ѧԺ');
insert into academy values(14,'���ش�ѧ˼���������۽�ѧ��');
insert into academy values(15,'���ش�ѧ������');
insert into academy values(16,'���ش�ѧ�����ͨѧԺ');

alter table department drop (l_name);
alter table worker drop (l_number);
alter table exter_workers drop (l_number);
--��department��������
delete department;
insert into department values(department_seq.nextval,'�����칫��','5236458');
insert into department values(department_seq.nextval,'��ί�칫��','75238');
insert into department values(department_seq.nextval,'������','7656236416');
insert into department values(department_seq.nextval,'ѧ��������','8656921');
insert into department values(department_seq.nextval,'��װ��','525121');
insert into department values(department_seq.nextval,'�����ϸɴ�','76239');
insert into department values(department_seq.nextval,'����','8273639');
insert into department values(department_seq.nextval,'��ί','6291877');
insert into department values(department_seq.nextval,'����','2153846');
insert into department values(department_seq.nextval,'�Ƽ���','521386');
insert into department values(department_seq.nextval,'�о�����','217394421');
insert into department values(department_seq.nextval,'���ڴ�','213642132');
insert into department values(department_seq.nextval,'����','2136492121');
insert into department values(department_seq.nextval,'���´�','2136499');
insert into department values(department_seq.nextval,'ʵ�������豸����','26134123');
insert into department values(department_seq.nextval,'���´�','721368482');
insert into department values(department_seq.nextval,'�����칫��','281639412');
insert into department values(department_seq.nextval,'������������','213948213');
insert into department values(department_seq.nextval,'ѧҵָ�����������','2716394');
insert into department values(department_seq.nextval,'���������������','2173649');
insert into department values(department_seq.nextval,'��ҵָ�����������','721358');
insert into department values(department_seq.nextval,'У�ѷ�������','76239222');
insert into department values(department_seq.nextval,'��ʦ��ѧ��չ����','7263723222');
insert into department values(department_seq.nextval,'������ѧ��������','62376411234');
insert into department values(department_seq.nextval,'��ҵ���������������','82876364');
insert into department values(department_seq.nextval,'�������̹�������','762873723');
insert into department values(department_seq.nextval,'�ۺ���Ϣ��������','128731122');
insert into department values(department_seq.nextval,'��Ͷ���������','23837877123');
insert into department values(department_seq.nextval,'ͼ���','18723812');
insert into department values(department_seq.nextval,'�����������','1727638912');
insert into department values(department_seq.nextval,'�߽��о���','12683');
insert into department values(department_seq.nextval,'�㶫�����Ļ��о�����','8123721');
insert into department values(department_seq.nextval,'LED�о�Ժ','12382344');
insert into department values(department_seq.nextval,'�����ش��Ļ���������','237823479');
insert into leader select * from exter_leaders;
--��field���������
delete field;
insert into field values(field_seq.nextval,'����Ȩ�����˶�����','��Ӿ','16:00','18:00',199342378,'�����ٳ���');
insert into field values(field_seq.nextval,'̷��������','��ë��ƹ����','19:00','22:00',197067793,'�����ٳ�����');
insert into field values(field_seq.nextval,'�ﾶ��','�ܲ�������','08:00','22:00',356106749,'��Ӿ����');
insert into field values(field_seq.nextval,'ɳ������','����','08:00','18:00',250229644,'�����ٳ���');
insert into field values(field_seq.nextval,'���Խ�������','����','08:00','21:30',397719208,'����¥ǰ');
insert into field values(field_seq.nextval,'��������','��Ӿ','08:00','22:00',247696212,'��������ѧ¥��');
insert into field values(field_seq.nextval,'������˶���','����ƹ�����赸','16:00','18:00',518642049,'���ķ�����');
insert into field values(field_seq.nextval,'��������','��������','08:00','21:00',555512015,'������˶��ݶ���');
--ʹ���ⲿ����students���в�������
insert into  students select * from exter_students;
--ʹ���ⲿ����teachers���в�������
insert into  teachers select * from exter_teachers;
--ʹ���ⲿ����woker���������
delete worker;
insert into  worker select * from exter_workers;
--����ѧ����ͼ
create or replace view students_view
("ѧ��ѧ��","ѧ������","ѧ���꼶","ѧԺ����")
as
select s.s_number,s.s_name,s.s_grade,a.a_name
from students s, academy a
where s.a_number=a.a_number;
drop table emp_back_worker;
create table emp_back_worker as select * from worker;
--����������ʵ�ֲ���ɹ���Ϣ����
create or replace trigger sayMessage_trigger
after insert
on students
declare
begin
dbms_output.put_line('���ѳɹ�����ѧ����Ϣ');
end;
/
--����������ʵ�ַǹ����ν�ֹ��ѧ������в������
create or replace trigger securitystudents_trigger
before insert
on students
declare
begin
if to_char(sysdate,'day') in ('������','������') or
   to_number(to_char(sysdate,'hh24')) not between 9 and 17 then
   raise_application_error(-20001,'��ֹ�ڷǹ���ʱ�����');
end if;
end;
/
--������䴥������ʹԱ����н���ܵ�����нǰ
create or replace trigger checkmoney_trigger
before update
on worker
for each row
declare
begin
if :new.w_money<:old.w_money then
raise_application_error(-20002,'�Ǻ�нˮ���ܵ�����ǰнˮ,
  �Ǻ�нˮ��'||:new.w_money||' ��ǰнˮ:'||:old.w_money);
end if;
end;
/
--�����м���������Ա�����ʴ���5000���Զ�����auto_info
create or replace trigger audit_money_trigger
after update
on worker
for each row
declare
begin
	if :new.w_money>5000 then
		insert into audit_info values(:new.w_number||'  '||:new.w_name||'  '||:new.w_money);
	end if;
end;
/
--�����м����������Զ����ݲ����Ա����Ϣ
create or replace trigger sync_money_trigger
after update
on worker
for each row
declare
begin
update emp_back_worker set w_money=:new.w_money where w_number=:new.w_number;
end;
/
--�����洢���̣�ͳ��������
create or replace procedure count_number_pro
as
	count_stu_number number(10);
	count_tea_number number(10);
	count_wor_number number(10);
	count_lead_number number(10);
begin
	select count(*) into count_stu_number from students;
	select count(*) into count_tea_number from teachers;
	select count(*) into count_lead_number from leader;
	select count(*) into count_wor_number from worker;
	dbms_output.put_line('ѧ����������'||count_stu_number);
	dbms_output.put_line('��ʦ��������'||count_tea_number);
	dbms_output.put_line('�쵼��������'||count_lead_number);
	dbms_output.put_line('Ա����������'||count_wor_number);
end;
/
--�����洢���̸�ָ��Ա���ǹ���
create or replace procedure raise_money_pro(p_number in number,p_raisemoney in number)
as
	p_money worker.w_money%type;
begin
	select w_money into p_money from worker where w_number=p_number;
	update worker set w_money=w_money+p_raisemoney;
	dbms_output.put_line('��н�ɹ�');
	dbms_output.put_line('��Ա��нˮΪ:'||(p_money+p_raisemoney));
exception
	when no_data_found then
	dbms_output.put_line('û�д�Ա��');
end;
/
--��Ȩ���û�fileduser02
grant select on students to fielduser02 with grant option;
grant select on teachers to fielduser02 with grant option;
grant select on academy to fielduser02 with grant option;
grant select on major to fielduser02 with grant option;
grant select on worker to fielduser02 with grant option;
grant select on leader to fielduser02 with grant option;
grant select on department to fielduser02 with grant option;
grant select on field to fielduser02 with grant option;
grant select on pass to fielduser02 with grant option;
grant select on students_view to fielduser02 with grant option;
grant select on teachers_view to fielduser02 with grant option;
grant select on field_view to fielduser02 with grant option;
/