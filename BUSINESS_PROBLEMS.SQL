--EDA	

SELECT * FROM customers;
SELECT * FROM deliveries;
SELECT * FROM orders;
SELECT * FROM restaurants;
SELECT * FROM riders;

SELECT COUNT(*) FROM customers
WHERE 
	customer_id IS NULL
	OR 
	reg_date IS NULL;

SELECT COUNT(*) FROM restaurants
WHERE 
	restaurant_name IS NULL
	OR 
	opening_hours IS NULL;

SELECT * FROM orders;
SELECT COUNT(*) FROM orders
WHERE 
	order_item IS NULL
	OR 
	order_date IS NULL
	OR 
	order_time IS NULL
	OR 
	order_status IS NULL
	OR 
	total_amount IS NULL
	;


DELETE FROM orders
WHERE 
	order_item IS NULL
	OR 
	order_date IS NULL
	OR 
	order_time IS NULL
	OR 
	order_status IS NULL
	OR 
	total_amount IS NULL
	;
	
INSERT INTO orders(order_id,customer_id,restaurant_id)
VALUES 
(10002,9,54),
(10003,10,51),
(10005,10,50);

-- -----------------------
-- Analysis & Reports
-- -----------------------

-- Q.1
--Write a query to find the top 5 most frequently ordered dishes by a customer called 'Arjun Mehta' in the last one year 
-- 

SELECT * FROM orders;
SELECT * FROM customers;

SELECT * FROM 
(SELECT 
	ot.order_item ,
	COUNT(ot.order_id) AS total_orders,
	DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rank
FROM orders AS ot
JOIN customers as ct 
ON ct.customer_id=ot.customer_id
WHERE ct.customer_name='Arjun Mehta' AND
ot.order_date >= CURRENT_DATE - INTERVAL  '3 year'
GROUP BY 1 
ORDER BY total_orders DESC ) as t1
WHERE rank <5

--Q.2
--	Popular Time Slots for Orders
--Business Question: What are the most popular time slots (in 2-hour intervals) for placing orders?

SELECT * FROM orders;

SELECT 
	CASE 
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1  THEN '00:00- 02:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3  THEN '02:00- 04:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5  THEN '04:00- 06:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7  THEN '06:00- 08:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9  THEN '08:00- 10:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11  THEN '10:00- 12:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13  THEN '12:00- 14:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15  THEN '14:00- 16:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17  THEN '16:00- 18:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19  THEN '18:00- 20:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21  THEN '20:00- 22:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23  THEN '22:00- 24:00'
	END AS time_slot, 
	COUNT(order_id) as total_order
FROM orders
GROUP BY time_slot
order by total_order DESC

--METHOD TWO
SELECT 
	FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 AS start_slot,
	FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 +2 AS end_slot,
	COUNT(*)
FROM orders
GROUP BY 1,2
ORDER BY 3 DESC

--Average Order Value (AOV) for Frequent Customers
--Business Question: What is the average order value (AOV) for customers 
--who have placed more than 750 orders?

SELECT 
	customer_id,
	AVG(total_amount) as AOV,
	COUNT(order_id) as total_order
FROM orders
GROUP BY 1 
HAVING COUNT(order_id) > 750

-- 4. High-Value Customers
-- Question: List the customers who have spent more than 100K in total on food orders.
-- return customer_name, and customer_id!

SELECT 
	ot.customer_id,
	ct.customer_name,
	COUNT(ot.order_id) as total_order,
	SUM(total_amount) as total_spend
FROM orders AS ot
JOIN customers AS ct 
ON ct.customer_id=ot.customer_id
GROUP BY 1 ,2
HAVING SUM(total_amount)> 100000

-- 5. Orders Without Delivery
-- Question: Write a query to find orders that were placed but not delivered. 
-- Return each restuarant name, city and number of not delivered orders 
SELECT DISTINCT
	dt.delivery_status,
	rest_t.restaurant_id,
	rest_t.restaurant_name,
	rest_t.city,
	COUNT(delivery_id) as TOTAL_NOT_DELIVERED
FROM deliveries AS dt
JOIN riders AS rt
ON rt.rider_id=dt.rider_id
JOIN orders AS ot
ON ot.order_id=dt.order_id
JOIN restaurants AS rest_t
ON rest_t.restaurant_id=ot.restaurant_id
WHERE dt.delivery_status='Not Delivered'
GROUP BY 2,1,3,4 ;

-- Q. 6
-- Restaurant Revenue Ranking: 
-- Rank restaurants by their total revenue from the last year, including their name, 
-- total revenue, and rank within their city.
WITH ranking_table 
AS 	
(
	SELECT 
		rest_t.restaurant_name,
		rest_t.city,
		SUM(ot.total_amount),
		RANK() OVER(PARTITION BY rest_t.city ORDER BY SUM(ot.total_amount) DESC) AS rank
	FROM restaurants AS rest_t
	JOIN orders AS ot
	ON ot.restaurant_id= rest_t.restaurant_id
	WHERE ot.order_date > CURRENT_DATE - INTERVAL '3 years'
	GROUP BY 2,1
)

