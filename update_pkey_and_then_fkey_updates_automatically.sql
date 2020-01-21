drop table if exists test.t1;
drop table if exists test.t2;

create table test.t1 (
	id uuid default uuid_generate_v4(),
	name text,
	
	constraint t1_pk primary key (id)
);

create table test.t2 (
	id uuid default uuid_generate_v4(),
	name text,
	t1_id uuid,
	
	constraint t2_pk primary key (id),
	
	CONSTRAINT t2_fk_t1_id FOREIGN KEY (t1_id)
    REFERENCES
      test.t1(id)
        ON DELETE cascade on update cascade
);

insert into test.t1(id, name) values 
	('111111111111-1111-1111-1111-11111111', 't1'),
	('222222222222-2222-2222-2222-22222222', 't2'),
	('333333333333-3333-3333-3333-33333333', 't3');
	
insert into test.t2(id, name, t1_id) values 
	('111111111111-1111-1111-1111-11111111', 't1', '111111111111-1111-1111-1111-11111111'),
	('222222222222-2222-2222-2222-22222222', 't2', '111111111111-1111-1111-1111-11111111'),
	('333333333333-3333-3333-3333-33333333', 't3', '333333333333-3333-3333-3333-33333333');
	
select t1.id, t1.name, t2.id, t2.name, t2.t1_id from test.t1 t1 left join test.t2 t2 on t1.id = t2.t1_id;


update test.t1 set id = '444444444444-4444-4444-4444-44444444' where id = '111111111111-1111-1111-1111-11111111';

select t1.id, t1.name, t2.id, t2.name, t2.t1_id from test.t1 t1 left join test.t2 t2 on t1.id = t2.t1_id;
