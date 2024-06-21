/*
Q #1: 
*/


SELECT state,
       COUNT(DISTINCT customer_id) 
FROM customers
GROUP BY state;

/*
 Q #2: 
*/

WITH completed_orders AS (
    SELECT *
    FROM orders
    WHERE status = 'Complete'
),
clean_customers AS (
    SELECT *,
           CASE 
               WHEN state LIKE '%US State%' THEN 'California'
               ELSE state
           END AS clean_state
    FROM customers
)
SELECT clean_state,
       COUNT(DISTINCT order_id) AS total_completed_orders
FROM completed_orders
INNER JOIN clean_customers ON clean_customers.customer_id = completed_orders.user_id
GROUP BY clean_state;

/*
Q #3: 
*/


WITH orders_clean AS (
    SELECT orders.*, 
           CASE 
               WHEN customers.state = 'US State' THEN 'California'
               WHEN customers.state IS NULL THEN 'Missing data'
               ELSE customers.state
           END AS clean_state
    FROM orders
    LEFT JOIN customers ON orders.user_id = customers.customer_id
),
nike_complete AS (
    SELECT DISTINCT order_id
    FROM order_items
),
vintage_complete AS (
    SELECT DISTINCT order_id
    FROM order_items_vintage
)
SELECT clean_state,
       COUNT(DISTINCT orders_clean.order_id) AS total_complete_orders,
       COUNT(DISTINCT nike_complete.order_id) AS official_completed_orders,
       COUNT(DISTINCT vintage_complete.order_id) AS vintage_completed_orders
FROM orders_clean
LEFT JOIN nike_complete ON nike_complete.order_id = orders_clean.order_id
LEFT JOIN vintage_complete ON vintage_complete.order_id = orders_clean.order_id
WHERE orders_clean.status = 'Complete'
GROUP BY clean_state
ORDER BY clean_state;

     

/*
Q #4: 
*/
WITH temp_table AS (
    SELECT CASE 
               WHEN customers.state = 'US State' THEN 'California'
               WHEN customers.state IS NULL THEN 'Missing Data'
               ELSE customers.state
           END AS cleaned_state, 
           SUM(order_items.sale_price) AS total_revenue, 
           COUNT(order_items.returned_at) AS returned_items
    FROM order_items
    FULL JOIN customers ON customers.customer_id = order_items.user_id
    GROUP BY cleaned_state
    UNION ALL
    SELECT CASE 
               WHEN customers.state = 'US State' THEN 'California'
               WHEN customers.state IS NULL THEN 'Missing Data'
               ELSE customers.state
           END AS cleaned_state, 
           SUM(order_items_vintage.sale_price) AS total_revenue,
           COUNT(order_items_vintage.returned_at) AS returned_items
    FROM order_items_vintage
    FULL JOIN customers ON customers.customer_id = order_items_vintage.user_id
    GROUP BY cleaned_state
),  
complete_orders AS (
    SELECT CASE 
               WHEN customers.state = 'US State' THEN 'California'
               WHEN customers.state IS NULL THEN 'Missing Data'
               ELSE customers.state
           END AS cleaned_state, 
           COUNT(DISTINCT orders.order_id) AS total_completed_orders, 
           COUNT(DISTINCT order_items.order_id) AS official_completed_orders,
           COUNT(DISTINCT order_items_vintage.order_id) AS vintage_completed_orders
    FROM customers
    FULL JOIN orders ON orders.user_id = customers.customer_id
    LEFT JOIN order_items ON orders.order_id = order_items.order_id
    LEFT JOIN order_items_vintage ON order_items_vintage.order_id = orders.order_id
    WHERE orders.status = 'Complete'
    GROUP BY cleaned_state
)
SELECT complete_orders.cleaned_state, 
       complete_orders.total_completed_orders, 
       complete_orders.official_completed_orders, 
       complete_orders.vintage_completed_orders, 
       SUM(temp_table.total_revenue) AS total_revenue
FROM complete_orders
FULL JOIN temp_table ON complete_orders.cleaned_state = temp_table.cleaned_state
GROUP BY complete_orders.cleaned_state, 
         complete_orders.total_completed_orders, 
         complete_orders.official_completed_orders, 
         complete_orders.vintage_completed_orders;


/*
Q #5: 
*/

