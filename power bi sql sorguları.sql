--Calculating Total Sales

update products_orders
set "tablo" = "unit_price" * "quantity";

alter table products_orders
rename column tablo to total_sales;

--Total Sales by Month for The Year 1996

select date_trunc('month', "order_date")
as "month",
sum("total_sales") as 
"monthlysales"
from products_orders
where extract(year from "order_date") = 1996
group by "month"
order by "month";

--Total Sales by Month for The Year 1997

select date_trunc('month', "order_date")
as "month",
sum("total_sales") as 
"monthlysales"
from products_orders
where extract(year from "order_date") = 1997
group by "month"
order by "month";

--Suppliers' sales by years
  
select extract (year from po.order_date) as
orderyear, 
s.supplier_id, s.company_name,
sum(po.total_sales) as total_sales
from products_orders po
join suppliers s on po.supplier_id = s.supplier_id
group by orderyear, s.supplier_id, s.company_name
order by orderyear, total_sales desc;

--Stock Turnover Analysis

select p.product_name,
sum(po.quantity) as total_sales,
avg(p.unit_in_stock) as average_stock,
sum(po.total_sales) as total_revenue,
sum(po.quantity) / nullif(avg(p.unit_in_stock),0) 
as stock_turnover
from products p
join products_orders po on p.product_id = po.product_id
group by p.product_name;

--Employee Performance Analysis (total_revenue was used as the performance criterion.)

select e.employee_id,
concat(e.first_name, ' ', e.last_name) as full_name,
sum(po.total_sales) as total_revenue from employees e
join products_orders po on e.employee_id = po.employee_id
group by e.employee_id, full_name
order by total_revenue desc;

--Performance Analysis by Department (total_revenue was used as the performance criterion.)

select e.title as department,
sum(po.total_sales) as total_revenue
from employees e 
join products_orders po on e.employee_id = po.employee_id
group by e.title
order by total_revenue desc;

--Employee Distribution by Country

select country,
count(employee_id) as employee_count
from employees
group by country
order by employee_count desc;

--Employee distribution by department

select title, count(employee_id) as employee_count
from employees
group by title
order by employee_count desc;

--Hierarchy map

select e.employee_id as employee,
concat(e.first_name, ' ', e.last_name) as employee_name,
concat (m.first_name, ' ', m.last_name) as manager_name
from employees e
left join employees m on e.reports_to = m.employee_id
order by e.employee_id;

--Employees of the year

select po.employee_id,
concat(e.first_name, ' ', e.last_name) as employee_name,
date_part ('year', po.order_date) as year,
sum(po.total_sales) as total_sales
from products_orders po
join employees e on po.employee_id = e.employee_id
group by po.employee_id, employee_name, year
order by year, total_sales desc;

--I wanted to see the data types

select column_name, data_type
from information_schema.columns
where table_name = 'products_orders';


select po.order_date,
date_part('year', po.order_date)
as year
from products_orders po
limit 10;

select * from customers

--Customer Segmentation

select c.customer_id, c.company_name, sum(po.total_sales)
as total_spent,
case when sum(po.total_sales)<= 5000 then 'low tech'
when sum (po.total_sales)
between 5001 and 20000 then 'medium'
else 'high tech' end as spending_segment from customers c 
join products_orders po on c.customer_id = po.customer_id
group by c.customer_id, c.company_name
order by total_spent desc;

select * from customers

--Customer Loyalty
  
select c.customer_id, c.company_name, count(po.order_id)
as total_orders,
case when count(po.order_id)
between 1 and 30 then 'low tech'
when count (po.order_id)
between 30 and 60 then 'medium'
else 'high tech' end as customer_segment from customers c 
join products_orders po on c.customer_id = po.customer_id
group by c.customer_id, c.company_name
order by total_orders desc;

--Reorder Level Analysis

select product_name, unit_in_stock, reorder_level
from products
where unit_in_stock <= reorder_level;
--Yeniden sipariş edilmesi gereken ürünler
select product_name, 
reorder_level - unit_in_stock as
reorder_quantity from products
where unit_in_stock < reorder_level;

--Churn Analysis

select c.customer_id, c.company_name as customer_name,
max(po.order_date) as last_order_date,
count(po.order_id) as total_orders,
sum(po.total_sales) as total_spent,
case when max (po.order_date)< 
'1998-01-01' then 'High Churn Risk'
when max(po.order_date)<
'1998-03-01'
then 'Medium Churn Risk'
else 'Low Churn Risk'
end as churn_risk
from customers c
left join products_orders po on c.customer_id = po.customer_id
group by c.customer_id, c.company_name;

--Customer Distribution by Countries

select country, count (*) as customer_count
from customers group by country
order by customer_count desc;




