


/*In this part I had to give values for the tables*/

UPDATE orders SET amount_inc_tax= 1638.34 from accounts a where orders.account_id='1' or orders.account_id='2';
UPDATE orders SET amount_inc_tax= 1172.49 from accounts a where orders.account_id='3' or orders.account_id='4';

UPDATE orders SET amount_exc_tax= amount_inc_tax/1.21 ;
UPDATE public.orders SET payment_status= 'success' from accounts a where status='APROVED';
UPDATE public.orders SET payment_status= 'not success' from accounts a where status!='APROVED';
UPDATE orders SET issued_at=  created_at + interval '30 days';
UPDATE orders SET paid_at=created_at + interval '30 days' from accounts a where status='APROVED';

update revenue_mrr set created_at=o.created_at from orders o, revenue_mrr m where m.id=o.id ; 
update revenue_usage set ammount_exc_tax=o.amount_exc_tax*0.88 , created_at=o.created_at, ammount_inc_tax= o.amount_exc_tax*0.88 from orders o, revenue_mrr m where m.account_id=o.account_id;
select * from orders order by id;
SELECT o.id, m.id, m.account_id, o.account_id FROM orders o INNER JOIN revenue_mrr m ON o.id = m.id order by o.id;
select * from revenue_mrr order by id;

UPDATE orders SET amount_inc_tax= 1638.34 from accounts a where orders.account_id='1' or orders.account_id='2';

truncate table revenue_mrr;
truncate table revenue_usage;
select * from revenue_mrr order by id;
select * from revenue_usage order by id;

INSERT INTO revenue_mrr (id,account_id,ammount_exc_tax,ammount_inc_tax,created_at) SELECT o.id,o.account_id,o.amount_exc_tax*0.88,o.amount_inc_tax*0.88 ,o.created_at  FROM orders o;
INSERT INTO revenue_usage (id,account_id,ammount_exc_tax,ammount_inc_tax,created_at) SELECT o.id,o.account_id,o.amount_exc_tax*0.12,o.amount_inc_tax*0.12 ,o.created_at  FROM orders o;



select * from revenue_mrr order by id;
UPDATE orders SET created_at=  issued_at + interval '-30 days';


update revenue_usage set ammount_inc_tax=ammount_exc_tax*1.21;
/*ejercise 1*/
select o.account_id as account ,round(sum(m.ammount_inc_tax)) as mrr , 
round(sum(u.ammount_inc_tax)) as usage,round(sum(o.amount_inc_tax)) as paid
from orders o
inner join revenue_mrr m on o.id=m.id
inner join revenue_usage u on o.id=u.id
where o.payment_status='success'
GROUP BY o.acco|unt_id;

/*ejercise 2*/
select*
FROM(
	
	select date(m.created_at) as month ,sum(m.ammount_inc_tax) as amount,  a.plan as plan, 'mrr' as revenue_type 
	from revenue_mrr m
	inner join accounts a on a.id=m.account_id
	where date_part('month',(m.created_at))=date_part('month',(m.created_at)) and date_part('year',(m.created_at))=date_part('year',(m.created_at))
	group by 	m.created_at, a.plan ,revenue_type

	union all

	select date(u.created_at) as month ,sum(u.ammount_inc_tax) as amount,  a.plan as plan , 'usage' as revenue_type 
	from revenue_usage u
	inner join accounts a on a.id=u.account_id
	where date_part('month',(u.created_at))=date_part('month',(u.created_at)) and date_part('year',(u.created_at))=date_part('year',(u.created_at))
	group by 	u.created_at, a.plan ,revenue_type	
	
) as pato
order by month;
/*ejercise 3*/
select p.month,p.account,p.amount
from(
SELECT 
   date(m.created_at) as month,
    m.account_id as account,
    m.ammount_inc_tax as amount,
	
    LAST_VALUE(date(created_at))
    OVER(
	PARTITION BY m.account_id
        ORDER BY m.created_at
        RANGE BETWEEN 
            UNBOUNDED PRECEDING AND 
            UNBOUNDED FOLLOWING
    ) lasts
FROM 
    revenue_mrr m) p
	where p.month=p.lasts


