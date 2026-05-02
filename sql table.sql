create database	super_store;
use super_store;
create table customer(
	customer_id varchar (20),
	customer_name varchar (20),	
    city varchar (20),	
    region varchar (20));
    
create table  employee(
	employee_id varchar (20),
	employee_name varchar (20),	
    department varchar (20));
    
create table product(
	Product_ID varchar (20),
	Product_Name varchar (60),
 	Category varchar (20),
    Price int);
    
create table orders(
	order_id varchar (20),
	order_date date,
	customer_id varchar (20),
	product_id varchar (20),	
    employee_id varchar (20),	
    quantity int,
	total_amount int);