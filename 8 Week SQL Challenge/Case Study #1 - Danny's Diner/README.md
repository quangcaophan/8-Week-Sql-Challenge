# 8-Week SQL Challenge
![Star Badge](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=style=flat&color=BC4E99)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-971901?)](https://github.com/quangcaophan/8-Week-SQL-Challenge)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/quangcaophan?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/quangcaophan)

# 🍜 Case Study #1 - Danny's Diner

## 📕 Table Of Contents
* 🛠️ [Problem Statement](#problem-statement)
* 📂 [Dataset](#dataset)
* 🧙‍♂️ [Case Study Questions](#case-study-questions)
* 🚀 [Solutions](#solutions)
  
---

## 🛠️ Problem Statement

> Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

 <br /> 

---

## 📂 Dataset
Danny has shared with you 3 key datasets for this case study:

### **```sales```**

<details>
<summary>
View table
</summary>

The sales table captures all ```customer_id``` level purchases with an corresponding ```order_date``` and ```product_id``` information for when and what menu items were ordered.

|customer_id|order_date|product_id|
|-----------|----------|----------|
|A          |2021-01-01|1         |
|A          |2021-01-01|2         |
|A          |2021-01-07|2         |
|A          |2021-01-10|3         |
|A          |2021-01-11|3         |
|A          |2021-01-11|3         |
|B          |2021-01-01|2         |
|B          |2021-01-02|2         |
|B          |2021-01-04|1         |
|B          |2021-01-11|1         |
|B          |2021-01-16|3         |
|B          |2021-02-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-07|3         |

 </details>

### **```menu```**

<details>
<summary>
View table
</summary>

The menu table maps the ```product_id``` to the actual ```product_name``` and price of each menu item.

|product_id |product_name|price     |
|-----------|------------|----------|
|1          |sushi       |10        |
|2          |curry       |15        |
|3          |ramen       |12        |

</details>

### **```members```**

<details>
<summary>
View table
</summary>

The final members table captures the ```join_date``` when a ```customer_id``` joined the beta version of the Danny’s Diner loyalty program.

|customer_id|join_date |
|-----------|----------|
|A          |1/7/2021  |
|B          |1/9/2021  |

 </details>

## 🧙‍♂️ Case Study Questions

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

 <br /> 

## 🚀 Solutions

### **Q1. What is the total amount each customer spent at the restaurant?**
```sql
SELECT 
        customer_id, 
        SUM(price) AS total_price
FROM dbo.sales AS S
JOIN dbo.menu AS M
ON S.product_id = M.product_id
GROUP BY customer_id;
```

| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

---

### **Q2. How many days has each customer visited the restaurant?**
```sql
SELECT 
        customer_id, 
        COUNT(DISTINCT order_date) AS visited_days
FROM dbo.sales
GROUP BY customer_id;
```

|customer_id|visited_days|
|-----------|------------|
|A          |4           |
|B          |6           |
|C          |2           |


---

### **Q3. What was the first item from the menu purchased by each customer?**
```sql
SELECT 
        customer_id, 
        order_date, 
        product_name
FROM dbo.menu AS M
JOIN dbo.sales AS S
ON S.product_id = M.product_id
GROUP BY 
        customer_id,
        order_date,
        product_name
HAVING order_date = '2021-01-01';
```

**Result:**
| customer_id | order_date   | product_name|
| ----------- | ------------ | ----------  |
| A           | 2021-01-01   | curry       |
| A           | 2021-01-01   | sushi       |
| B           | 2021-01-01   | curry       |
| C           | 2021-01-01   | ramen       |

---

### **Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
```sql
SELECT 
        TOP 1
        s.product_id,  
        product_name,
        COUNT(product_name) AS order_count
FROM dbo.menu AS m
JOIN dbo.sales AS s
ON s.product_id = m.product_id
GROUP BY 
        s.product_id,
        product_name
ORDER BY 3 DESC;
```

|product_id|product_name|order_count|
|----------|------------|-----------|
|3         |ramen       |8          |

---

### **Q5. Which item was the most popular for each customer?**
```sql
WITH CTE AS (
  SELECT 
        product_name, 
        customer_id, 
        COUNT(order_date) as orders,
        RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) as rnk
  FROM SALES as S
  JOIN MENU as M on S.product_id = M.product_id 
  GROUP BY 
         product_name, 
         customer_id
)
SELECT 
        customer_id,
        product_name
FROM CTE
WHERE rnk = 1;
```
|customer_id|product_name|
|-----------|------------|
| A         |ramen       |
| B         |curry       |
| B         |ramen       |
| B         |sushi       |
| C         |ramen       |

---

### **Q6. Which item was purchased first by the customer after they became a member?**
```sql
WITH CTE AS (
    SELECT 
        S.customer_id,
        product_name,
        order_date,
        RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) AS purchase_order
    FROM SALES as S
    JOIN MENU as M on S.product_id = M.product_id
    JOIN MEMBERS as MEM ON MEM.customer_id = S.customer_id 
    WHERE order_date >= join_date
)
SELECT *
FROM CTE
WHERE RANK = 1;
```

| customer_id | product_name | order_date | purchase_order |
| ----------- | ------------ | -----------| -------------- |
| A           | curry        | 2021-01-07 | 1              |
| B           | sushi        | 2021-01-11 | 1              |

---

### **Q7. Which item was purchased just before the customer became a member?**

```sql
WITH CTE AS (
    SELECT 
        S.customer_id,
        product_name,
        order_date,
        RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) AS purchase_order
    FROM SALES as S
    JOIN MENU as M on S.product_id = M.product_id
    JOIN MEMBERS as MEM ON MEM.customer_id = S.customer_id 
    WHERE order_date < join_date
)
SELECT *
FROM CTE
WHERE purchase_order = 1;
```

| customer_id | product_name | order_date | purchase_order |
| ----------- | ------------ | -----------| -------------- |
| A           | sushi        | 2021-01-01 | 1              |
| A           | curry        | 2021-01-01 | 1              |
| B           | curry        | 2021-01-01 | 1              |

---

### **Q8. What is the total items and amount spent for each member before they became a member?**
```sql
SELECT 
        s.customer_id,
        COUNT(m.product_id) AS total_item,
        SUM(price) AS amount_spent
FROM SALES as S
JOIN MENU as M on S.product_id = M.product_id
JOIN MEMBERS as MEM ON MEM.customer_id = S.customer_id 
WHERE order_date < join_date
GROUP BY S.customer_id;
```

| customer_id | total_items | total_spent |
| ----------- | ----------- | ----------- |
| A           | 2           | 25          |
| B           | 3           | 40          |


---

### **Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```sql
SELECT
        S.customer_id,
        SUM(
            CASE WHEN product_name = 'sushi' then price * 10 * 2 
            ELSE price * 10 END
        ) AS points
FROM sales as S
JOIN menu AS M ON S.product_id = M.product_id
GROUP BY S.customer_id;
```

| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |

---

### **Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
```sql
SELECT 
      S.customer_id, 
      SUM(
          CASE WHEN S.order_date BETWEEN MEM.join_date AND DATEADD(day, 6, MEM.join_date) THEN price * 10 * 2 
               WHEN product_name = 'sushi' THEN price * 10 * 2 
               ELSE price * 10 END
      ) AS points
FROM MENU AS M
JOIN SALES AS S ON S.product_id = M.product_id
JOIN MEMBERS AS MEM ON MEM.customer_id = S.customer_id
WHERE 
      DATEPART(month, S.order_date) = DATEPART(month, '2021-01-01') AND 
      DATEPART(year, S.order_date) = DATEPART(year, '2021-01-01')
GROUP BY S.customer_id;
```
| customer_id | total_points |
| ----------- | ------------ |
| A           | 1370         |
| B           | 820          |

## BONUS QUESTIONS 

**1. JOIN ALL THINGS**
```sql
SELECT 
        S.customer_id,
        order_date,
        product_name,
        price,
        CASE WHEN order_date < join_date THEN 'N'
             WHEN join_date IS NULL THEN 'N' 
             ELSE 'Y' END AS members
FROM sales AS S
JOIN menu AS M ON S.product_id = M.product_id
FULL JOIN members AS MEM ON S.customer_id = MEM.customer_id
ORDER BY 
        customer_id,
        order_date,
        product_name,
        price
```

| cutomer_id     |  order_date   |  product_name   | price   |	member   |
| -------------- | ------------- | --------------- | ------- | --------- |
| A              |   2021-01-01  |     sushi       |  10     |    N      |
| A              |   2021-01-01  |     curry       |  15     |    N      |
| A              |   2021-01-07  |     curry       |  15     |    Y      |
| A              |   2021-01-10  |     ramen       |  12     |    Y      |
| A              |   2021-01-11  |     ramen       |  12     |    Y      |
| A              |   2021-01-11  |     ramen       |  12     |    Y      |
| B              |   2021-01-01  |     curry       |  15     |    N      |
| B              |   2021-01-02  |     curry       |  15     |    N      |
| B              |   2021-01-04  |     sushi       |  10     |    N      |
| B              |   2021-01-11  |     sushi       |  10     |    Y      |
| B              |   2021-01-16  |     ramen       |  12     |    Y      |
| B              |   2021-02-01  |     ramen       |  12     |    Y      |
| C              |   2021-01-01  |     ramen       |  12     |    N      |
| C              |   2021-01-01  |     ramen       |  12     |    N      |
| C              |   2021-01-07  |     ramen       |  12     |    N      |

---

**2. Rank All The Things**
```sql
WITH cte AS (
    SELECT 
            S.customer_id,
            order_date,
            product_name,
            price,
            CASE WHEN order_date < join_date THEN 'N'
                WHEN join_date IS NULL THEN 'N' 
                ELSE 'Y' END AS members
    FROM sales AS S
    JOIN menu AS M ON S.product_id = M.product_id
    LEFT JOIN members AS MEM ON S.customer_id = MEM.customer_id
            )
SELECT *,
       CASE WHEN members = 'N' THEN NULL
       ELSE RANK() OVER(PARTITION BY customer_id, members ORDER BY order_date)  
       END AS ranking
FROM cte
ORDER BY 
        customer_id,
        order_date,
        product_name,
        price
```

| customer_id    | order_date    | product_name    | price   |	member   |	ranking   |
| ---            |  ---          |     ---         |  ---    | ---       | ---        |
| A              |   2021-01-01  |     sushi       |  10     |    N      |   NULL     |
| A              |   2021-01-01  |     curry       |  15     |    N      |   NULL     |
| A              |   2021-01-07  |     curry       |  15     |    Y      |    1       |
| A              |   2021-01-10  |     ramen       |  12     |    Y      |    2       |
| A              |   2021-01-11  |     ramen       |  12     |    Y      |    3       |
| A              |   2021-01-11  |     ramen       |  12     |    Y      |    3       |
| B              |   2021-01-01  |     curry       |  15     |    N      |   NULL     |
| B              |   2021-01-02  |     curry       |  15     |    N      |   NULL     |
| B              |   2021-01-04  |     sushi       |  10     |    N      |   NULL     |
| B              |   2021-01-11  |     sushi       |  10     |    Y      |    1       |
| B              |   2021-01-16  |     ramen       |  12     |    Y      |    2       |
| B              |   2021-02-01  |     ramen       |  12     |    Y      |    3       |
| C              |   2021-01-01  |     ramen       |  12     |    N      |   NULL     |
| C              |   2021-01-01  |     ramen       |  12     |    N      |   NULL     |
| C              |   2021-01-07  |     ramen       |  12     |    N      |   NULL     |

---

