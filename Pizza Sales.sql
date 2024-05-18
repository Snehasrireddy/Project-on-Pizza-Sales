create database orders;
use orders; 

select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

---Retrieve the total number of orders placed
select count(*) as Total_no_orders from orders;

---Calculate the total revenue generated from pizza sales
select round(sum(cast(p.price as float)*od.quantity),2) as total_revenue from pizzas as p inner join order_details as od on od.pizza_id=p.pizza_id;

---Identify the highest priced pizza
select Top 1 name,max(cast(price as float)) as highest_price from pizzas as p inner join pizza_types as py  on py.pizza_type_id=p.pizza_type_id 
group by name order by highest_price desc;

---Identify the most common pizza size ordered 
select count(order_details_id) as count_of_pizzas,size as most_common_pizza_size from pizzas as p
 join order_details as o on o.pizza_id=p.pizza_id group by size order by count_of_pizzas desc;  

---List Top 5 most ordered pizza types along with their quantities
select Top 5 name,sum(cast(o.quantity as int)) as quantities from pizza_types as py
inner join pizzas as p on py.pizza_type_id=p.pizza_type_id 
inner join order_details as o on o.pizza_id=p.pizza_id group by name order by quantities desc;

---Join the neccessary tables to find the total quantity of each pizza category ordered
select sum(cast(quantity as int)) as total_quantity,category from order_details as o,pizza_types as py,pizzas as p 
where o.pizza_id=p.pizza_id and py.pizza_type_id=p.pizza_type_id group by category order by total_quantity desc;

---Determine the distribution of orders by hour of the day
SELECT DATEPART(HOUR,time) as order_hour,count(order_id) as total_orders FROM  orders as o 
GROUP BY DATEPART(HOUR,time)
ORDER BY total_orders desc;

---Join relevant tables to find the category wise distribution of pizzas
Select category,count(name) as distribution_of_pizza from pizza_types as py group by category;
   
---Group the orders by date and calculate the average number of pizzas ordered per day
select round(avg(cast(total_quantity as int)),2) as avg_no_of_pizzas_perday from  
(select date,sum(cast(od.quantity as int)) as total_quantity from orders as o
inner join order_details  as od on o.order_id=od.order_id group by date) as a;

---Determine the Top 3 most ordered pizza types based on revenue
select Top 3 name,round(sum(cast(p.price as float)*o.quantity),2) as total_revenue from pizzas as p
inner join order_details as o on o.pizza_id=p.pizza_id 
inner join pizza_types as py on py.pizza_type_id=p.pizza_type_id
group by name order by total_revenue desc; 

---calculate the percentage contribution of each pizza type to total revenue 
 select py.category,(sum(cast(p.price as float)*od.quantity)/(select round(sum(cast(p.price as float)*od.quantity),2) as revenue from pizzas as p
 inner join order_details as od on p.pizza_id=od.pizza_id
 inner join pizza_types as py on py.pizza_type_id=p.pizza_type_id))*100 as rev from pizza_types as py 
 inner join pizzas as p on py.pizza_type_id=p.pizza_type_id
 inner join order_details as od on od.pizza_id=p.pizza_id group by py.category;

---Analyse the cumulative revenue generated over time
SELECT 
      CONVERT(time,time) AS OrderTime,
    SUM(revenue) OVER (ORDER BY CONVERT(time, time)) AS CumulativeRevenue
FROM 
    (SELECT 
        o.time,
        ROUND(SUM(CAST(p.price AS float) * od.quantity), 2) AS revenue
    FROM 
        pizzas AS p
    INNER JOIN 
        order_details AS od ON p.pizza_id = od.pizza_id 
    INNER JOIN 
        orders AS o ON od.order_id = o.order_id 
    GROUP BY 
        o.time
    ) AS a;

---Determine the top 3 most ordered price types based on revenue for each pizza category 
select name,category,total_sales from
(select name,category,total_sales,rank()OVER (partition by category ORDER BY total_sales desc) as rnk
from
(select py.name,py.category,round(sum(cast(p.price as float)*od.quantity),2) as total_sales from pizzas as p 
inner join order_details as od on p.pizza_id=od.pizza_id
inner join pizza_types as py on py.pizza_type_id=p.pizza_type_id 
group by py.name,py.category) as a) as aa 
where rnk<=3; 

