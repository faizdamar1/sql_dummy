-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) total_amount
FROM 1_sales s
INNER JOIN 1_menu as m ON s.product_id = m.product_id
GROUP BY s.customer_id

-- 2. How many days has each customer visited the restaurant?
SELECT s.customer_id, COUNT(DISTINCT s.order_date) days
FROM 1_sales s
GROUP BY s.customer_id

-- 3. What was the first item from the menu purchased by each customer?

-- option 1
WITH CTE as (
	SELECT s.customer_id, s.order_date, m.product_name,
	RANK() OVER(PARTITION BY customer_id ORDER BY order_date ASC) rnk,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date ASC) rn
	FROM 1_sales s
	INNER JOIN 1_menu as m ON s.product_id = m.product_id
)
SELECT 
	customer_id, 
	product_name, 
	order_date
FROM CTE
WHERE rn = 1 

-- option 2
SELECT customer_id, product_name, first_order
FROM 1_menu m
INNER JOIN (
	SELECT s.customer_id, MIN(s.order_date) first_order, MIN(s.product_id) product_id
	FROM 1_sales s
	GROUP BY s.customer_id
) fo ON m.product_id = fo.product_id