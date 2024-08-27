-- ### A. Pizza Metrics
-- 1. How many pizzas were ordered?
    SELECT count(*)
    FROM 2_customer_orders 

-- 2. How many unique customer orders were made?
    SELECT COUNT(DISTINCT(co.order_id)) unique_customer_order
    FROM 2_customer_orders co
    
-- 3. How many successful orders were delivered by each runner?
    SELECT
    ro.runner_id, COUNT(DISTINCT ro.runner_id) delivery_order
    FROM 2_customer_orders co
    INNER JOIN 2_runner_orders ro ON co.order_id = ro.order_id
    WHERE pickup_time <> 'null'
    GROUP BY ro.runner_id

-- 4. How many of each type of pizza was delivered?
    SELECT
    pn.pizza_name, 
    COUNT(pn.pizza_id) pizza_delivered
    FROM 2_customer_orders co
    INNER JOIN 2_runner_orders ro ON co.order_id = ro.order_id
    INNER JOIN 2_pizza_names pn ON co.pizza_id = pn.pizza_id
    WHERE pickup_time <> 'null'
    GROUP BY pn.pizza_name

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
    SELECT
    co.customer_id,
    pn.pizza_name, 
    COUNT(pn.pizza_id) pizza_ordered
    FROM 2_customer_orders co
    INNER JOIN 2_pizza_names pn ON co.pizza_id = pn.pizza_id
    GROUP BY pn.pizza_name, co.customer_id
    
-- 6. What was the maximum number of pizzas delivered in a single order?
    SELECT
    co.order_id,
    pickup_time,
    COUNT(co.order_id) maximum_order
    FROM 2_customer_orders co
    INNER JOIN 2_runner_orders ro ON ro.order_id = co.order_id
    WHERE ro.pickup_time != 'null' 
    GROUP BY co.order_id, pickup_time
    ORDER BY maximum_order DESC
    LIMIT 1
-- 6. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- 7. How many pizzas were delivered that had both exclusions and extras?
-- 8. What was the total volume of pizzas ordered for each hour of the day?
-- 9. What was the volume of orders for each day of the week?