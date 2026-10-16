create database indian_e_commerce;
use indian_e_commerce;

select count(*) from customer_review;

select database();

show tables;

SELECT COUNT(*) FROM customer;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_item;
SELECT COUNT(*) FROM payment;
SELECT COUNT(*) FROM product;
SELECT COUNT(*) FROM shipment;
SELECT COUNT(*) FROM returns;
SELECT COUNT(*) FROM customer_review;
SELECT COUNT(*) FROM market_camp;



describe customer;


select customer_signup_date, last_order_date
from customer
limit 10;

select customer_id ,
str_to_date(customer_signup_date , "%Y-%m-%d") as signup_date,
str_to_date(nullif(last_order_date,""),"%Y-%m-%d") as last_order
from customer
limit 10;


describe customer;

-- Q1. Total कितने customers हैं
select count(*) as total_customer
from customer;
# 25000

select * from
customer
limit 10;

-- Q2. kitne customers ne abhi तक कोई order नहीं kiya hai

select count(*) customer_without_order
from customer
where total_orders = 0;
# 2300

-- Q3. कितने customers ने कम से कम 1 order किया
select  count(*) customer_1_order
from customer
where total_orders >= 1;
# 22700

-- Q4. कितने customers ने 1, 2, 3... orders किए हैं

select total_orders,count(*) customer_count
from customer
group by total_orders
order by total_orders;
/*
0	2300
1	4005
2	4243
3	3750
4	3023
5	2009
6	442
7	1445
8	1109
9	799
10	609
11	390
12	280
13	222
14	149
15	87
16	61
17	36
18	11
19	5
20	17
21	4
22	3
24	1
*/

select * from
customer
limit 10;

-- Q5 — Customer Status Analysis
select customer_status , count(*) as customer_count
from customer
group by customer_status
order by customer_count desc;
/*
Churned	13365
Active	7234
Never Purchased	2300
At Risk	2101
8*/
-- Q6 — Customer Segment Analysis
select customer_segment , count(*) customer_count
from customer
group by customer_segment
order by customer_count desc;
/*
Regular	11002
Budget	7713
New	3294
Premium	2991
*/

-- Q7 — Segment-wise Total Spend

select customer_segment , count(*) customer_count , round(sum(total_spend),2) as total_spend , round(avg(total_spend),2) as avg_spend
from customer
group by customer_segment
order by total_spend desc;
/*
Regular	11002	1219709047.3	110862.48
Premium	2991	857288403.98	286622.67
Budget	7713	349825048.04	45355.25
New	3294	73955256.79	22451.5
*/


-- Q8 — Customer + Orders JOIN (हर customer ने actual orders table में कितने orders किए हैं)

select * from customer;
select * from orders;

select c.customer_id , c.customer_segment , count(o.order_id) total_orders
from customer as c
inner join orders as o
on c.customer_id = o.customer_id
group by c.customer_id , c.customer_segment
order by total_orders desc;

-- inner join me un logo ka data nhi aayega jinhone order nhi kiya hai abh ham left join se nikal kar dekhte hai 

select c.customer_id , c.customer_segment , count(o.order_id) total_orders
from customer as c
left join orders as o
on c.customer_id = o.customer_id
group by c.customer_id , c.customer_segment
order by total_orders desc;

-- Q10 हर customer segment से total कितने orders आए हैं और average orders/customer कितने हैं

select customer_segment ,
count(o.order_id) as total_order,
count(distinct(c.customer_id)) as customer,
round(count(o.order_id) / count(distinct(c.customer_id)) ,2 ) as avg_order_per_customer
from customer as c
left join orders as o
on c.customer_id = o.customer_id
group by c.customer_segment
order by total_order desc;

/*
important insight

Premium customers सिर्फ 2,991 हैं, लेकिन average:

लगभग 10 orders/customer
*/

-- Q11 कौन सा customer segment सबसे ज्यादा revenue generate कर रहा है

select * from customer;
select * from orders;

select customer_segment,
count(distinct(c.customer_id)) customer_count,
count(o.order_id) total_orders,
round(sum(o.final_amount),2) as total_revenue,
round(avg(o.final_amount),2) as avg_order_value
from customer as c
left join orders as o
on c.customer_id = o.customer_id
group by c.customer_segment
order by total_revenue desc;


