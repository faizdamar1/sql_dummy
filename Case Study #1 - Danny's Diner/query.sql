-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) total_amount
FROM 1_sales s
INNER JOIN 1_menu as m ON s.product_id = m.product_id
GROUP BY s.customer_id

