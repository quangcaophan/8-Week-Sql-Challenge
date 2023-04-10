# 8-Week SQL Challenge
![Star Badge](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=style=flat&color=BC4E99)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-971901?)](https://github.com/quangcaophan/8-Week-SQL-Challenge)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/quangcaophan?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/quangcaophan)

# 🍕 Case Study #2 - Pizza Runner


## 📕 Table Of Contents
  - 🛠️ [Problem Statement](#problem-statement)
  - 📂 [Dataset](#dataset)
  - ♻️ [Data Preprocessing](#️-data-preprocessing)
  - 🚀 [Solutions](#-solutions)

---

## 🛠️ Problem Statement

> Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”
> 
> Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so **Pizza Runner** was launched!
> 
> Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/127271531-0b4da8c7-8b24-4a14-9093-0795c4fa037e.png)

---

## 📂 Dataset
Danny has shared with you 6 key datasets for this case study:

### **```runners```**
<details>
<summary>
View table
</summary>

The runners table shows the **```registration_date```** for each new runner.


|runner_id|registration_date|
|---------|-----------------|
|1        |1/1/2021         |
|2        |1/3/2021         |
|3        |1/8/2021         |
|4        |1/15/2021        |

</details>


### **```customer_orders```**

<details>
<summary>
View table
</summary>

Customer pizza orders are captured in the **```customer_orders```** table with 1 row for each individual pizza that is part of the order.

|order_id|customer_id|pizza_id|exclusions|extras|order_time        |
|--------|-----------|--------|----------|------|------------------|
|1       |101        |1       |          |      |44197.75349537037 |
|2       |101        |1       |          |      |44197.79226851852 |
|3       |102        |1       |          |      |44198.9940162037  |
|3       |102        |2       |          |null  |44198.9940162037  |
|4       |103        |1       |4         |      |44200.558171296296|
|4       |103        |1       |4         |      |44200.558171296296|
|4       |103        |2       |4         |      |44200.558171296296|
|5       |104        |1       |null      |1     |44204.87533564815 |
|6       |101        |2       |null      |null  |44204.877233796295|
|7       |105        |2       |null      |1     |44204.88922453704 |
|8       |102        |1       |null      |null  |44205.99621527778 |
|9       |103        |1       |4         |1, 5  |44206.47429398148 |
|10      |104        |1       |null      |null  |44207.77417824074 |
|10      |104        |1       |2, 6      |1, 4  |44207.77417824074 |

</details>

### **```runner_orders```**

<details>
<summary>
View table
</summary>

After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer.

The **```pickup_time```** is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. 

The **```distance```** and **```duration```** fields are related to how far and long the runner had to travel to deliver the order to the respective customer.



|order_id|runner_id|pickup_time    |distance  |duration  |cancellation           |
|--------|---------|---------------|----------|----------|-----------------------|
|1       |1        |1/1/2021 18:15 |20km      |32 minutes|                       |
|2       |1        |1/1/2021 19:10 |20km      |27 minutes|                       |
|3       |1        |1/3/2021 0:12  |13.4km    |20 mins   |*null*                 |
|4       |2        |1/4/2021 13:53 |23.4      |40        |*null*                 |
|5       |3        |1/8/2021 21:10 |10        |15        |*null*                 |
|6       |3        |null           |null      |null      |Restaurant Cancellation|
|7       |2        |1/8/2020 21:30 |25km      |25mins    |null                   |
|8       |2        |1/10/2020 0:15 |23.4 km   |15 minute |null                   |
|9       |2        |null           |null      |null      |Customer Cancellation  |
|10      |1        |1/11/2020 18:50|10km      |10minutes |null                   |

</details>

### **```pizza_names```**

<details>
<summary>
View table
</summary>

|pizza_id|pizza_name |
|--------|-----------|
|1       |Meat Lovers|
|2       |Vegetarian |

</details>

### **```pizza_recipes```**

<details>
<summary>
View table
</summary>

Each **```pizza_id```** has a standard set of **```toppings```** which are used as part of the pizza recipe.


|pizza_id|toppings               |
|--------|-----------------------|
|1       |1, 2, 3, 4, 5, 6, 8, 10| 
|2       |4, 6, 7, 9, 11, 12     | 

</details>

### **```pizza_toppings```**

<details>
<summary>
View table
</summary>

This table contains all of the **```topping_name```** values with their corresponding **```topping_id```** value.


|topping_id|topping_name|
|----------|------------|
|1         |Bacon       | 
|2         |BBQ Sauce   | 
|3         |Beef        |  
|4         |Cheese      |  
|5         |Chicken     |     
|6         |Mushrooms   |  
|7         |Onions      |     
|8         |Pepperoni   | 
|9         |Peppers     |   
|10        |Salami      | 
|11        |Tomatoes    | 
|12        |Tomato Sauce|

</details>

---

## ♻️ Data Preprocessing

### **Data Issues**

Data issues in the existing schema include:

* **```customer_orders``` table**
  - ```null``` values entered as text
  - using both ```NaN``` and ```null``` values
* **```runner_orders``` table**
  - ```null``` values entered as text
  - using both ```NaN``` and ```null``` values
  - units manually entered in ```distance``` and ```duration``` columns

### **Data Cleaning**

**```customer_orders```**

Cleaning customer_orders
- Identify records with null or 'null' values
- Updating null or 'null' values to ''
- Blanks '' are not null because it indicates the customer asked for no extras or exclusions
- Saving the transformations in a temporary table

**```runner_orders```**

- pickup time, distance, duration is of the wrong type
- Records have nulls in these columns when the orders are cancelled
- Convert text 'null' to null values
- Units (km, minutes) need to be removed from distance and duration
- Saving the transformations in a temporary table


**Result:**

<details>
<summary> 
updated_customer_orders
</summary>

|order_id|customer_id|pizza_id|exclusions|extras|order_time              |
|--------|-----------|--------|----------|------|------------------------|
|1       |101        |1       |          |      |2020-01-01T18:05:02.000Z|
|2       |101        |1       |          |      |2020-01-01T19:00:52.000Z|
|3       |102        |1       |          |      |2020-01-02T12:51:23.000Z|
|3       |102        |2       |          |      |2020-01-02T12:51:23.000Z|
|4       |103        |1       |4         |      |2020-01-04T13:23:46.000Z|
|4       |103        |1       |4         |      |2020-01-04T13:23:46.000Z|
|4       |103        |2       |4         |      |2020-01-04T13:23:46.000Z|
|5       |104        |1       |          |1     |2020-01-08T21:00:29.000Z|
|6       |101        |2       |          |      |2020-01-08T21:03:13.000Z|
|7       |105        |2       |          |1     |2020-01-08T21:20:29.000Z|
|8       |102        |1       |          |      |2020-01-09T23:54:33.000Z|
|9       |103        |1       |4         |1, 5  |2020-01-10T11:22:59.000Z|
|10      |104        |1       |          |      |2020-01-11T18:34:49.000Z|
|10      |104        |1       |2, 6      |1, 4  |2020-01-11T18:34:49.000Z|

</details>

<details>
<summary> 
updated_runner_orders
</summary>

| order_id | runner_id | pickup_time         | distance | duration | cancellation            |
|----------|-----------|---------------------|----------|----------|-------------------------|
| 1        | 1         | 2020-01-01 18:15:34 | 20       | 32       |                         |
| 2        | 1         | 2020-01-01 19:10:54 | 20       | 27       |                         |
| 3        | 1         | 2020-01-02 00:12:37 | 13.4     | 20       |                         |
| 4        | 2         | 2020-01-04 13:53:03 | 23.4     | 40       |                         |
| 5        | 3         | 2020-01-08 21:10:57 | 10       | 15       |                         |
| 6        | 3         |                     |          |          | Restaurant Cancellation |
| 7        | 2         | 2020-01-08 21:30:45 | 25       | 25       |                         |
| 8        | 2         | 2020-01-10 00:15:02 | 23.4     | 15       |                         |
| 9        | 2         |                     |          |          | Customer Cancellation   |
| 10       | 1         | 2020-01-11 18:50:20 | 10       | 10       |                         |

</details>

---

## 🚀 Solutions

<details>
<summary> 
Pizza Metrics
</summary>

## 🧙‍♂️ Case Study Questions
1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

  
### **Q1. How many pizzas were ordered?**
```sql
SELECT
    COUNT(*) AS pizza_count
FROM
    customer_orders;
```
|pizza_count|
|-----------|
|14         |

### **Q2. How many unique customer orders were made?**
```sql
SELECT
    COUNT(DISTINCT order_id) AS order_count
FROM
    customer_orders;
```
|order_count|
|-----------|
|10         |


### **Q3. How many successful orders were delivered by each runner?**
```sql
SELECT
    runner_id,
    COUNT(DISTINCT order_id) AS successful_order
FROM
    runner_orders
WHERE
    pickup_time != 'null'
GROUP BY
    runner_id;
```

| runner_id | successful_orders |
|-----------|-------------------|
| 1         | 4                 |
| 2         | 3                 |
| 3         | 1                 |


### **Q4. How many of each type of pizza was delivered?**
```SQL
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
```

| pizza_name | delivered_pizzas |
|------------|------------------|
| Meatlovers | 9                |
| Vegetarian | 3                |


### **Q5. How many Vegetarian and Meatlovers were ordered by each customer?**
```SQL
SELECT
  customer_id,
  SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS meat_lovers,
  SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS vegetarian
FROM 
    updated_customer_orders
GROUP BY 
    customer_id;
```

| customer_id | meat_lovers | vegetarian |
|-------------|-------------|------------|
| 101         | 2           | 1          |
| 103         | 3           | 1          |
| 104         | 3           | 0          |
| 105         | 0           | 1          |
| 102         | 2           | 1          |

### **Q6. What was the maximum number of pizzas delivered in a single order?**
```SQL
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
 ``` 

| order_id  |ordered_pizzas|
|-----------|--------------|
| 4         | 3            |


### **Q7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**
```SQL
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
```

| customer_id | changes | no_change |
|-------------|---------|-----------|
| 101         | 0       | 2         |
| 102         | 0       | 3         |
| 103         | 3       | 0         |
| 104         | 2       | 1         |
| 105         | 1       | 0         |


### **Q8. How many pizzas were delivered that had both exclusions and extras?**
```SQL
SELECT SUM(CASE
               WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
               ELSE 0
           END) AS pizza_count_w_exclusions_extras
FROM updated_customer_orders AS c
         JOIN updated_runner_orders AS r ON c.order_id = r.order_id
WHERE exclusions != ''
  AND extras != ''
  AND distance > 1;
```  

| pizza_count_w_exclusions_extras |
|-------------|
| 1           |


### **Q9. What was the total volume of pizzas ordered for each hour of the day?**
```SQL
SELECT
    DATEPART(HOUR,order_time) AS hour_of_day,
    COUNT(order_id) AS pizza_count
FROM 
    updated_customer_orders
GROUP BY 
    DATEPART(HOUR,order_time);
```

| hour_of_day | pizza_count |
|-------------|-------------|
| 11          | 1           |
| 13          | 3           |
| 18          | 3           |
| 19          | 1           |
| 21          | 3           |
| 23          | 3           |

### **Q10. What was the volume of orders for each day of the week?**
```SQL
SELECT FORMAT(DATEADD(DAY, 2, order_time), 'dddd') AS hour_of_day,
       COUNT(order_id) AS total_pizzas_ordered
FROM updated_customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time), 'dddd');
```

| day_of_week | pizza_count |
|-------------|-------------|
| Friday      | 5           |
| Saturday    | 3           |
| Monday      | 5           |
| Sunday      | 1           |

</details>

<details>
<summary>
Runner and Customer Experience
</summary>

### **Q1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**
```SQL
SELECT 
    DATEPART(week, registration_date) AS registration_week,
    COUNT(runner_id) AS runner_signed
FROM runners
GROUP BY DATEPART(week, registration_date);
```
| registration_week | runner_signed |
|-------------------|---------------|
| 1                 | 1             |
| 2                 | 2             |
| 3                 | 1             |

### **Q2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```SQL 
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
```
| AVG |
|-----|
| 16  |

### **Q3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```SQL
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
```
| pizza_order | AVG |
|-------------|-----|
| 1           | 12  |
| 2           | 18  |
| 3           | 30  |


### **Q4. What was the average distance travelled for each customer?**
```SQL
SELECT 
  c.customer_id, 
  ROUND(AVG(r.distance),2) AS avg_distance
FROM updated_customer_orders AS c
JOIN updated_runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.duration != 0
GROUP BY c.customer_id;
```
| pizza_customer_idorder | avg_distance |
|-------------|---------|
| 101         | 20      |
| 102         | 16.73   |
| 103         | 23.4    |
| 104         | 10      |
| 105         | 25      |


### **Q5. What was the difference between the longest and shortest delivery times for all orders?**
```SQL
SELECT 
    MAX(duration) - MIN(duration) AS delivery_time_difference
FROM updated_runner_orders
WHERE duration != 0;
```
| delivery_time_difference |
|-----|
| 30  |


### **Q6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**
```SQL
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
```
| runner_id | order_id | pizza_count| distance| avg_speed|
|-----------|----------|------------|---------|----------|
| 1         | 1        | 1          | 20      | 37.5     |
| 1         | 2        | 1          | 20      | 44.44    |
| 1         | 3        | 2          | 13.4    | 4.02     |
| 2         | 4        | 3          | 23.4    | 35.1     |
| 3         | 5        | 1          | 10      | 40       |
| 2         | 7        | 1          | 25      | 60       |
| 2         | 8        | 1          | 23.4    | 93.6     |
| 1         | 10       | 2          | 10      | 60       |


### **Q7. What is the successful delivery percentage for each runner?**
```SQL
SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance = 0 THEN 0
    ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM updated_runner_orders
GROUP BY runner_id;
```
| runner_id | success_perc |
|-----------|--------------|
| 1         | 100          |
| 2         | 75           |
| 3         | 50           |