SELECT
    c.customer_id,
    c.total_spend AS customer_table_spend,
    ROUND(SUM(o.final_amount), 2) AS orders_table_spend
FROM customer c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.total_spend
ORDER BY c.customer_id
LIMIT 20;

SELECT
    order_id,
    order_date,
    subtotal,
    shipping_fee,
    tax_amount,
    discount_percentage,
    final_amount
FROM orders
WHERE customer_id = 'CUST100021'
ORDER BY order_date;

SELECT
    order_id,
    customer_id,
    order_date,
    order_status,
    final_amount
FROM orders
WHERE order_id = 'ORD1012851';


-- कौन से products सबसे ज्यादा बिके
select * from product;

select product_name, count(*) total_product
from product
group by product_name;

select count(distinct(product_id)) as unique_product_sold
from product;
#  550

-- कौन सी category सबसे ज्यादा revenue देती है

select category , sum(price) as total_revenue
from product
group by category
order by total_revenue desc;

-- Quantity के हिसाब से Top 10 सबसे ज्यादा बिकने वाले products कौन से हैं

select p.product_name,p.product_id,p.category ,
sum(oi.quantity) as total_quantity_sold
from product p
inner join order_item oi
on p.product_id = oi.product_id
group by p.product_name,p.product_id,p.category
order by total_quantity_sold desc
limit 10;

select * from product;
select * from order_item;

-- कौन-सी product category सबसे ज्यादा quantity बेचती है, revenue generate करती है और profit कमाती है

select p.category , 
sum(oi.quantity) as total_quantity , 
round(sum(oi.item_revenue)/1000000,2) as total_revenue_million ,
round(sum(oi.profit)/1000000,2) as total_profit_million  
from product as p
inner join order_item as oi
on p.product_id = oi.product_id
group by p.category 
order by  total_revenue_million desc;

-- Kaunsi product category revenue ke comparison mein sabse zyada profit generate kar rahi hai

select p.category , 
sum(oi.quantity) as total_quantity,
round(sum(oi.item_revenue)/1000000,2) as total_revenue , 
round(sum(oi.profit)/1000000,2) total_profit,
round(sum(oi.profit)/sum(oi.item_revenue)*100,2) as revenue_agent_profit_comparision
from product as p
inner join order_item as oi
on p.product_id = oi.product_id
group by p.category
order by revenue_agent_profit_comparision desc;

-- कौन-से Top 10 products सबसे ज्यादा profit generate कर रहे हैं

select p.product_name , p.product_id, p.category,
round(sum(oi.item_revenue),2) as total_revenue,
round(sum(oi.profit),2) as total_profit
from product as p
inner join order_item as oi
on p.product_id = oi.product_id
group by product_name , product_id, category
order by total_profit desc
limit 10;


-- कौन-से Top 10 customers ने सबसे ज्यादा पैसा spend किया है
select c.customer_id , c.customer_segment , 
count(o.order_id) as total_orders,
round(sum(o.final_amount),2) total_spend
from customer as c
inner join orders as o
on c.customer_id = o.customer_id
group by c.customer_id , c.customer_segment
order by total_spend desc
limit 10;


-- कितने customers ने 1 से ज्यादा orders किए हैं
select count(*) repeat_customers
from(
select customer_id , count(order_id) total_orders
from orders
group by customer_id
having total_orders > 1) as customers;

-- किस customer segment में repeat customers सबसे ज्यादा हैं
select c.customer_segment ,
count(distinct(c.customer_id)) repeat_customer
from customer c
inner join orders o
on c.customer_id = o.customer_id
group by c.customer_segment
having count(o.order_id) >1
order by repeat_customer desc;

-- हर customer का total order और total spending निकालकर, सबसे ज्यादा पैसा खर्च करने वाले Top 10 customers निकालिए। इस analysis के लिए CTE का इस्तेमाल कीजिए
with top_10_customer_spend as (
select c.customer_id, c.customer_segment,
count(o.order_id) as total_orders,
round(sum(o.final_amount),2) as total_spend
from customer c
inner join orders o
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_segment)

select customer_id , customer_segment, total_orders,total_spend
from top_10_customer_spend
order by  total_spend desc
limit 10;

