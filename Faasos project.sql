create database Faasos;
use Faasos;

drop table if exists driver;
CREATE TABLE driver
(driver_id integer,
reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES 
 (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


drop table if exists ingredients;
CREATE TABLE ingredients
(ingredients_id integer,
ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES 
 (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls
(roll_id integer,
roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes
(roll_id integer,
ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order
(order_id integer,
driver_id integer,
pickup_time datetime,
distance VARCHAR(7),
duration VARCHAR(10),
cancellation VARCHAR(23));

INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2021 21:30:45','25km','25mins',null),
(8,2,'01-10-2021 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2021 18:50:20','10km','10minutes',null);


drop table if exists customer_orders;
CREATE TABLE customer_orders
(order_id integer,
customer_id integer,
roll_id integer,
not_include_items VARCHAR(4),
extra_items_included VARCHAR(4),
order_date datetime);

INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

/* Queries would be run on these parameters
A Roll Metrics
B Driver & Customer Experience
C Ingredient Optimization
D Pricing & Ratings
*/

--A Roll Metrics
--Q1 How many Rolls were ordered?
select count(order_id) as'no._of_orders'
from customer_orders

--A 
--Q2 How many unique customer orders were made?
select count(distinct customer_id) as'unique_no._of_orders'
from customer_orders;

/* Q3 How many successful orders were delivered by each driver?
*/

select driver_id,count(distinct order_id) from driver_order
where cancellation not in ('Cancellation','Customer Cancellation') 
group by driver_id;

/* Q4 How many of each type of roll were delivered?
*/
select * from customer_orders;
select * from driver_order; 

select roll_id,count(order_id) as 'no._of_rolls_ordered' from
(select t1.order_id,t1.roll_id,t2.driver_id
from customer_orders t1
inner join (select *,case when cancellation in ('Cancellation','Customer Cancellation') then 'c'
else 'nc' end as 'order_cancel_details'
from driver_order) t2
on t1.order_id=t2.order_id
where t2.order_cancel_details = 'nc')t3
group by roll_id;

/*Q5 How many Veg Rolls and Non Veg Rolls were ordered by
each customer
*/
select * from customer_orders;

select t1.customer_id,t1.roll_id,t2.roll_name,t1.count from
(select customer_id,roll_id,count(customer_id) as 'count'
from customer_orders
group by customer_id,roll_id)t1
inner join rolls t2
on t1.roll_id=t2.roll_id
order by t1.customer_id;

/*
Q6 What was the max. no. of rolls delivered in a single order?
*/
select * from customer_orders;
select * from driver_order; 

select top 1 order_id,count(roll_id) as 'count'
from
(select * from customer_orders where order_id in
(select order_id from 
(select *,case when cancellation in ('Cancellation','Customer Cancellation') then 'c'
else 'nc' end as 'order_cancel_details'
from driver_order)t1
where order_cancel_details='nc'))t2
group by order_id
order by count(roll_id) desc

--Q7 For each customer how many delivered rolls had atleast 1 change and how many and
--how many had no change?


with temp_customer_orders (order_id,customer_id,roll_id,new_not_include_items,new_extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items=' ' then '0' else not_include_items end as 'new_not_include_items',
case when extra_items_included is null or extra_items_included='NAN' or extra_items_included=' ' then '0' 
else extra_items_included end as 'new_extra_items_included',
order_date
from customer_orders
)
, temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,pickup_time,distance,duration,
case when cancellation in ('Cancellation','Customer Cancellation') then 0 else 1 end as 'new_cancellation'
from driver_order
)

select customer_id,change_no_change,count(order_id) as 'atleast_1_change'  
from 
(
select *,case when new_not_include_items='0' and new_extra_items_included='0' then 'no change' else 
'change' end as 'change_no_change'
from temp_customer_orders where order_id in 
(select order_id from temp_driver_order
where new_cancellation<>0)
)t1
group by customer_id,change_no_change
;
-----------------------------------------------
------------------------------------------------
--Same code Using over clause

with temp_customer_orders (order_id,customer_id,roll_id,new_not_include_items,new_extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items=' ' then '0' else not_include_items end as 'new_not_include_items',
case when extra_items_included is null or extra_items_included='NAN' or extra_items_included=' ' then '0' 
else extra_items_included end as 'new_extra_items_included',
order_date
from customer_orders
)
, temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,pickup_time,distance,duration,
case when cancellation in ('Cancellation','Customer Cancellation') then 0 else 1 end as 'new_cancellation'
from driver_order
)

select customer_id,change_no_change,count(customer_id) over(partition by customer_id,change_no_change) as 'atleast_1_change'  
from 
(
select *,case when new_not_include_items='0' and new_extra_items_included='0' then 'no change' else 
'change' end as 'change_no_change'
from temp_customer_orders where order_id in 
(select order_id from temp_driver_order
where new_cancellation<>0)
)t1;

/*Q8 How many Rolls were delivered that had both exclusions and extras?
*/

with temp_customer_orders (order_id,customer_id,roll_id,new_not_include_items,new_extra_items_included,order_date) as
(
select order_id,customer_id,roll_id,
case when not_include_items is null or not_include_items=' ' then '0' else not_include_items end as 'new_not_include_items',
case when extra_items_included is null or extra_items_included='NAN' or extra_items_included=' ' then '0' 
else extra_items_included end as 'new_extra_items_included',
order_date
from customer_orders
)
, temp_driver_order (order_id,driver_id,pickup_time,distance,duration,new_cancellation) as
(
select order_id,driver_id,pickup_time,distance,duration,
case when cancellation in ('Cancellation','Customer Cancellation') then 0 else 1 end as 'new_cancellation'
from driver_order
)

select change_no_change,count(change_no_change) as'count'
from
(
select *,case when new_not_include_items!='0' and new_extra_items_included!='0' then 'both inc exc' else 
'either 1 incl or excl' end as 'change_no_change'
from temp_customer_orders where order_id in 
(select order_id from temp_driver_order
where new_cancellation<>0)
)t1
group by change_no_change;

/*Q9 What was the total number of rolls ordered for each hour of the day?
*/

select hours_bracket,count(hours_bracket) as 'count' 
from
(select *,concat(cast(DATEPART(hour,order_date) as varchar),'-', 
cast(DATEPART(hour,order_date) +1 as varchar)) as 'hours_bracket'
from customer_orders)t1
group by hours_bracket;

/*Q10 What was the no. of orders for each day of the week?
*/

select Day_of_week,count(distinct order_id) as 'count'
from
(select *,datename(dw,order_date) as'Day_of_week' 
from customer_orders)t1
group by Day_of_week;

--B Driver & Customer Experience

/*Q1 What was the average time in minutes it took for each driver to 
reach at faasos HQ to pick up the order?
*/

select * from customer_orders;
select * from driver_order;

select driver_id,avg(diff) as 'average'
from
(select * from
(select *, row_number() over(partition by order_id order by diff) as'rank'
from
(select t1.order_id,t1.customer_id,t1.roll_id,t1.not_include_items,t1.extra_items_included,t1.order_date,
t2.driver_id,t2.pickup_time,t2.distance,t2.duration,t2.cancellation,
datediff(minute,t1.order_date,t2.pickup_time) as 'diff'
from customer_orders t1
inner join driver_order t2
on t1.order_id=t2.order_id
where t2.pickup_time is not null)t2)t3
where rank=1)t4
group by driver_id;

/*Q2 Is there any relationship between the number of rolls and how long the order takes to prepare?
*/

select order_id,count(roll_id) as 'count_of_rolls',sum(diff)/count(roll_id) as 'time_for_1_roll'
from
(select t1.order_id,t1.customer_id,t1.roll_id,t1.not_include_items,t1.extra_items_included,t1.order_date,
t2.driver_id,t2.pickup_time,t2.distance,t2.duration,t2.cancellation,
datediff(minute,t1.order_date,t2.pickup_time) as 'diff'
from customer_orders t1
inner join driver_order t2
on t1.order_id=t2.order_id
where t2.pickup_time is not null)t1
group by order_id
order by order_id ;
--ANS->>  Relationship is that 1 roll takes 10 mins average


/*Q3 What's the Average distance travelled for each customer?
*/

select customer_id,sum(distance)/count(order_id) from
(select  * from
(select *,ROW_NUMBER() over(partition by order_id order by diff) as 'rank' 
/*We are taking row number function so that we can take 1 value of distance value for 
1 same value of order_id, so that we get correct 
average for each customer
*/
from
(select t1.order_id,t1.customer_id,t1.roll_id,t1.not_include_items,t1.extra_items_included,t1.order_date,
t2.driver_id,t2.pickup_time,
cast(trim(replace(t2.distance,'km',''))as decimal(4,2)) as 'distance',
t2.duration,t2.cancellation,
datediff(minute,t1.order_date,t2.pickup_time) as 'diff'
from customer_orders t1
inner join driver_order t2
on t1.order_id=t2.order_id
where t2.pickup_time is not null)t1
)t2
where rank=1)t3
group by customer_id

/*Q4 What was the difference b/w longest and shortest delivery times for all orders?
*/

select max(new_duration)-min(new_duration) as 'Difference' from
(select cast(case when duration like '%min%' then left(duration,CHARINDEX('m',duration)-1) else duration end as int) as 'new_duration'
from driver_order
where duration is not null)t1

/*Q5 What was the average speed for each driver for each delivery and do you notice any trend for these values?
*/

select t1.order_id,t1.driver_id,t2.count,distance/duration as 'Speed' from --speed=distance/time which is in km/min
(select order_id,driver_id,
cast(case when duration like '%min%' then left(duration,CHARINDEX('m',duration)-1) else duration end as int) as 'duration',
cast(trim(replace(distance,'km',''))as decimal(4,2)) as 'distance'
from driver_order where duration is not null)t1
inner join (select order_id,count(roll_id) as 'count' from customer_orders group by order_id) t2 
on t1.order_id=t2.order_id
-- trend is that when the count of rolls is 1 average speed is more compared to when the no. of rolls is 
--3

/*Q6 What is the successful delivery % for each driver?
successful delivery % = successful delivery/total delivery * 100
*/


select driver_id,sum(cancel) as 'successful',count(cancel) as'total',
sum(cancel)*1.0/count(cancel) as 'percentage' 
--multiplying by 1.0 to get percentage in decimals
from
(select driver_id,case when cancellation like '%cancel%' then 0 else 1 end as 'cancel'
from driver_order)t1
group by driver_id






















