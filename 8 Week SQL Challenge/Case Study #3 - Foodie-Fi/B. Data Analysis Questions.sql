-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS unique_customer
FROM subscriptions;


-- 2.What is the monthly distribution of trial plan start_date values for our dataset use the start of the month as the group by value
SELECT 
    DATEPART(month, start_date) AS month,
    COUNT(*) AS trial_subscription
FROM plans AS p 
JOIN subscriptions AS s
    ON p.plan_id = s.plan_id
WHERE p.plan_name = 'trial'
GROUP BY DATEPART(month, start_date);


-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.
SELECT plan_id, COUNT(*)
FROM foodie_fi.subscriptions
WHERE start_date > '2020-01-01'
GROUP BY plan_id
ORDER BY plan_id;


--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT 
    COUNT(*) AS churn_count,
    COUNT(*) * 100 / (
        SELECT COUNT(DISTINCT customer_id)
        FROM subscriptions
    ) AS churn_percentage
FROM plans AS p 
JOIN subscriptions AS s
    ON p.plan_id = s.plan_id
WHERE plan_name = 'churn';


-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
-- To find ranking of the plans by customers and plans
WITH ranking AS (
    SELECT 
        s.customer_id, 
        s.plan_id, 
        p.plan_name,
        -- Run a ROW_NUMBER() to rank the plans from 0 to 4
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.plan_id) AS plan_rank 
    FROM subscriptions AS s
    JOIN plans AS p
        ON s.plan_id = p.plan_id
)
SELECT 
    COUNT(*) AS churn_count,
    ROUND(100 * COUNT(*) / (
        SELECT COUNT(DISTINCT customer_id) 
        FROM subscriptions
    ), 0) AS churn_percentage
FROM ranking
WHERE plan_id = 4 -- Filter to churn plan
    AND plan_rank = 2; -- Filter to rank 2 as customers who churned immediately after trial have churn plan ranked as 2


-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH next_plan_cte AS (
    SELECT 
        customer_id, 
        plan_id, 
        LEAD(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY plan_id) AS next_plan
    FROM subscriptions
)
SELECT 
    next_plan, 
    COUNT(*) AS conversions,
    ROUND(100 * COUNT(*) / (
        SELECT COUNT(DISTINCT customer_id) 
        FROM subscriptions
    ), 1) AS conversion_percentage
FROM next_plan_cte
WHERE next_plan IS NOT NULL 
    AND plan_id = 0
GROUP BY next_plan
ORDER BY next_plan;


--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
-- To retrieve next plan's start date located in the next row based on current row
WITH next_plan AS (
    SELECT 
        customer_id, 
        plan_id, 
        start_date,
        LEAD(start_date, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_date
    FROM subscriptions
    WHERE start_date <= '2020-12-31'
),
-- To find breakdown of customers with existing plans on or after 2020-12-31
customer_breakdown AS (
    SELECT 
        plan_id, 
        COUNT(DISTINCT customer_id) AS customers
    FROM next_plan
    WHERE (next_date IS NOT NULL AND (start_date < '2020-12-31' AND next_date > '2020-12-31')) 
        OR (next_date IS NULL AND start_date < '2020-12-31')
    GROUP BY plan_id
)
SELECT plan_id, customers, 
    ROUND(100 * customers / (
        SELECT COUNT(DISTINCT customer_id) 
        FROM subscriptions
    ), 1) AS percentage
FROM customer_breakdown
GROUP BY plan_id, customers
ORDER BY plan_id;


--8. How many customers have upgraded to an annual plan in 2020?
SELECT 
    COUNT(DISTINCT customer_id) AS unique_customer
FROM subscriptions
WHERE plan_id = 3
    AND start_date <= '2020-12-31';


-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
-- Filter results to customers at trial plan = 0
WITH trial_plan AS (
    SELECT 
        customer_id, 
        start_date AS trial_date
    FROM subscriptions
    WHERE plan_id = 0
),
-- Filter results to customers at pro annual plan = 3
annual_plan AS (
    SELECT 
        customer_id, 
        start_date AS annual_date
    FROM subscriptions
    WHERE plan_id = 3
)
SELECT 
    AVG(DATEDIFF(day, trial_date, annual_date)) AS avg_days_to_upgrade
FROM trial_plan AS tp
JOIN annual_plan AS ap
    ON tp.customer_id = ap.customer_id;


--10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
-- Filter results to customers at trial plan = 0
WITH trial_plan AS (
    SELECT 
        customer_id, 
        start_date AS trial_date
    FROM subscriptions
    WHERE plan_id = 0
),
-- Filter results to customers at pro annual plan = 3
annual_plan AS (
    SELECT 
        customer_id, 
        start_date AS annual_date
    FROM subscriptions
    WHERE plan_id = 3
),
-- Sort values above in buckets of 12 with range of 30 days each
bins AS (
    SELECT 
        (DATEDIFF(day, trial_date, annual_date) / 30) + 1 AS avg_days_to_upgrade
    FROM trial_plan AS tp
    JOIN annual_plan AS ap
        ON tp.customer_id = ap.customer_id
)
SELECT 
    CONCAT(((avg_days_to_upgrade - 1) * 30), ' - ', (avg_days_to_upgrade * 30), ' days') AS breakdown, 
    COUNT(*) AS customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;


-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
-- To retrieve next plan's start date located in the next row based on current row
WITH next_plan_cte AS (
    SELECT 
        customer_id, 
        plan_id, 
        start_date,
        LEAD(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY plan_id) AS next_plan
    FROM subscriptions
)
SELECT 
    COUNT(*) AS downgraded
FROM next_plan_cte
WHERE start_date <= '2020-12-31'
    AND plan_id = 2 
    AND next_plan = 1;
