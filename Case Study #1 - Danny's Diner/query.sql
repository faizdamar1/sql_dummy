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

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
	SELECT m.product_name, COUNT(s.order_date) orders
	FROM 1_sales s
	INNER JOIN 1_menu m ON s.product_id = m.product_id
	GROUP BY m.product_name
	ORDER BY COUNT(s.order_date) DESC
	LIMIT 1

-- 5. Which item was the most popular for each customer?
	WITH CTE AS (
		SELECT 
		m.product_name,
		s.customer_id, 
		COUNT(s.order_date) orders,
		RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) as rnk,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) as rn
		FROM 1_sales s
		INNER JOIN 1_menu m ON s.product_id = m.product_id
		GROUP BY 
			m.product_name,
			s.customer_id
	)
	SELECT *
	FROM CTE
	WHERE rnk = 1

-- 6. Which item was purchased first by the customer after they became a member?
	WITH CTE AS (
		SELECT
			s.customer_id,
			s.order_date,
			s.product_id,
			m.join_date,
			me.product_name,
		RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) as rnk,
		ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY order_date) as rn
		FROM 1_sales s 
		INNER JOIN 1_members m ON s.customer_id = m.customer_id
		INNER JOIN 1_menu me ON s.product_id = me.product_id
		WHERE order_date >= join_date
	)
	SELECT *
	FROM CTE
	WHERE rnk = 1 

-- 7. Which item was purchased just before the customer became a member?
			WITH CTE AS (
		SELECT
			s.customer_id,
			s.order_date,
			s.product_id,
			m.join_date,
			me.product_name,
		RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) as rnk,
		ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) as rn
		FROM 1_sales s 
		INNER JOIN 1_members m ON s.customer_id = m.customer_id
		INNER JOIN 1_menu me ON s.product_id = me.product_id
		WHERE order_date < join_date
	)
	SELECT
		customer_id, product_name
	FROM CTE
	WHERE rnk = 1 

-- 8. What is the total items and amount spent for each member before they became a member?
	SELECT
		s.customer_id,
		COUNT(me.product_name) total_items,
		SUM(me.price) amount_spent
	FROM 1_sales s 
	INNER JOIN 1_members m ON s.customer_id = m.customer_id
	INNER JOIN 1_menu me ON s.product_id = me.product_id
	WHERE order_date >= join_date
	GROUP BY s.customer_id

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- --1. how many points would each customer have?
	SELECT
		s.customer_id ,
		SUM(
			CASE
			WHEN product_name = 'sushi' THEN price *10 *2
			ELSE  price *10
			END 
		) as points
	FROM `1_menu` m 
	INNER JOIN `1_sales` s ON m.product_id = s.product_id 
	GROUP BY s.customer_id 


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- -- how many points do customer A and B have at the end of January?
-- -- step 1
	SELECT
		s.customer_id,
		CASE
			WHEN s.order_date BETWEEN m2.join_date AND DATE_ADD(m2.join_date, INTERVAL 6 DAY) THEN price * 10 * 2
			WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
			ELSE m.price * 10
		END AS points,
		s.order_date,
		m2.join_date AS offer_start,
		DATE_ADD(m2.join_date, INTERVAL 6 DAY) AS offer_end
	FROM `1_menu` m
	INNER JOIN `1_sales` s ON m.product_id = s.product_id
	INNER JOIN `1_members` m2 ON m2.customer_id = s.customer_id;

-- -- step 2
	SELECT
		s.customer_id,
		SUM(CASE
			WHEN s.order_date BETWEEN m2.join_date AND DATE_ADD(m2.join_date, INTERVAL 7 DAY) AND m.product_name = 'sushi' THEN m.price * 10 * 2
			WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
			ELSE m.price * 10
		END) AS points,
		s.order_date,
		m2.join_date AS offer_start,
		DATE_ADD(m2.join_date, INTERVAL 6 DAY) AS offer_end
	FROM `1_menu` m
	INNER JOIN `1_sales` s ON m.product_id = s.product_id
	INNER JOIN `1_members` m2 ON m2.customer_id = s.customer_id
	WHERE DATE_FORMAT(s.order_date, '%Y-%m-01') = '2021-01-01'
	GROUP BY s.customer_id 
	
	-- done