-- हर customer segment के अंदर customers को उनके total spending के आधार पर rank कीजिए
with customer_segment_rank as
(select c.customer_id , c.customer_segment ,
count(o.order_id) as total_order,
round(sum(o.final_amount),2) as total_spend
from customer c
inner join orders o
on c.customer_id = o.customer_id
group by c.customer_id , c.customer_segment)

select customer_id , customer_segment, total_order , total_spend,
rank() over(partition by customer_segment order by total_spend desc) as customer_rank
from customer_segment_rank
order by customer_segment,customer_rank;

-- हर customer segment से सबसे ज्यादा spending करने वाले Top 3 customers निकालिए
with customer_segment_ranking as (
select c.customer_id , c.customer_segment , 
count(o.order_id) total_order,
round(sum(o.final_amount),2) as total_spend
from customer c
inner join orders o 
on c.customer_id = o.customer_id
group by c.customer_id , c.customer_segment),
ranked_customer as
(
select customer_id , customer_segment, total_order , total_spend,
rank() over(partition by customer_segment order by total_spend desc) as ranked
from customer_segment_ranking
)

select customer_id , customer_segment, total_order , total_spend, ranked
from ranked_customer
where ranked <= 3
order by customer_segment , ranked;

-- हर customer ने पहली बार order कब किया था, यानी उसका first order date निकालिए

select customer_id , min(order_date) as first_order
from orders
group by customer_id
order by first_order;


-- हर repeat customer ने अपने first order के कितने दिनों बाद second order किया

with customer_order as
(select customer_id , order_id ,order_date,
row_number() over(partition by customer_id order by order_date) as ranked_order
from orders), 
first_order as
(
select customer_id,
max(case when ranked_order = 1 then order_date end) first_orders,
max(case when ranked_order = 2 then order_date end) secound_order
from customer_order
group by customer_id
)

select customer_id , first_orders , secound_order ,
datediff(secound_order , first_orders) as days_to_secound_order
from first_order
where secound_order is not null
order by days_to_secound_order;
-- Customers अपने first order के बाद average कितने दिनों में second order करते हैं

WITH customer_order AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS ranked_order
    FROM orders
),

first_order AS (
    SELECT
        customer_id,
        MAX(CASE WHEN ranked_order = 1 THEN order_date END) AS first_order,
        MAX(CASE WHEN ranked_order = 2 THEN order_date END) AS second_order
    FROM customer_order
    GROUP BY customer_id
)

SELECT
    ROUND(
        AVG(DATEDIFF(second_order, first_order)),
        2
    ) AS avg_days_to_second_order
FROM first_order
WHERE second_order IS NOT NULL;


use indian_e_commerce;


-- हर महीने की total revenue निकालिए और monthly revenue trend को analyze कीजिए।

Select round(sum(final_amount),2) as total_revenue,
date_format(order_Date,"%Y-%m") as order_month
from orders
group by date_format(order_Date,"%Y-%m")
order by total_revenue;

-- हर महीने की revenue को पिछले महीने की revenue से compare करके Month-over-Month (MoM) growth percentage निकालिए
with month_wise_total_revenue as (
select round(sum(final_amount),2) as total_revenue,
date_format(order_date , "%Y-%m") as order_month
from orders
group by date_format(order_date , "%Y-%m")
) , month_over_month as
(
select total_revenue , order_month ,
lag(total_revenue) over(order by order_month) as previous_month_revenue
from month_wise_total_revenue
)

select order_month , total_revenue , previous_month_revenue ,
(total_revenue - previous_month_revenue)/ previous_month_revenue *100 as month_growth_prcntg
from month_over_month
order by order_month;

-- वह कौन-सा महीना है जिसमें business की total revenue सबसे ज्यादा रही

select sum(final_amount) as total_revenue,
date_format(order_date, "%Y-%m") as year_of_month
from orders
group by year_of_month
order by total_revenue desc ;

with monthly_revenue as (
select round(sum(final_amount),2) as total_revenue,
	   date_format(order_date,"%Y-%m") as years_months
from orders
group by date_format(order_date,"%Y-%m")
)

select total_revenue , years_months
from monthly_revenue
order by total_revenue desc
limit 1;

-- Sabse zyada revenue generate karne wale Top 5 products nikaliye
select * from product;
select * from order_item;

select oi.product_id, p.product_name, sum(oi.item_revenue) as total_revenue
from product p
inner join order_item oi
on p.product_id = oi.product_id
group by oi.product_id, p.product_name
order by total_revenue desc
limit 5;

