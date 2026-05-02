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
