--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
    DATEPART(week, registration_date) AS registration_week,
    COUNT(runner_id) AS runner_signed
FROM runners
GROUP BY DATEPART(week, registration_date);


--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH CTE AS (
    SELECT 
        c.order_id, 
        c.order_time, 
        r.pickup_time, 
        DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS pickup_minutes
    FROM updated_customer_orders AS c
    JOIN updated_runner_orders AS r
      ON c.order_id = r.order_id
    WHERE r.distance != 0
    GROUP BY c.order_id, c.order_time, r.pickup_time
)
SELECT AVG(pickup_minutes) AS AVG
FROM CTE
WHERE pickup_minutes > 1;


--Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH CTE AS (
    SELECT 
        c.order_id, 
        COUNT(c.order_id) AS pizza_order, 
        c.order_time, 
        r.pickup_time, 
        DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time_minutes
    FROM updated_customer_orders AS c
    JOIN updated_runner_orders AS r
      ON c.order_id = r.order_id
    WHERE r.distance != 0
    GROUP BY c.order_id, c.order_time, r.pickup_time
)
SELECT 
    pizza_order,
    AVG(prep_time_minutes) AS AVG
FROM CTE
GROUP BY pizza_order;


--What was the average distance travelled for each customer?
SELECT 
  c.customer_id, 
  ROUND(AVG(r.distance),2) AS avg_distance
FROM updated_customer_orders AS c
JOIN updated_runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.duration != 0
GROUP BY c.customer_id;


--What was the difference between the longest and shortest delivery times for all orders?
SELECT 
    MAX(duration) - MIN(duration) AS delivery_time_difference
FROM updated_runner_orders
WHERE duration != 0;


--What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
  runner_id,
  c.order_id,
  COUNT(c.order_id) as pizza_count,
  distance,
  ROUND((r.distance/r.duration*60), 2) AS avg_speed
FROM updated_runner_orders AS r
JOIN updated_customer_orders AS c
  ON r.order_id = c.order_id
WHERE distance != 0
GROUP BY r.runner_id, c.customer_id, c.order_id, r.distance, r.duration
ORDER BY c.order_id;


--What is the successful delivery percentage for each runner?
SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance = 0 THEN 0
    ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM updated_runner_orders
GROUP BY runner_id;