

/*---------------------------------------------------use database-------------------------------------------------------------*/
use pizza_data;
CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

/*-------------------------------------------------------------- Queries----------------------------------------------------------------*/

/*------------------Retrieve the total number of orders placed----------------------*/

SELECT 
    COUNT(order_id) AS total_order
FROM
    orders;

/*------------------The total revenue generated from pizza sales.--------------------*/
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS TS
FROM
    order_details
        INNER JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

/*------------------The highest-priced pizza.--------------------------*/

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1; 

/*------------------The most common pizza size ordered------------------*/
SELECT 
    pizzas.size, COUNT(order_details.order_details_id) AS oredr
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY COUNT(order_details.order_details_id) DESC
LIMIT 1;

/*---------------Top 5 most ordered pizza types along with their quantities------------------*/

SELECT 
    pizza_types.name AS names,
    SUM(order_details.quantity) AS total
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY names
ORDER BY total DESC
LIMIT 5;

/*----------Join the necessary tables to find the total quantity of each pizza category ordered.*/

SELECT 
    e2.category, SUM(e1.quantity) as total_Q
FROM
    pizza_types e2
        INNER JOIN
    pizzas e3 ON e3.pizza_type_id = e2.pizza_type_id
        INNER JOIN
    order_details e1 ON e1.pizza_id = e3.pizza_id
GROUP BY e2.category;

/*-------Determine the distribution of orders by hour of the day.*/

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS count_order
FROM
    orders
GROUP BY hour;

/*------Category-wise distribution of pizzas.*/

SELECT 
    category, COUNT(name) AS total_pizza
FROM
    pizza_types
GROUP BY category
ORDER BY total_pizza DESC;

/*------Group the orders by date and calculate the average number of pizzas ordered per day.*/

SELECT 
    ROUND(AVG(quantity_sum), 2) AS avg_ordered_pizzas
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS quantity_sum
    FROM
        orders
    INNER JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS per_day_order;

/*----_----Determine the top 3 most ordered pizza types based on revenue.*/

SELECT 
    E1.name, SUM(E2.quantity * E3.price) AS revenue
FROM
    pizza_types E1
        INNER JOIN
    pizzas E3 ON E3.pizza_type_id = E1.pizza_type_id
        INNER JOIN
    order_details E2 ON E2.pizza_id = E3.pizza_id
GROUP BY E1.name
ORDER BY revenue DESC
LIMIT 3;

/*-------Percentage contribution of each pizza type to total revenue.  */

SELECT 
    pizza_types.category,
    ROUND(SUM(pizzas.price * order_details.quantity) / (SELECT 
                    SUM(pizzas.price * quantity) AS total_revenue
                FROM
                    pizzas
                        INNER JOIN
                    order_details ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS pizza_revenue
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY (pizza_types.category)
ORDER BY pizza_revenue DESC;

/*---------Cumulative revenue generated over time.*/

SELECT order_date, ROUND(SUM(revenue) OVER(ORDER BY order_date),2) AS cumulative_revenue
FROM
(SELECT E2.order_date, SUM(E1.quantity*E3.price) AS revenue                            
FROM order_details E1
INNER JOIN pizzas E3
ON E1.pizza_id=E3.pizza_id
INNER JOIN orders E2
ON E2.order_id=E1.order_id
GROUP BY E2.order_date) AS date_wise_revenue
ORDER BY cumulative_revenue DESC;

/*--------Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/

SELECT category, name, revenue FROM
(SELECT category, name, revenue, RANK () OVER(PARTITION BY category ORDER BY revenue DESC) AS rank_cate
FROM 
(SELECT pizza_types.category, pizza_types.name,
SUM(order_details.quantity*pizzas.price) AS revenue
FROM pizza_types 
INNER JOIN pizzas 
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
INNER JOIN order_details
ON order_details.pizza_id=pizzas.pizza_id
GROUP BY  pizza_types.category, pizza_types.name) AS category_name) AS rank_table
WHERE rank_cate<=3;   

