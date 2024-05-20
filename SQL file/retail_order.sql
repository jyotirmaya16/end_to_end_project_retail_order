create database retail; -- 3,5,
use retail;

create table retail_order(
order_id int,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state varchar(20),
postal_code int,
region	varchar(20),
category varchar(20),
sub_category varchar(20),
product_id	varchar(20),
quantity int,
discount decimal(7,2),
sale_price decimal(7,2),
profit decimal(7,2)
);
select * from retail_order;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'retail' AND TABLE_NAME = 'retail_order';   -- for seeing all column along with its data types


-- 1.find top 10 highest reveue generating products 

select category,sub_category,product_id,sum(sale_price)as sale  from retail_order
group by category,sub_category,product_id order by sale desc limit 10;

-- 2.find top 5 highest selling products in each region

select * from
(select * ,
row_number()over(partition by region order by sale desc)as rnk from
(select region,category, sub_category, product_id, sum(sale_price) as sale from retail_order
group by region,category, sub_category, product_id order by region, sale desc)as k)as i
where rnk<6;

-- 3. find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte as(
select year(order_date)as yearr,month(order_date)as monthh, sum(sale_price)as sale from retail_order
group by yearr,monthh)

select monthh,
sum(case when yearr="2022" then sale else 0 end )as sale_2022,
sum(case when yearr="2023" then sale else 0 end )as sale_2023
from cte
group by monthh order by monthh;


-- 4. for each category which date had highest sales

with cte as 
(select category,year(order_date)as yearr,month(order_date)as monthh,sum(sale_price)as sale from retail_order
group by yearr,monthh,category  order by category,sale desc)

select * from 
(select *,
row_number()over(partition by category order by sale desc)as rn from cte)as k
where rn=1;


-- 5.which sub category had highest growth by sale in 2023 compare to 2022

with cte as 
(select sub_category,year(order_date)as yearr,sum(sale_price)as sale from retail_order
group by sub_category,yearr)
,cte2 as 
(select sub_category,
sum(case when yearr="2022" then sale else 0 end)as sale_2022,
sum(case when yearr="2023" then sale else 0 end)as sale_2023
from cte
group by sub_category)

select *,(sale_2023 - sale_2022)as growth from cte2
order by growth desc;



-- 6.Calculate the Average Discount and Total Sales for Each Segment and Ship Mode
select * from retail_order;

select segment, ship_mode, round(avg_discount,1)as avg_discount, total_sale from 
(select segment,ship_mode,avg(discount)as avg_discount , sum(sale_price)as total_sale from retail_order
group by segment,ship_mode order by segment)as k;

























