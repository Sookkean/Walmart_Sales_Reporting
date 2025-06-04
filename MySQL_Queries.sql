Use walmart_db;
SELECT * FROM walmart;
-- Business Problems
-- Q1. Find different payment method and number of transactions, number of qty sold
SELECT payment_method, count(*) as total_transaction, SUM(quantity) as total_quantity
FROM walmart 
GROUP BY payment_method;

-- Q2. Identify the highest-rated category in each branch, displaying the branch, category 
SELECT * 
FROM 
(	SELECT branch, category, AVG(rating) as avg_rating, RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as ranking1
	FROM walmart
	GROUP BY 1, 2
	ORDER BY 1,3 DESC
) as ranked
WHERE ranking1 = 1;

-- Q3. Identify the busiest day for each branch based on the number of transactions
SELECT *
FROM
(	SELECT  branch, 
			DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) as day_name, 
            count(*) as no_transactions, 
            rank() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as ranking2
		FROM walmart
	GROUP BY 1,2
) as ranked2
WHERE ranking2 =1;

-- Q4. Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
SELECT payment_method, SUM(quantity) as total_quantity
FROM walmart
GROUP BY payment_method;

-- Q5. Determine the average, minimum and maximum rating of category for each city
SELECT city, category, min(rating), max(rating), round(avg(rating),2)
FROM walmart
GROUP BY 1,2;

-- Q6. Calculate the total profit for each category by considering total_profit(unit_price * quantity * profit_margin)
SELECT category, ROUND(SUM(total), 2) as total_revenue, ROUND(SUM(total * profit_margin),2) as total_profit
FROM walmart
GROUP BY category;

-- Q7. Determine the most common payment method for each branch.
with cte
AS
(SELECT branch, payment_method, count(*) as total_trans, RANK() OVER(PARTITION BY branch ORDER BY count(*) DESC) as ranking3
FROM walmart
GROUP BY 1,2
) 
SELECT *
FROM cte
WHERE ranking3 =1;

-- Q8. Categorize sales into 3 group MORNING, AFTERNOON, EVENING
SELECT 
  branch,
  CASE 
    WHEN HOUR(time) < 12 THEN 'Morning'
    WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS day_time,
  COUNT(*) AS total_transactions
FROM walmart
GROUP BY branch, day_time
ORDER BY 1,3 DESC;

-- Q9

-- 2022 sales
WITH revenue_2022 AS (
  SELECT 
    branch, 
    SUM(total) AS revenue
  FROM walmart
  WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
  GROUP BY branch
),
revenue_2023 AS (
  SELECT 
    branch, 
    SUM(total) AS revenue
  FROM walmart
  WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
  GROUP BY branch
)
SELECT ls.branch, ls.revenue as last_year_revenue, cs.revenue as current_year_revenue, round(((ls.revenue - cs.revenue)/ls.revenue) *100,2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN revenue_2023 as cs
ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5