SELECT * FROM ranking_table 
WHERE rank=1

-- Q. 7
-- Most Popular Dish by City: 
-- Identify the most popular dish in each city based on the number of orders.
WITH dish_table 
AS 
(
	SELECT 
		ot.order_item,
		rt.city,
		COUNT(ot.order_id ) AS total_orders ,
		RANK() OVER(PARTITION BY rt.city ORDER BY COUNT(ot.order_id) DESC) AS rank
	FROM orders AS ot 
	JOIN restaurants AS rt 
	ON rt.restaurant_id=ot.restaurant_id
	GROUP BY 2,1
)
SELECT * FROM dish_table 
WHERE rank=1

-- Q.8 Customer Churn: 
-- Find customers who haven’t placed an order in 2024 but did in 2023.

-- find cx who has done orders in 2023
-- find cx who has not done orders in 2024
-- compare 1 and 2

SELECT DISTINCT customer_id FROM orders 
WHERE EXTRACT(YEAR FROM order_date) = 2023
	AND 
	customer_id NOT IN 
		 (SELECT DISTINCT customer_id FROM orders 
		  WHERE EXTRACT(YEAR FROM order_date) = 2024) 
		  

-- Q.9 Cancellation Rate Comparison: 
-- Calculate and compare the order cancellation rate for each restaurant between the 
-- current year and the previous year.

WITH cancle_ratio_23
AS 
(
SELECT 
	ot.restaurant_id,
	COUNT(ot.order_id) AS total_order,
	COUNT(CASE WHEN dt.delivery_id IS NULL THEN 1 END) AS not_delivered
FROM orders AS ot
LEFT JOIN deliveries AS dt
ON dt.order_id=ot.order_id
WHERE EXTRACT(YEAR FROM ot.order_date) = 2023
GROUP BY 1
),
cancle_ratio_24
AS 
(
SELECT 
	ot.restaurant_id,
	COUNT(ot.order_id) AS total_order,
	COUNT(CASE WHEN dt.delivery_id IS NULL THEN 1 END) AS not_delivered
FROM orders AS ot
LEFT JOIN deliveries AS dt
ON dt.order_id=ot.order_id
WHERE EXTRACT(YEAR FROM ot.order_date) = 2024
GROUP BY 1
),
current_year_data
AS(
SELECT 
	restaurant_id,
	total_order,
	not_delivered,
	ROUND(
		not_delivered::numeric/total_order::numeric * 100, 2) as cancel_ratio
FROM cancle_ratio_24
	),
last_year_data
AS(
SELECT 
	restaurant_id,
	total_order,
	not_delivered,
	ROUND(
		not_delivered::numeric/total_order::numeric * 100, 2) as cancel_ratio
FROM cancle_ratio_23
	)
SELECT 
    c.restaurant_id AS restaurant_id,
    c.cancel_ratio AS current_year_cancel_ratio,
    l.cancel_ratio AS last_year_cancel_ratio
FROM current_year_data AS c
JOIN last_year_data AS l
ON c.restaurant_id = l.restaurant_id;

-- Q.10 Rider Average Delivery Time: 
-- Determine each rider's average delivery time.

SELECT 
	rt.rider_name,
	-- ot.order_time,
	-- dt.delivery_time,
	ROUND(AVG(EXTRACT(EPOCH FROM (dt.delivery_time - ot.order_time + CASE WHEN dt.delivery_time < ot.order_time 
	THEN INTERVAL '1 day' ELSE INTERVAL '0 day' END ))/60),2) AS  avg_delivery_minutes
FROM riders AS rt
JOIN deliveries AS dt
ON dt.rider_id=rt.rider_id
JOIN orders AS ot
ON ot.order_id=dt.order_id
WHERE dt.delivery_time is not null
GROUP BY 1

-- Q.11 Monthly Restaurant Growth Ratio: 
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining

--Last month 10
--this month 15 -> 50% growth
-- this month - last month/ last month * 100
WITH growth_ratio
AS
(
SELECT 
	ot.restaurant_id,
	TO_CHAR(ot.order_date,'mm-yy') AS month,
	COUNT(ot.order_id) AS this_month,
	LAG(COUNT(ot.order_id),1)
	OVER(
		PARTITION BY ot.restaurant_id
		ORDER BY TO_CHAR(ot.order_date,'mm-yy')
	) AS previous_month
FROM orders AS ot
JOIN deliveries AS dt 
ON ot.order_id=dt.order_id
GROUP BY 1,2
ORDER BY 1,2
)
SELECT 
	*,
	ROUND(
		((this_month::numeric-previous_month::numeric)/previous_month::numeric) * 100 ,2)
		AS growth_ratio
		
FROM growth_ratio

-- Q.12 Customer Segmentation: 
-- Customer Segmentation: Segment customers into 'Gold' or 'Silver' groups based on their total spending 
-- compared to the average order value (AOV). If a customer's total spending exceeds the AOV, 
-- label them as 'Gold'; otherwise, label them as 'Silver'. Write an SQL query to determine each segment's 
-- total number of orders and total revenue

