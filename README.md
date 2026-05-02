# 🛒 Super Store Sales Analysis

## 📌 Project Overview
**Project Title:** Super Store Sales Analysis  
**Level:** Intermediate  
**Database:** `super_store`  
**Tool:** MySQL  

This project demonstrates **SQL skills and techniques** used by data analysts to explore and analyze a retail super store dataset. The project covers **database exploration, advanced SQL queries, window functions, and customer segmentation** using **RFM analysis** and **Cohort Analysis**. It is ideal for those looking to strengthen their SQL skills with real-world business scenarios.

---

## 📁 Database Schema
The project uses the `super_store` database with **4 main tables**:

| Table | Description |
| :--- | :--- |
| **customer** | Customer information (name, city, etc.) |
| **employee** | Employee details (name, department, etc.) |
| **orders** | Order transactions (date, amount, quantity, etc.) |
| **product** | Product catalog (name, category, price, etc.) |

---

## 🎯 Objectives
The primary goals of this project are:
*   **Explore and understand** the super store dataset.
*   Perform **sales trend analysis** (monthly, yearly, running totals).
*   Analyze **customer behavior** and segmentation.
*   Evaluate **employee and department performance**.
*   Identify **top products and categories** by revenue.

---

## 📊 Project Structure & SQL Queries

### 1. 🔍  Data Exploration
```sql
select * from customer;
select * from employee;
select	* from orders;
select * from product;
```
### 2. 💰 Sales Analysis
**Total Revenue**:
```sql
select 
sum(total_amount)
from orders;
```
**Best-Selling Category**:
```sql
select 
p.Category ,
sum(total_amount) as total_amount
from orders o
left join product p
on o. product_id = p. Product_ID
group by 1;
```
**Monthly / Yearly Sales**:
```sql
select 
DATE_FORMAT(order_date, '%b') as Month,
date_format(order_date, '%Y') as Year,
sum(total_amount) as total_sales
from orders
group by 1,2
ORDER BY 1,2;
```
**Sales Running Total & Percent of Annual Total**:
```sql
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
```
**Sales Moving Average (3-Month)**:
```sql
select
month(order_date) as month,
year (order_date) as year, 
count(*) as total_order,
sum(quantity) as quantity,
sum(total_amount) as total_amount,
round( AVG(SUM(total_amount)) OVER (
        ORDER BY YEAR(ORDER_DATE), MONTH(ORDER_DATE)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW 
    ),1) AS moving_average
from orders
group by 1,2
order by 2,1;
```
**Sales Growth Rate vs Previous Month**:
```sql
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
```
**Average Order Value**:
```sql
SELECT 
    MONTH(order_date) AS month,
    YEAR(order_date) AS year,
    SUM(total_amount) AS total_amount,
    ROUND(AVG(total_amount), 1) AS avg_order_value
FROM
    orders
GROUP BY 1 , 2
ORDER BY 2 , 1;
```
### 3. 👥 Customer Analysis
**City with Most Orders**:
```sql
select 
* 
from (select city, 
		sum(total_amount)
	from customer c 
		join orders o 
        on o.customer_id = c.customer_id
	group by 1
    order by 2 desc) as co;
```
**Top 5 Customers by Revenue**:
```sql
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
```
**Largest Region by Customer Base**:
```sql
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
```
**Customers with no orders**:
```sql
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
```
**Customer Lifetime Value (CLV)**:
```sql
SELECT 
customer_id,
count(distinct order_id) as total_Order ,
sum(quantity) as total_quantity,
avg(total_amount) as avg_order_value,
sum(total_amount) as total_spent
FROM orders
group by 1
order by 5 desc;
```
**New vs Returning Customers**:
```sql
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
;.
```
**Customers with No Orders in Last 20+ Days**:
```sql
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
order by 4 Desc;.
```
