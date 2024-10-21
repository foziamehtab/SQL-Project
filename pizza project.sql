create database pizzahut;

use pizzahut;

create table orders(
order_id int not null primary key,
order_date date not null,
order_time time not null);

create table order_details(
order_details_id int not null primary key,
order_id int not null,
pizza_id text not null,
quantity int not null);

-- Q-1:Retrieve the total number of orders placed.
select count(order_id) from orders;

-- Q-2:Calculate the total revenue generated from pizza sales.
select 
round(sum(od.quantity*p.price),2) as total_sales 
from pizzas p 
join order_details od 
on p.pizza_id=od.pizza_id;

-- :Q-3:Identify the highest-priced pizza.
select pt.name, p.price as highest_price 
from pizzas p 
join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by pt.name,p.price
order by p.price desc
limit 1;

-- Q-4: Identify the most common pizza size ordered.
select p.size, count(od.quantity) as most_ordered
from pizzas p 
join order_details od 
on p.pizza_id=od.pizza_id
group by p.size
order by most_ordered desc
limit 1;

-- Q5:List the top 5 most ordered pizza_types along with their quantities.
select pt.name, 
sum(od.quantity) as quantity 
from pizza_types pt join pizzas p 
on pt.pizza_type_id = p.pizza_type_id 
join order_details od 
on od.pizza_id = p.pizza_id
group by pt.name
order by quantity desc
limit 5;

-- Q6: Join the necessary tables to find the total quantity of each pizza category ordered.
select pt.category,sum(od.quantity) as total_quantity 
from pizza_types pt
join pizzas p 
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on od.pizza_id=p.pizza_id
group by pt.category
order by total_quantity desc;

-- Q7: Determine the distribution of orders by hour of the day.
select hour(order_time) as hour,
count(order_id) as quantity
from orders
group by hour
order by quantity desc;

-- Q8: Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) as distribution 
from pizza_types
group by category
order by distribution;

-- Q9: Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),2) as avg_quantity from
(select o.order_date as date,
sum(od.quantity) as quantity
from orders o 
join order_details od
on o.order_id=od.order_id
group by date) as per_day_qty;

-- Q10: Calculate the percentage contribution of each pizza type to total revenue.
select pt.name as pizza_type,
round(sum((p.price)*(od.quantity)),2) as revenue
from pizza_types pt 
join pizzas p
on p.pizza_type_id = pt.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pizza_type
order by revenue desc 
limit 3;

-- Q 11: Calculate the percentage contribution of each pizza type to total revenue.
select pt.category as pizza_category,
concat(round(sum((p.price)*(od.quantity)) / 
(select round(sum((p.price)*(od.quantity)),2)
from pizza_types pt 
join pizzas p
on p.pizza_type_id = pt.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id)*100,2),'%') as revenue
from pizza_types pt 
join pizzas p
on p.pizza_type_id = pt.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pizza_category;


-- Q12: Analyze the cumulative revenue generated over time.
select date, 
sum(revenue) over(order by date) as cum_revenue
from
(select o.order_date as date,
round(sum((p.price)*(od.quantity)),2) as revenue
from order_details od
join pizzas p
on p.pizza_id = od.pizza_id
join orders o
on o.order_id = od.order_id
group by o.order_date) as sales;

-- Q13: Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, 
name as most_ordered_pizza_type, 
revenue from
(select category,name,revenue,
rank()over(partition by category order by revenue desc) as rn
from
(select pt.category,pt.name,
round(sum((p.price)*(od.quantity)),2) as revenue
from pizza_types pt 
join pizzas p
on p.pizza_type_id = pt.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by pt.category,pt.name) x) y
where y.rn<=3; 
