-- cx total spend
-- aov
-- gold
-- silver
-- each category and total orders and total rev` 

SELECT 
	cx_category,
	SUM(total_orders) AS total_orders,
	SUM(total_revenue) AS total_revenue
FROM(
	SELECT 
		customer_id,
		COUNT(order_id) AS total_orders,
		SUM(total_amount) AS total_revenue,
		CASE 
		WHEN SUM(total_amount) > (SELECT AVG(total_amount) FROM orders)
			THEN 'GOLD'
			ELSE 'SILVER' 
		END AS cx_category
	FROM orders 
	GROUP BY 1
	ORDER BY 1
)	AS t1
GROUP BY 1;

-- Q.13 Rider Monthly Earnings: 
-- Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.

SELECT 
	dt.rider_id,
	TO_CHAR(ot.order_date, 'mm-yy') AS month,
	SUM(ot.total_amount) / 100 * 8 AS total_earning
FROM deliveries AS dt
JOIN orders AS ot
ON ot.order_id = dt.order_id
GROUP BY 1,2
ORDER BY 1,2


-- Q.14 Rider Ratings Analysis: 
-- Find the number of 5-star, 4-star, and 3-star ratings each rider has.
-- riders receive this rating based on delivery time.
-- If orders are delivered less than 15 minutes of order received time the rider get 5 star rating,
-- if they deliver 15 and 20 minute they get 4 star rating 
-- if they deliver after 20 minute they get 3 star rating.
SELECT 
	rider_id,
	rating,
	COUNT(rating) as number_of 
FROM(
	SELECT 
		rider_id,
		order_time,
		delivery_time,
		CASE 
		WHEN time_gap <  15 THEN ' 5 star'
		WHEN time_gap BETWEEN 15 AND 20 THEN '4 star'
		ELSE '3 star'
		END AS RATING
	FROM(
		SELECT 
			dt.rider_id AS rider_id,
			ot.order_time AS order_time,
			dt.delivery_time AS delivery_time,
			EXTRACT(EPOCH FROM (dt.delivery_time - ot.order_time)  +
				CASE 
				WHEN dt.delivery_time < ot.order_time THEN INTERVAL '1 day'
				ELSE INTERVAL '0 day' 
				END) /60 AS time_gap
		FROM deliveries AS dt
		JOIN orders AS ot
		ON ot.order_id = dt.order_id
		WHERE dt.delivery_time is NOT NULL
		GROUP BY 1,2,3
	)AS t1
	) AS t2
GROUP BY 1,2
ORDER BY 1;


-- Q.16 Customer Lifetime Value (CLV): 
-- Calculate the total revenue generated by each customer over all their orders.

SELECT 
	customer_id,
	SUM(total_amount)
FROM orders
GROUP BY 1
ORDER BY 1;

-- Q.17 Monthly Sales Trends: 
-- Identify sales trends by comparing each month's total sales to the previous month.

SELECT 
	EXTRACT(YEAR FROM order_date) as year,
	EXTRACT(MONTH FROM order_date) as month,
	SUM(total_amount) as total_sale,
	LAG(SUM(total_amount), 1) OVER(ORDER BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)) as prev_month_sale
FROM orders
GROUP BY 1, 2

-- Q.18 Rider Efficiency: 
-- Evaluate rider efficiency by determining average delivery times 
--and identifying those with the lowest and highest averages.
WITH new_table
AS 
(
	SELECT 
		d.rider_id AS rider_id,
		EXTRACT (EPOCH FROM (d.delivery_time - o.order_time +
				CASE 
					WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
					ELSE INTERVAL '0 day'
				END )) /60
				AS time_gap
	FROM orders AS o
	JOIN deliveries AS d 
	ON d.order_id= o.order_id
	WHERE d.delivery_status='Delivered'
) ,
time_avg
as(
	SELECT 
		rider_id,
		AVG(time_gap) AS avg_time
	FROM new_table 
	GROUP BY 1
)
SELECT 
	MIN(avg_time),
	MAX(avg_time)
FROM time_avg


-- Q.19 Order Item Popularity: 
-- Track the popularity of specific order items over time and identify seasonal demand spikes.
WITH season_track
AS
(
	SELECT 
		order_item,
		EXTRACT(MONTH FROM order_date) AS months,
		CASE 
			WHEN EXTRACT(MONTH FROM order_date) BETWEEN 4 AND 6 THEN 'SPRING'
			WHEN EXTRACT(MONTH FROM order_date) BETWEEN 6 AND 9 THEN 'SUMMER'
			ELSE 'WINTER'
		END AS seasons
	FROM orders
)
SELECT 
	order_item,
	COUNT(order_item) as total_order,
	seasons
FROM season_track
GROUP BY 1,3
ORDER BY 1,2 DESC;

-- Q.20 Rank each city based on the total revenue for last year 2023 
SELECT 
	r.city AS city,
	SUM(o.total_amount) AS total_revenue,
	RANK() OVER(ORDER BY SUM(o.total_amount) DESC) AS rank
FROM orders AS o
JOIN restaurants AS r
ON r.restaurant_id=o.restaurant_id
GROUP BY 1;

-- End of Analysis & Reports