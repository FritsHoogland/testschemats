create bigfile tablespace ts datafile size 100m autoextend on next 10m maxsize unlimited;
create user ts identified by ts default tablespace ts temporary tablespace temp quota unlimited on ts;
grant create session, create table to ts;
grant select on v_$mystat to ts;
grant alter session to ts;

--dbms_stats.display_cursor
grant select on v_$session to ts;
grant select on v_$sql_plan to ts;
grant select on v_$sql to ts;

conn ts/ts
exec dbms_random.seed('abracadabra');
create table t1
as
with generator as (
    select      rownum      id
    from        dual
    connect by
                rownum <= 1000
)
select
    rownum                                                id,
    trunc((rownum-1)/50)                            clustered,
    mod(rownum,20000)                               scattered,
    trunc(dbms_random.value(0,20000))               randomized,
    trunc(sysdate) + dbms_random.value(-180, 180)   random_date,
    dbms_random.string('l',6)                       random_string,
    lpad(rownum,10,0)                               vc_small,
    rpad('x',100,'x')                               vc_padding
from
    generator   g1,
    generator   g2
where
    rownum <= 1000000
;
exec dbms_stats.gather_table_stats(null,'T1');
create unique index t1_pk_ix on t1 ( id );
alter table t1 add (constraint t1_pk primary key ( id ) using index t1_pk_ix);
exec dbms_stats.gather_table_stats(null,'T1');

create table t2 as select * from t1;
exec dbms_stats.gather_table_stats(null,'T2');