-- Top 5 Products by Profit 

select oi.product_id,p.product_name, sum(oi.profit) total_profit
from product p
inner join order_item oi
on p.product_id = oi.product_id
group by oi.product_id, p.product_name
order by total_profit desc
limit 5;

-- Top 5 Products by Profit margin

select oi.product_id,p.product_name, 
sum(oi.quantity) as total_quantity,
sum(oi.item_revenue) total_revenue,
sum(oi.profit) / sum(oi.item_revenue) *100 as profit_margin_prcntg
from product p
inner join order_item oi
on p.product_id = oi.product_id
group by oi.product_id, p.product_name
order by profit_margin_prcntg desc
limit 5;

-- Top 5 Customers by Average Order Value (AOV)

select * from customer;
select * from orders;

select c.customer_id , 
count(o.order_id) as total_order,
sum(o.final_amount) as total_revenue_by_order,
sum(o.final_amount) / count(o.order_id) as average_order_value_by_orders
from customer c
inner join orders o
on c.customer_id = o.customer_id
group by c.customer_id
order by average_order_value_by_orders desc 
limit 5;

-- Customers Who Have Never Purchased

select c.customer_id,c.customer_segment,c.customer_status 
from customer c
left join orders o
on c.customer_id = o.customer_id
where o.order_id is null;

-- Un customers ka percentage nikaliye jinhone 1 se zyada orders place kiye hain
with repeat_customer_percentage as (
select customer_id , count(order_id) as total_order
from orders
group by customer_id
having total_order > 1)

select count(*) repeat_customer,
        (select count(*) from customer) as total_customer,
round(count(*) / (select count(*) from customer) *100,2 ) as repeat_customer_prcntg
from repeat_customer_percentage;

-- ऐसे customers का percentage निकालिए जिन्होंने exactly 1 order किया है
with order_1 as (
select customer_id , count(order_id) as total_order
from orders
group by customer_id
having total_order = 1)

select count(*) orderss,
(select count(*) from customer) as total_customer,
round(count(*) / (select count(*) from customer) *100 ,2 ) as 1_order_percentage
from order_1;

-- हर Order Status के लिए total orders और total revenue निकालिए 

select * from orders;
select order_status, count(order_id) as total_order , sum(final_amount) as total_revenue
from orders
group by order_status
order by total_revenue desc;

-- हर order status के लिए Average Order Value निकालिए
select order_status , count(order_id) as total_order , sum(final_amount) as total_revenue,
sum(final_amount) / count(order_id)  as average_order_value 
from orders
group by order_status
order by average_order_value desc;

-- हर order status के लिए average delivery days निकालिए
select * from orders;
select * from shipment;

select o.order_status,
round(avg(datediff(actual_delivery_date,o.order_date)),2) as delivery_day
from orders o
left join shipment s
on o.order_id = s.order_id
where actual_delivery_date is not null
group by o.order_status
order by delivery_day;

-- हर marketing campaign से कितने orders आए और कितनी total revenue generate हुई, यह निकालिए

select * from market_camp;
select * from orders;

select mc.campaign_name , count(o.order_id) as total_order, round(sum(o.final_amount),2) as total_revenue
from market_camp as mc
left join orders as o
on mc.campaign_id = o.campaign_id
group by mc.campaign_name
order by total_revenue desc ;

-- हर customer segment के top 3 customers निकालिए, जो total revenue के आधार पर सबसे ज्यादा spend करते हैं। साथ में उनके total orders और segment के अंदर उनका rank भी दिखाइए

select * from customer;
select * from orders;
with customer_wise as (
select c.customer_id,c.customer_segment ,
count(o.order_id) as total_order,
round(sum(o.final_amount),2) total_revenue 
from customer c
left join orders o
on c.customer_id = o.customer_id
group by c.customer_id,c.customer_segment
),
customer_segment_wise as
(
select customer_id , total_order, customer_segment , total_revenue ,
row_number() over(partition by customer_segment order by total_revenue desc ) as ranked_by_segment
from customer_wise
)

select customer_id, customer_segment , total_order,total_revenue , ranked_by_segment
from customer_segment_wise
where ranked_by_segment <=3 
order by customer_segment , ranked_by_segment;
