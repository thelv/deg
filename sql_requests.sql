drop table if exists voters;
create table 
	voters
as
(
	select
		(v.voter_id)::text,
		(t."order")::int as transaction_order
	from
	(
		select 
			hash,
			voter_id
		from 
			transactions, 
			json_array_elements(transactions.payload->'voters') voter_id
		where
			method_id=1
	) 
	as v join 
	(
		select 
			hash,
			row_number() over() as "order"
		from 
			transactions
		where 
			method_id=1
		order by
			block_height, position_in_block		
	)
	as t using
	(
		hash
	)
);
create index on voters (voter_id);

drop table if exists ballots;
create table 
	ballots
as select 
	(payload->'voter_id')::text voter_id, 
	(payload->>'district_id')::int district_id, 
	datetime
from 
	transactions 
where 
	method_id=4 
order by 
	datetime
	
	
	
	
--select count(*) from decrypted_ballots
--select count(*) from transactions where method_id=6
create table 
	votes 
as select 
	d.decrypted_choice[1] as choise_id,
	(t.payload->>'district_id')::int as district_id,
	t.datetime
from 
	decrypted_ballots as d 
join 
	transactions as t 
on 
	d.store_tx_hash=t.hash;
create index on votes (district_id, datetime);
	
drop table if exists votes_by_mins;
create table 
	votes_by_mins
as select 	
	choise_id, 
	district_id, 
	((extract(epoch from datetime))/60)::int mins,
	count(*) count
from
	votes
group by 
	district_id,
	choise_id, 
	((extract(epoch from datetime))/60)::int
	
	
drop table if exists votes_by_mins6;
create table 
	votes_by_mins6
as select 	
	choise_id, 
	district_id, 
	((extract(epoch from datetime))/360)::int mins6,
	count(*) count
from
	votes
group by 
	district_id,
	choise_id, 
	((extract(epoch from datetime))/360)::int
	
drop table if exists votes_by_mins30;
create table 
	votes_by_mins30
as select 	
	choise_id, 
	district_id, 
	((extract(epoch from datetime))/1800)::int mins30,
	count(*) count
from
	votes
group by 
	district_id,
	choise_id, 
	((extract(epoch from datetime))/1800)::int
	
	
	
--------------

select 
	count(*), (transaction_order/10)::int
from 
	ballots b		 
join 
	voters v
using
(
	voter_id
)
where 
	b.datetime>'2021-09-17 4:00:33.02+03'::timestamptz and
	b.datetime<'2021-09-17 22:00:33.02+03'::timestamptz
group by 
	(v.transaction_order/10)::int
order by 
	(v.transaction_order/10)::int

	