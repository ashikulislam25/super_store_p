use super_store;
select * from customer;
select * from employee;
select	* from orders;
select * from product;

--- total revenue
select 
sum(total_amount)
from orders;

--- Best-selling category
select 
p.Category ,
sum(total_amount)
from orders o
left join product p
on o. product_id = p. Product_ID
group by 1;
--- Monthly / yearly sales
select 
DATE_FORMAT(order_date, '%b') as Month,
date_format(order_date, '%Y') as Year,
sum(total_amount) as total_sales
from orders
group by 1,2
ORDER BY 1,2;
/* Sales Running Total & Percent of anual total*/
select  
date_format (order_date,'%m') as Month,
date_format(order_date,'%Y') as Year,
count(*) as total_order,
sum(quantity) as quantity,
sum(total_amount) as total_amount,
SUM(SUM(total_amount)) OVER (
        PARTITION BY DATE_FORMAT(order_date, '%Y') 
        ORDER BY DATE_FORMAT(order_date, '%m')
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
round( SUM(SUM(total_amount)) OVER (
        PARTITION BY DATE_FORMAT(order_date, '%Y') 
        ORDER BY DATE_FORMAT(order_date, '%m')
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )/SUM(SUM(total_amount)) OVER (
        PARTITION BY DATE_FORMAT(order_date, '%Y') ) *100,1) as percent_of_annual_total
from orders
group by 1,2
order by 2,1;

--- Sales Moving Average
select
month(order_date) as month,
year (order_date) as year, 
count(*) as total_order,
sum(quantity) as quantity,
sum(total_amount) as total_amount,
round( AVG(SUM(total_amount)) OVER (
        ORDER BY YEAR(ORDER_DATE), MONTH(ORDER_DATE)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW -- এখানে BETWEEN শব্দটি আগে হবে
    ),1) AS moving_average
from orders
group by 1,2
order by 2,1;

-- Sales Growth Rate vs previous months 
select 
Month (order_date) as month,
Year (order_date) as year,
sum(total_amount) as total_amount,

lag	(sum(total_amount)) over( order by year(order_date) , month (order_date)) as previous_months,

round((sum(total_amount) - lag	(sum(total_amount)) over( order by year(order_date) , month (order_date))) /
lag	(sum(total_amount)) over( order by year(order_date) , month (order_date))*100,1) AS grouth_rate 

from orders
group by 1,2
order by 2,1;

-- Avg Order Value

SELECT 
    MONTH(order_date) AS month,
    YEAR(order_date) AS year,
    SUM(total_amount) AS total_amount,
    ROUND(AVG(total_amount), 1) AS avg_order_value
FROM
    orders
GROUP BY 1 , 2
ORDER BY 2 , 1;

--  City with most orders
 
select 
* 
from (select city, 
		sum(total_amount)
	from customer c 
		join orders o 
        on o.customer_id = c.customer_id
	group by 1
    order by 2 desc) as co;
    
-- Top 5 customers by revenue
SELECT 
    *
FROM
    (SELECT 
        o.customer_id, customer_name, SUM(total_amount)
    FROM
        customer c
    JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY 1 , 2
    ORDER BY 3 DESC) AS co
LIMIT 5;

-- Largest region by customer base

SELECT 
    *
FROM
    (SELECT 
        city, COUNT(DISTINCT c.customer_id), SUM(total_amount)
    FROM
        customer c
    JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY 1
    ORDER BY 3 DESC) AS co;
    
-- Customers with no orders
SELECT 
    *
FROM
    (SELECT 
        city, COUNT(DISTINCT c.customer_id) as total_customer, SUM(total_amount)
    FROM
        customer c
    JOIN orders o ON o.customer_id = c.customer_id
       GROUP BY 1
       having COUNT(DISTINCT c.customer_id) <1
    ORDER BY 3 DESC) AS co;
    
-- Customer Total Revenue(CLV)

SELECT 
customer_id,
count(distinct order_id) as total_Order ,
sum(quantity) as total_quantity,
avg(total_amount) as avg_order_value,
sum(total_amount) as total_spent
FROM orders
group by 1
order by 5 desc;

-- New vs returning customers 
SELECT 
    customer_id,
    COUNT(order_id) AS total_order,
    SUM(total_amount) total_amount,
    IF(COUNT(order_id) > 1,
        'Retarning',
        'New') AS customer_status
FROM
    orders
GROUP BY 1
;

-- no order last 20+ days
with ref_da as(
select 
max(order_date) as ref_date 
from orders
)
select
customer_id,
 min(order_date) as first_order,
 max(order_date) as last_order,
datediff (ref_da.ref_date,max(order_date)) as date_diff
from orders
cross join  ref_da
group by 1,ref_da.ref_date
having date_diff>=20
order by 4 Desc;

 -- Employee with most order shandled
 select 
	employee_id,
    (select employee_name from employee e
    where e.employee_id=o.employee_id ) as employee_name ,
    count(distinct order_id) as total_order,
    sum(total_amount) as total_amount,
   round( avg(total_amount),1) as avg_order_value
 from orders o
 group by 1;
-- Department revenue contribution
SELECT 
    e.department,
    COUNT(DISTINCT order_id) AS total_order,
    SUM(total_amount) AS total_amount,
    ROUND(AVG(total_amount), 1) AS avg_order_value
FROM
    orders o
left join employee e
on o.employee_id=e.employee_id
GROUP BY 1;
-- Employee sales performanceranking
SELECT 
    employee_id,
    COUNT(DISTINCT order_id) AS total_order,
    SUM(total_amount) AS total_amount,
    row_number() over(order by sum(total_amount) desc ) as sales_rank
FROM
    orders o
GROUP BY 1;

--  Monthly employee sales compare
select 
Month (order_date) as month,
Year (order_date) as year,
employee_id,
count(distinct order_id) as total_order,
sum(total_amount) as total_amount,
lag	(sum(total_amount)) over( order by year(order_date) , month (order_date)) as previous_months

from orders
group by 1,2,3
order by 2,1;

-- Average product price
select 
*,
round(avg(Price) over(),1) as avg_product_price
from product
;
-- Top 5 products by revenue
select 
o.product_id,
product_name,
sum(quantity),
sum(total_amount) as amount
from orders o
join product p 
on o.product_id=p.product_id
group by 1,2
order by 4 desc
limit 5;
-- Bottom 5 products (least sold)
select 
o.product_id,
product_name,
sum(quantity),
sum(total_amount) as amount
from orders o
join product p 
on o.product_id=p.product_id
group by 1,2
order by 4 asc
limit 5;
-- Category revenue share (%)
select 
Category,
sum(quantity),
sum(total_amount) as amount
from orders o
join product p 
on o.product_id=p.product_id
group by 1
order by 3 desc;
-- RFM
with ref_table as(
select  max(order_date) as ref_date from orders),
rfm as (
select 
customer_id,
datediff(r.ref_date,max(order_date)) as recency,
count(distinct order_id) as fequency,
sum(total_amount) as monetary
from orders o
cross join ref_table r
group by 1,r.ref_date),
final_rfm as (
select 
customer_id,
recency,
fequency,
monetary,
ntile(5) over(order by recency desc) as r_recency,
ntile(5) over(order by fequency asc) as r_fequency,
ntile(5) over(order by monetary asc) as r_monetary
from rfm),
rfm_combination as (
select 
	r.*,
    R_recency + r_fequency + r_monetary AS TOTAL_RFM_SCORE, 
    concat_ws('', r_recency,r_fequency,r_monetary) as rfm_combination 
from final_rfm r)  

select
customer_id,
recency,
fequency,
monetary,
TOTAL_RFM_SCORE,
rfm_combination,
 CASE
		WHEN RFM_COMBINATION IN (455, 515, 542, 544, 552, 553, 452, 545, 554, 555) THEN "Champions"
        WHEN RFM_COMBINATION IN (344, 345, 353, 354, 355, 443, 451, 342, 351, 352, 441, 442, 444, 445, 453, 454, 541, 543, 515, 551) THEN 'Loyal Customers'
        WHEN RFM_COMBINATION IN (513, 413, 511, 411, 512, 341, 412, 343, 514) THEN 'Potential Loyalists'
        WHEN RFM_COMBINATION IN (414, 415, 214, 211, 212, 213, 241, 251, 312, 314, 311, 313, 315, 243, 245, 252, 253, 255, 242, 244, 254) THEN 'Promising Customers'
        WHEN RFM_COMBINATION IN (141, 142,143,144,151,152,155,145,153,154,215) THEN 'Needs Attention'
        WHEN RFM_COMBINATION IN (113, 111, 112, 114, 115) THEN 'About to Sleep'
        ELSE "Other"
        END AS CUSTOMER_SEGMENT
from rfm_combination c;

-- cohort
WITH BASE_DATA AS (
    SELECT
        CUSTOMER_ID,
		ORDER_DATE,
        MIN(order_date) OVER (PARTITION BY CUSTOMER_ID) AS FIRST_TRANSACTION_DATE
    FROM Orders
  ),
COHORT_CALC AS (
    SELECT 
        DATE_FORMAT(FIRST_TRANSACTION_DATE, '%Y-%m-01') AS COHORT,
        CUSTOMER_ID,
        -- মাস গণনা করার জন্য DATEDIFF ব্যবহার করে তাকে ৩০ দিয়ে ভাগ করা হয়েছে
       CONCAT('Month_', 
            (YEAR(ORDER_DATE) - YEAR(FIRST_TRANSACTION_DATE)) * 12 + 
            (MONTH(ORDER_DATE) - MONTH(FIRST_TRANSACTION_DATE))
        ) AS COHORT_MONTH
    FROM BASE_DATA
)
SELECT
    COHORT,
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_0' THEN CUSTOMER_ID END) AS "MONTH_0",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_1' THEN CUSTOMER_ID END) AS "MONTH_1",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_2' THEN CUSTOMER_ID END) AS "MONTH_2",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_3' THEN CUSTOMER_ID END) AS "MONTH_3",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_4' THEN CUSTOMER_ID END) AS "MONTH_4",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_5' THEN CUSTOMER_ID END) AS "MONTH_5",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_6' THEN CUSTOMER_ID END) AS "MONTH_6",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_7' THEN CUSTOMER_ID END) AS "MONTH_7",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_8' THEN CUSTOMER_ID END) AS "MONTH_8",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_9' THEN CUSTOMER_ID END) AS "MONTH_9",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_10' THEN CUSTOMER_ID END) AS "MONTH_10",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_11' THEN CUSTOMER_ID END) AS "MONTH_11",
    COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_12' THEN CUSTOMER_ID END) AS "MONTH_12"
FROM COHORT_CALC
GROUP BY COHORT
ORDER BY COHORT;