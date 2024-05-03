/*    Measure KPI's    */

# 1. Total revenue generated from pizza sales ?

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
    
# 2. Total number of Orders placed ?

SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders; 
    
    
# 3. Average Order Value.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price) / COUNT(DISTINCT order_id),
            2) AS Avg_order_value
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
    
# 4. Total number of pizzas sold ?

SELECT 
    SUM(quantity) AS Total_pizzas_sold
FROM
    order_details;    
    
    
    
# 5. Average pizzas per Order.

SELECT 
    ROUND(SUM(quantity) / COUNT(DISTINCT order_id),
            2) AS Avg_pizzas_per_order
FROM
    order_details;
    
    
# 6. Total Quantity sold from each pizza category ?

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category;



/*    Seasonal Trend    */


# 1. Find peak time hours based on Total Orders ?

SELECT 
    COUNT(order_id) AS orders, HOUR(order_time) AS hours
FROM
    orders
GROUP BY hours
ORDER BY orders DESC;


# 2. Average number of pizzas ordered per day ?

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date) AS qunatity_ordered;
    
 
 # 3. Order trend based on Days.
 
 SELECT 
    DAYNAME(order_date) AS day,
    COUNT(order_id) AS Total_orders
FROM
    orders
GROUP BY day
ORDER BY Total_orders DESC;


# 4. Order trend based on Months.

SELECT 
    MONTHNAME(order_date) AS month,
    COUNT(order_id) AS Total_orders
FROM
    orders
GROUP BY month
ORDER BY Total_orders DESC;


# 5. Quarter-wise sales ?

SELECT 
    QUARTER(order_date) as Quarter, ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN
	orders ON orders.order_id = order_details.order_id
GROUP BY
	Quarter;
    
    
 # 6. Cumulative revenue generated over time.
 
SELECT
order_date, sum(revenue) OVER (order by order_date)  as cum_revenue
FROM
	(SELECT orders.order_date, round(sum(order_details.quantity*pizzas.price),0) as revenue
FROM orders
	JOIN order_details
ON orders.order_id = order_details.order_id
	JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
	GROUP BY order_date) as Total_sales;


/*    Product Popularity    */


# 1. Category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS pizzas
FROM
    pizza_types
GROUP BY category
ORDER BY pizzas DESC;


# 2. Most expensive pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;


# 3. Top 5 best selling pizza based on Total Orders ?

SELECT 
    pizza_types.name,
    COUNT(DISTINCT order_details.order_id) AS Orders
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Orders DESC
LIMIT 5;    


# 4. Top 3 pizzas based on sales for each pizza category ?

SELECT 
	category, name, revenue
FROM
(SELECT
	category, name, revenue, RANK() OVER (PARTITION BY category ORDER BY revenue DESC) as rnk
FROM
(SELECT
 pizza_types.category, pizza_types.name, round(sum(order_details.quantity*pizzas.price),0) as revenue
FROM
  pizza_types
	JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
	JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) as a) as b
WHERE rnk <= 3 ;

# 5. Percentage of sales by pizza category.

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price) AS Total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS Total_sales_percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;


# 6. Percentage of sales by pizza size.

SELECT 
    pizzas.size,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price) AS Total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS Total_sales_percentage
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size;
    
    
    
    