/* --------------------
   Table Transformation
   --------------------*/
SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'customer_orders';


SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'runner_orders';

--Update tables

--1. customer_order
/*
Cleaning customer_orders
- Identify records with null or 'null' values
- updating null or 'null' values to ''
- blanks '' are not null because it indicates the customer asked for no extras or exclusions
*/
--Blanks indicate that the customer requested no extras/exclusions for the pizza, whereas null values would be ambiguous on this.


DROP TABLE IF EXISTS updated_customer_orders;

SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE WHEN exclusions IS NULL OR exclusions = 'null' THEN '' ELSE exclusions END AS exclusions,
    CASE WHEN extras IS NULL OR extras = 'null' THEN '' ELSE extras END AS extras,
    order_time
INTO 
    updated_customer_orders
FROM 
    customer_orders;

--2. runner_orders
/*
- pickup time, distance, duration is of the wrong type
- records have nulls in these columns when the orders are cancelled
- convert text 'null' to null values
- units (km, minutes) need to be removed from distance and duration
*/

DROP TABLE IF EXISTS updated_runner_orders;
SELECT
    order_id,
    runner_id,
    REPLACE(pickup_time, 'null','') AS pickup_time,
    CAST(REPLACE(ISNULL(NULLIF(distance, 'null'), ''), 'km', '') AS float) AS distance,
    ISNULL(CAST(NULLIF(REPLACE(REPLACE(REPLACE(duration, 'mins', ''), 'minutes', ''),'minute',''), 'null') AS int), 0) AS duration,
    REPLACE(cancellation,'null','') as Cancellation
INTO 
    updated_runner_orders
FROM 
    runner_orders;



--How many pizzas were ordered?
SELECT
    COUNT(*) AS pizza_count
FROM
    customer_orders;


--How many unique customer orders were made?
SELECT
    COUNT(DISTINCT order_id) AS order_count
FROM
    customer_orders;


--How many successful orders were delivered by each runner?
SELECT
    runner_id,
    COUNT(DISTINCT order_id) AS successful_order
FROM
    runner_orders
WHERE
    pickup_time <> 'null'
GROUP BY
    runner_id;


--How many of each type of pizza was delivered?
SELECT
    pizza_name,
    COUNT(co.order_id) AS delivered_pizzas
FROM
    pizza_names AS pn
    INNER JOIN customer_orders AS co ON pn.pizza_id = co.pizza_id
    INNER JOIN runner_orders AS ro ON ro.order_id = co.order_id
WHERE
    pickup_time <> 'null'
GROUP BY
    pizza_name;


--How many Vegetarian and Meatlovers were ordered by each customer?
SELECT TOP 1
    order_id,
    COUNT(co.order_id) AS ordered_pizzas
FROM
    customer_orders AS co
    INNER JOIN pizza_names AS pn ON co.pizza_id = pn.pizza_id
GROUP BY
    order_id
ORDER BY
    COUNT(co.order_id) DESC;


--What was the maximum number of pizzas delivered in a single order?
SELECT TOP 1
  order_id,  
  COUNT(co.order_id) as ordered_pizzas 
FROM 
  customer_orders as co 
  INNER JOIN pizza_names as pn on co.pizza_id = pn.pizza_id 
GROUP BY  
  order_id
ORDER BY 
    COUNT(co.order_id) DESC;


--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
    c.customer_id,
    SUM(CASE WHEN c.exclusions != '' OR c.extras != '' THEN 1 ELSE 0 END) AS change,
    SUM(CASE WHEN c.exclusions = '' AND c.extras = '' THEN 1 ELSE 0 END) AS no_change
FROM 
    updated_customer_orders AS c
JOIN 
    updated_runner_orders AS r ON c.order_id = r.order_id
WHERE 
    r.distance != 0
GROUP BY 
    c.customer_id
ORDER BY 
    c.customer_id;


--How many pizzas were delivered that had both exclusions and extras?
SELECT 
    SUM(CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE 0 END) AS pizza_count_w_exclusions_extras
FROM 
    updated_customer_orders AS c
JOIN 
    updated_runner_orders AS r ON c.order_id = r.order_id
WHERE 
    exclusions != '' 
    AND extras != '' 
    AND distance > 1;


--What was the total volume of pizzas ordered for each hour of the day?
SELECT
    DATEPART(HOUR,order_time) AS hour_of_day,
    COUNT(order_id) AS pizza_count
FROM 
    updated_customer_orders
GROUP BY 
    DATEPART(HOUR,order_time);


--What was the volume of orders for each day of the week?
SELECT
    FORMAT(DATEADD(DAY,2,order_time),'dddd') AS day_of_week,
    COUNT(order_id) AS total_pizzas_ordered
FROM 
    updated_customer_orders
GROUP BY 
    FORMAT(DATEADD(DAY,2,order_time),'dddd');

