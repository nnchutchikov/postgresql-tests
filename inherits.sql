drop table if exists test_sub;
drop table if exists test_main;
drop function if exists update_date();
drop trigger if exists update_date on test_main;


create or replace function update_date() returns trigger as $BODY$
begin
	NEW.date := now();
	return new;
end;
$BODY$ language plpgsql volatile cost 100;


create table test_main ( 
	id uuid default uuid_generate_v4() not null,
	name text,
	date timestamp with time zone default now() not null,
	
	constraint test_main_pk primary key (id),
	constraint test_main_unique_name unique (name) 
);


create trigger update_date 
	before update on test_main 
	    for each row execute procedure update_date();


create table test_sub (
	sub_name text 
)
inherits (test_main);



insert into	test_sub(name) values ('1');
insert into	test_sub(name) values ('2');
insert into	test_sub(name) values ('3');
insert into	test_sub(name) values ('3'); -- NO ERROR no constraint on test_sub table
 
update test_sub set name = '33' where name = '3'; -- date not updated

insert into	test_main(name) values ('3'); -- NO ERROR
insert into test_main(name) values ('4');

-- insert into test_main(name) values ('3'); -- ERROR already exists on test_main


-- update test_sub set name = '333' where name = '3'; -- date not modify
-- update test_main set name = '333' where name = '3'; -- date modify

select * from test_main;

drop table if exists test_sub;
drop table if exists test_main;
drop function if exists update_date;
drop trigger if exists update_date on test_main;
