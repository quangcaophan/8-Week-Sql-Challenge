
SELECT
  s.customer_id,
  f.plan_id, 
  f.plan_name,  
  s.start_date
FROM plans f
JOIN subscriptions s
  ON f.plan_id = s.plan_id
WHERE s.customer_id IN (1,2,11,13,15,16,18,19);

SELECT
  s.customer_id,
  f.plan_id, 
  f.plan_name,  
  s.start_date
FROM plans f
JOIN subscriptions s
  ON f.plan_id = s.plan_id
WHERE s.customer_id = 1;

SELECT
  s.customer_id,
  f.plan_id, 
  f.plan_name,  
  s.start_date
FROM plans f
JOIN subscriptions s
  ON f.plan_id = s.plan_id
WHERE s.customer_id = 13;

SELECT
  s.customer_id,
  f.plan_id, 
  f.plan_name,  
  s.start_date
FROM plans f
JOIN subscriptions s
  ON f.plan_id = s.plan_id
WHERE s.customer_id = 15;