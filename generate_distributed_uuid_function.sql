-- CREATE SCHEMA test AUTHORIZATION postgres;

create or replace function test.gen_uuid(prefix text, table_name text) returns uuid -- prefix
as $$
<<uuid_function>>
declare
	id text;
	chr1 text;
	chr2 text;
	already_exists boolean;
begin
	loop
		id := uuid_generate_v4();
		-- raise notice '%', id::text;
		chr1 := substring(id::text from 1 for 1);
		chr2 := substring(id::text from 2 for 1);
		id := overlay(id placing (chr1) from 15 for 1); -- version byte replacement
		id := overlay(id placing (chr2) from 20 for 1);	-- variant byte replacement
		-- id := overlay(id placing prefix from 1 for 30); -- prefix replacement                   -- for increase duplication id probability
		id := overlay(id placing prefix from 1 for 5); -- prefix replacement
		-- raise notice '%', id::text;
		-- raise notice ' ';
		
		execute 'select exists(select 1 from ' || table_name || ' t1 where t1.id = ''' || uuid_function.id::uuid || ''');' into already_exists;
		-- raise notice 'exists id: %', already_exists;
		if already_exists is false then
			exit;
		end if;
		
		-- raise notice 'duplicate';
	end loop;
		
	return id;
end;
$$ language plpgsql;


drop table if exists test.main;
create table test.main (
	id uuid default uuid_generate_v4(),
	
	constraint test_main_pk primary key (id)
);

-- 2 ** (8 * 5) = 1,099,511,627,776 -- 40 bits various sections
-- 2 ** (8 * 11) = 309,485,009,821,345,068,724,781,056 -- 88 bits various values

DO $$
declare
	built_in timestamp;
	custom timestamp;
	int_built_in interval;
	int_custom interval;
	iterations int;
begin
	iterations = 100000;

	alter table test.main alter column id set default uuid_generate_v4();
	truncate test.main;
  	
	built_in := clock_timestamp();
	FOR counter IN 1..iterations loop
   		insert into test.main default values;
  	END LOOP;
  	int_built_in := clock_timestamp() - built_in;
  
  	-- alter table test.main alter column id set default test.gen_uuid('00000000-0000-0000-0000-000000', 'test.main'); -- for increase duplication id probability
  	alter table test.main alter column id set default test.gen_uuid('00000', 'test.main');
  	truncate test.main;
  
  	custom := clock_timestamp();
  	FOR counter IN 1..iterations loop
   		insert into test.main default values;
  	END LOOP;
  	int_custom := clock_timestamp() - custom;
  
  	raise notice 'uuid_generate_v4() - %', int_built_in;	
  	raise notice 'test.gen_uuid() - %', int_custom;
  	raise notice 'performance - %', (EXTRACT(second FROM int_custom) + EXTRACT(minute FROM int_custom) * 60) / (EXTRACT(second FROM int_built_in) + EXTRACT(minute FROM int_built_in) * 60) ;
  	raise notice ' ';
END; $$

-- select * from test.main order by 1;
