--Q1: What is the total amount each customer spent at the restaurant?
SELECT 
        customer_id, 
        SUM(price) AS total_price
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
GROUP BY customer_id

--Q2: How many days has each customer visited the restaurant?
SELECT 
        customer_id, 
        COUNT(DISTINCT order_date) AS visited_days
FROM dbo.sales
GROUP BY customer_id

--Q3: What was the first item from the menu purchased by each customer?
SELECT 
        customer_id, 
        order_date, 
        product_name
FROM dbo.menu AS m
JOIN dbo.sales AS s
ON s.product_id = m.product_id
GROUP BY 
        customer_id,
        order_date,
        product_name
HAVING 
        order_date = '2021-01-01'

--Q4: What is the most purchased item on the menu and how many times was it purchased by all customers?
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

--Q5: Which item was the most popular for each customer?
WITH cte_order_count AS (
  SELECT
    s.customer_id,
    m.product_name,
    COUNT(*) AS order_count,
    RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) AS rank
  FROM dbo.sales as s
  JOIN dbo.menu as m
  ON s.product_id = m.product_id
  GROUP BY 
    customer_id,
    product_name
)
SELECT * FROM cte_order_count
WHERE rank = 1;

--Q6: Which item was purchased first by the customer after they became a member?
WITH CTE AS (
    SELECT 
        S.customer_id,
        product_name,
        order_date,
        RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) AS RANK
    FROM SALES as S
    JOIN MENU as M on S.product_id = M.product_id
    JOIN MEMBERS as MEM ON MEM.customer_id = S.customer_id 
    WHERE order_date >= join_date
)
SELECT *
FROM CTE
WHERE RANK = 1;

--Q7: Which item was purchased just before the customer became a member?
WITH CTE AS (
    SELECT 
        S.customer_id,
        product_name,
        order_date,
        RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) AS RANK
    FROM SALES as S
    JOIN MENU as M on S.product_id = M.product_id
    JOIN MEMBERS as MEM ON MEM.customer_id = S.customer_id 
    WHERE order_date < join_date
)
SELECT *
FROM CTE
WHERE RANK = 1;

--Q8: What is the total items and amount spent for each member before they became a member?
SELECT 
        s.customer_id,
        COUNT(m.product_id) AS total_item,
        SUM(price) AS amount_spent
FROM SALES as S
JOIN MENU as M on S.product_id = M.product_id
JOIN MEMBERS as MEM ON MEM.customer_id = S.customer_id 
WHERE order_date < join_date
GROUP BY S.customer_id;

--Q9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
--How many points would each customer have?
SELECT
        S.customer_id,
        SUM(
            CASE WHEN product_name = 'sushi' then price * 10 * 2 
            ELSE price * 10 END
        ) AS points
FROM sales as S
JOIN menu AS M ON S.product_id = M.product_id
GROUP BY S.customer_id;

--Q10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
--How many points do customer A and B have at the end of January?
SELECT 
        S.customer_id, 
        SUM(
            CASE WHEN product_name = 'sushi' 
            OR order_date BETWEEN CAST(join_date as datetime) AND DATEADD(day, 6, CAST(join_date as datetime)) 
            THEN price*10*2 
            ELSE price*10 END
        ) AS points
FROM sales AS S
JOIN menu AS M
ON S.product_id = M.product_id
LEFT JOIN members AS MEM
ON S.customer_id = MEM.customer_id
WHERE MONTH(order_date) = 1
GROUP BY S.customer_id;

-- Bonus Questions
-- Join All The Things

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
;
--Rank All The Things
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
SELECT 
        *,
        CASE WHEN members = 'N' THEN NULL
        ELSE RANK() OVER(PARTITION BY customer_id, members ORDER BY order_date)  
        END AS ranking
FROM cte
ORDER BY 
        customer_id,
        order_date,
        product_name,
        price