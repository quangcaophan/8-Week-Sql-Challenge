# 8-Week SQL Challenge
![Star Badge](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=style=flat&color=BC4E99)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-971901?)](https://github.com/quangcaophan/8-Week-SQL-Challenge)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/quangcaophan?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/quangcaophan)

# 🥑 Case Study #3 - Foodie-Fi

## 📕 Table Of Contents
* 🛠️ [Problem Statement](#problem-statement)
* 📂 [Dataset](#dataset)
* 🧙‍♂️ [Case Study Questions](#case-study-questions)
* 🚀 [Solutions](#solutions)
  
---

## 🛠️ Problem Statement

Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

## 📂 Dataset
Danny has shared with you 2 key datasets for this case study:

### **```plans```**

<details>
<summary>
View table
</summary>

The plan table shows which plans customer can choose to join Foodie-Fi when they first sign up.

* **Trial:** can sign up to an initial 7 day free trial will automatically continue with the pro monthly subscription plan unless they cancel

* **Basic plan:** limited access and can only stream user videos
* **Pro plan** no watch time limits and video are downloadable with 2 subscription options: **monthly** and **annually**


| "plan_id" | "plan_name"     | "price" |
|-----------|-----------------|---------|
| 0         | "trial"         | 0.00    |
| 1         | "basic monthly" | 9.90    |
| 2         | "pro monthly"   | 19.90   |
| 3         | "pro annual"    | 199.00  |
| 4         | "churn"         | NULL    |


</details>


### **```subscriptions```**


<details>
<summary>
View table
</summary>

Customer subscriptions show the exact date where their specific ```plan_id``` starts.

If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the ```start_date``` in the ```subscriptions``` table will reflect the date that the actual plan changes.

In this part, I will display the first 20 rows of this dataset since the original one is super long:


| "customer_id" | "plan_id" | "start_date" |
|---------------|-----------|--------------|
| 1             | 0         | "2020-08-01" |
| 1             | 1         | "2020-08-08" |
| 2             | 0         | "2020-09-20" |
| 2             | 3         | "2020-09-27" |
| 3             | 0         | "2020-01-13" |
| 3             | 1         | "2020-01-20" |
| 4             | 0         | "2020-01-17" |
| 4             | 1         | "2020-01-24" |
| 4             | 4         | "2020-04-21" |
| 5             | 0         | "2020-08-03" |
| 5             | 1         | "2020-08-10" |
| 6             | 0         | "2020-12-23" |
| 6             | 1         | "2020-12-30" |
| 6             | 4         | "2021-02-26" |
| 7             | 0         | "2020-02-05" |
| 7             | 1         | "2020-02-12" |
| 7             | 2         | "2020-05-22" |
| 8             | 0         | "2020-06-11" |
| 8             | 1         | "2020-06-18" |
| 8             | 2         | "2020-08-03" |


</details>


## 🧙‍♂️ Case Study Questions

1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of **```trial```** plan **```start_date```** values for our dataset - use the start of the month as the group by value
3. What plan **```start_date```** values occur after the year 2020 for our dataset? Show the breakdown by count of events for each **```plan_name```**
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 **```plan_name```** values at **```2020-12-31```**?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

## 🚀 Solutions

**1. How many customers has Foodie-Fi ever had?**

To find the number of Foodie-Fi's unique customers, I use `DISTINCT` and wrap `COUNT` around it.

````sql
SELECT 
  COUNT(DISTINCT customer_id) AS unique_customer
FROM foodie_fi.subscriptions;
````

**Answer:**

| total_customers |
|-------------------|
| 1000              |

- Foodie-Fi has 1,000 unique customers.

---

**2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value**

Question is asking for the monthly numbers of users on trial plan.
- I extract numerical month using `DATE_PART`.
- `DATE_PART` is used to extract numerical values from a date
- Filter for `trial` for trial plans.

````sql
SELECT 
    DATEPART(month, start_date) AS month,
    COUNT(*) AS trial_subscription
FROM plans AS p 
JOIN subscriptions AS s
  ON p.plan_id = s.plan_id
WHERE p.plan_name = 'trial'
GROUP BY DATEPART(month, start_date);
````

**Answer:**

months | trial_subscription 
-------|-------
   1 |    88
   2 |    68
   3 |    94
   4 |    81
   5 |    88
   6 |    79
   7 |    89
   8 |    88
   9 |    87
  10 |    79
  11 |    75
  12 |    84

- March has the highest number of trial plans, whereas February has the lowest number of trial plans.

---

**3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.**
Question is asking for the number of plans for start dates occurring on 1 Jan 2021 and after grouped by plan names.
- Filter plans with start_dates occurring on 2021–01–01 and after.
- Group and order results by plan.

_Note: Question calls for events occuring after 1 Jan 2021, however I ran the query for events in 2020 as well as I was curious with the year-on-year results._

````sql
SELECT 
  s.plan_id,
  p.plan_name,
  SUM(
    CASE WHEN s.start_date <= '2020-12-31' THEN 1
    ELSE 0 END) AS events_2020,
  SUM(
    CASE WHEN s.start_date >= '2021-01-01' THEN 1
    ELSE 0 END) AS events_2021
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id
GROUP BY s.plan_id, p.plan_name
ORDER BY s.plan_id;
````

**Answer:**

plan_id | plan_name   | events_2020|events_2021
--------|-------------|------------|-----------
0       |trial        |	1000       |	0
1       |basic monthly|	538        |	8
2       |pro monthly  |	479        |	60
3       |pro annual   |	195        |	63
4       |	churn     |	236        |	71

- There were 0 customer on trial plan in 2021. Does it mean that there were no new customers in 2021, or did they jumped on basic monthly plan without going through the 7-week trial?
- We should also look at the data and look at the customer proportion for 2020 and 2021.

---

**Q4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**

I like to write down the steps and breakdown the questions into parts.

**Steps:**
- Find the number of customers who churned.
- Find the percentage of customers who churned and round it to 1 decimal place.
- Filter plan_name = 'churn'

````sql
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
````

**Answer:**

churn_count | churn_percentage 
-------------|-----------------
  307 |            30

- There are 307 customers who have churned, which is 30.7% of Foodie-Fi customer base.

---

**Q5. How many customers have churned straight after their initial free trial what percentage is this rounded to the nearest whole number?**

In order to identify which customer churned straight after the trial plan, I rank each customer's plans using a `ROW_NUMBER`. Remember to partition by unique customer.

My understanding is that if a customer churned immediately after trial, the plan ranking would look like this.

- Trial Plan - Rank 1
- Churned - Rank 2

Using the CTE, I filtered for `plan id = 4` (churn plan) and `rank = 2` (being customers who churned immediately after trial) and find the percentage of churned customers.

````sql
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
````

**Answer:**

  churn_count | churn_percentage 
 ----------------|-----------------
 92 |             9

- There are 92 customers who churned straight after the initial free trial which is at 9% of entire customer base.

---

**Q6. What is the number and percentage of customer plans after their initial free trial?**

Question is asking for number and percentage of customers who converted to becoming paid customer after the trial. 

**Steps:**
- Find customer's next plan which is located in the next row using `LEAD()`. Run the `next_plan_cte` separately to view the next plan results and understand how `LEAD()` works.
- Filter for `non-null next_plan`. Why? Because a next_plan with null values means that the customer has churned. 
- Filter for `plan_id = 0` as every customer has to start from the trial plan at 0.

````sql
-- To retrieve next plan's start date located in the next row based on current row
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

````
**Answer:**

next_plan|conversions|conversion_percentage
---------|-----------|---------------------
1|	546	|54
2|	325|32
3|	37|	3
4|	92|	9

- More than 80% of customers are on paid plans with small 3.7% on plan 3 (pro annual $199). Foodie-Fi has to strategize on their customer acquisition who would be willing to spend more.

---

**Q7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?**

````sql
-- To retrieve next plan's start date located in the next row based on current row
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


````

**Answer:**
plan_id|customers|percentage
-------|---------|----------
0|	19|	1
1|	224|	22
2|	326|	32
3|	195|	19
4|	235|	23

---

**8. How many customers have upgraded to an annual plan in 2020?**

````sql
SELECT 
    COUNT(DISTINCT customer_id) AS unique_customer
FROM subscriptions
WHERE plan_id = 3
    AND start_date <= '2020-12-31';
````

**Answer:**
|unique_customer |
|------|
|195 |


- 195 customers upgraded to an annual plan in 2020.

---

**Q9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**

````sql
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
````

**Answer:**
|avg_days_to_upgrade |
|------|
|104 |

- On average, it takes 104 days for a customer to upragde to an annual plan from the day they join Foodie-Fi.

---

**Q10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**

````sql
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
````

**Answer:**

|  breakdown   |customers|
|--------------|---------|
| 0-30         | 48      |
| 30-60        | 25      |
| 60-90        | 33      |
| 90-120       | 35      |
| 120-150      | 43      |
| 150-180      | 35      |
| 180-210      | 27      |
| 210-240      | 4       |
| 240-270      | 5       |
| 270-300      | 1       |
| 300-330      | 1       |
| 330-360      | 1       |

---

**Q11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?**

````sql
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
````

**Answer:**

|downgraded|
|----------|
| 0        |

- No customer has downgrade from pro monthly to basic monthly in 2020.