WITH temp_table AS (
    SELECT CASE 
               WHEN customers.state = 'US State' THEN 'California'
               WHEN customers.state IS NULL THEN 'Missing Data'
               ELSE customers.state
           END AS cleaned_state, 
           SUM(order_items.sale_price) AS total_revenue, 
           COUNT(order_items.returned_at) AS return_items
    FROM order_items
    FULL JOIN customers ON customers.customer_id = order_items.user_id
    GROUP BY cleaned_state
    UNION ALL
    SELECT CASE 
               WHEN customers.state = 'US State' THEN 'California'
               WHEN customers.state IS NULL THEN 'Missing Data'
               ELSE customers.state
           END AS cleaned_state, 
           SUM(order_items_vintage.sale_price) AS total_revenue,
           COUNT(order_items_vintage.returned_at) AS return_items
    FROM order_items_vintage
    FULL JOIN customers ON customers.customer_id = order_items_vintage.user_id
    GROUP BY cleaned_state
),  
complete_orders AS (
    SELECT CASE 
               WHEN customers.state = 'US State' THEN 'California'
               WHEN customers.state IS NULL THEN 'Missing Data'
               ELSE customers.state
           END AS cleaned_state, 
           COUNT(DISTINCT orders.order_id) AS total_completed_orders, 
           COUNT(DISTINCT order_items.order_id) AS official_completed_orders,
           COUNT(DISTINCT order_items_vintage.order_id) AS vintage_completed_orders
    FROM customers
    FULL JOIN orders ON orders.user_id = customers.customer_id
    LEFT JOIN order_items ON orders.order_id = order_items.order_id
    LEFT JOIN order_items_vintage ON order_items_vintage.order_id = orders.order_id
    WHERE orders.status = 'Complete'
    GROUP BY cleaned_state
)
SELECT complete_orders.cleaned_state, 
       complete_orders.total_completed_orders, 
       complete_orders.official_completed_orders, 
       complete_orders.vintage_completed_orders, 
       SUM(temp_table.total_revenue) AS total_revenue,
       SUM(temp_table.return_items) AS returned_items
FROM complete_orders
FULL JOIN temp_table ON complete_orders.cleaned_state = temp_table.cleaned_state
GROUP BY complete_orders.cleaned_state, 
         complete_orders.total_completed_orders, 
         complete_orders.official_completed_orders, 
         complete_orders.vintage_completed_orders;


/*
Q6: 
*/
WITH temp_table AS (
    SELECT CASE 
               WHEN customers.state = 'US State' THEN 'California'
               WHEN customers.state IS NULL THEN 'Missing Data'
               ELSE customers.state
           END AS cleaned_state, 
           SUM(order_items.sale_price) AS total_revenue, 
           COUNT(order_items.returned_at) AS return_items,
           COUNT(DISTINCT order_items.order_item_id) AS order_item
    FROM order_items
    FULL JOIN customers ON customers.customer_id = order_items.user_id
    GROUP BY cleaned_state
    UNION ALL
    SELECT CASE 
               WHEN customers.state = 'US State' THEN 'California'
               WHEN customers.state IS NULL THEN 'Missing Data'
               ELSE customers.state
           END AS cleaned_state, 
           SUM(order_items_vintage.sale_price) AS total_revenue,
           COUNT(order_items_vintage.returned_at) AS return_items,
           COUNT(DISTINCT order_items_vintage.order_item_id) AS order_item
    FROM order_items_vintage
    FULL JOIN customers ON customers.customer_id = order_items_vintage.user_id
    GROUP BY cleaned_state
),  
complete_orders AS (
    SELECT CASE 
               WHEN customers.state = 'US State' THEN 'California'
               WHEN customers.state IS NULL THEN 'Missing Data'
               ELSE customers.state
           END AS cleaned_state, 
           COUNT(DISTINCT orders.order_id) AS total_completed_orders, 
           COUNT(DISTINCT order_items.order_id) AS official_completed_orders,
           COUNT(DISTINCT order_items_vintage.order_id) AS vintage_completed_orders
    FROM customers
    FULL JOIN orders ON orders.user_id = customers.customer_id
    LEFT JOIN order_items ON orders.order_id = order_items.order_id
    LEFT JOIN order_items_vintage ON order_items_vintage.order_id = orders.order_id
    WHERE orders.status = 'Complete'
    GROUP BY cleaned_state
)
SELECT complete_orders.cleaned_state, 
       complete_orders.total_completed_orders, 
       complete_orders.official_completed_orders, 
       complete_orders.vintage_completed_orders, 
       SUM(temp_table.total_revenue) AS total_revenue,
       SUM(temp_table.return_items) AS returned_items,
       SUM(temp_table.return_items) / SUM(temp_table.order_item) AS return_rate
FROM complete_orders
FULL JOIN temp_table ON complete_orders.cleaned_state = temp_table.cleaned_state
GROUP BY complete_orders.cleaned_state, 
         complete_orders.total_completed_orders, 
         complete_orders.official_completed_orders, 
         complete_orders.vintage_completed_orders;
