
--View orders delivered to the city of Clayton that have a revenue greater than $400.
SELECT *
FROM sales
WHERE 
    customer_city = 'Clayton'
    AND net_sales > 400
ORDER BY 
    net_sales DESC 

--View order numbers, product names, and revenue for orders delivered to the city of Hammond with revenue greater than or equal to $500.
SELECT sales_id, product_name, net_sales
FROM sales
WHERE 
    customer_city = 'Hammond'
    AND net_sales >= 500

--Category Manager needs to view orders for products whose names contain the word Cotton.
SELECT *
FROM sales
WHERE 
    product_name LIKE '%Cotton%'

--See the top 20 highest grossing orders delivered to the city of Athens.
SELECT *
FROM sales
WHERE 
    customer_city = 'Athens'
ORDER BY 
    net_sales DESC 
LIMIT 20

--Calculate Average Order Value (AOV) of each state.
SELECT 
    customer_state
    , AVG(net_sales) AS avg_order_value
FROM sales
GROUP BY 1

--Calculate the total revenue of the state of Texas.
SELECT 
    SUM(net_sales) AS net_sales
FROM sales
WHERE 
    customer_state = 'TX'

--The company needs to analyze its customer file based on its past purchase data.

--Create a report for each customer, showing the following metrics.
--total spend
-- total orders purchased
-- total number of products purchased
-- AOV
--largest order value ever purchased

--Sort by total spend in descending order.
SELECT 
    customer_id
    , customer_name
    , SUM(net_sales) AS total_spent_amount
    , COUNT(sales_id) AS total_purchased_orders
    , SUM(quantity) AS purchased_quantity
    , AVG(net_sales) AS avg_order_value
    , MAX(net_sales) AS max_order_value
FROM sales
GROUP BY 1, 2
ORDER BY 
    SUM(net_sales) DESC

/*The company is looking to increase sales in new markets. To do so, the company
wants to understand the purchasing behavior of the states with good sales, and how they differ
from the rest of the states.

Based on that plan, you first need to group the states based on sales:
- Big 10: TX, MT, MN, NY, CO, CA, MI, NC, ND, MO
- Others: The remaining states */
SELECT 
    *
    , CASE
        WHEN customer_state = 'TX' THEN 'Big 10'
        WHEN customer_state = 'MT' THEN 'Big 10'
        WHEN customer_state = 'MN' THEN 'Big 10'
        WHEN customer_state = 'NY' THEN 'Big 10'
        WHEN customer_state = 'CO' THEN 'Big 10'
        WHEN customer_state = 'CA' THEN 'Big 10'
        WHEN customer_state = 'MI' THEN 'Big 10'
        WHEN customer_state = 'NC' THEN 'Big 10'
        WHEN customer_state = 'ND' THEN 'Big 10'
        WHEN customer_state = 'MO' THEN 'Big 10'
        ELSE 'Others' END
    AS customer_state_revenue_segment
FROM sales

/*
The company needs to group products to perform some product analysis.

You need to group products by material as required below:

- Metal: product name contains the words Aluminum, Copper, Steel, Bronze, Iron
- Cloth: product name contains the words Wool, Leather, Silk, Linen, Cotton
- Others: the rest

*/
SELECT 
    *
    , CASE
        WHEN product_name LIKE '%Aluminum%' THEN 'Metal'
        WHEN product_name LIKE '%Copper%' THEN 'Metal'
        WHEN product_name LIKE '%Steel%' THEN 'Metal'
        WHEN product_name LIKE '%Bronze%' THEN 'Metal'
        WHEN product_name LIKE '%Iron%' THEN 'Metal'
        WHEN product_name LIKE '%Wool%' THEN 'Cloth'
        WHEN product_name LIKE '%Leather%' THEN 'Cloth'
        WHEN product_name LIKE '%Silk%' THEN 'Cloth'
        WHEN product_name LIKE '%Linen%' THEN 'Cloth'
        WHEN product_name LIKE '%Cotton%' THEN 'Cloth'
        ELSE 'Others' END
    AS product_material_category
FROM sales
/*
The Marketing Team needs to segment customers to implement marketing programs for each customer group.

How to segment customers by total spending, done in M04 - T02:

- High value: > $3000
- Normal value: $1000 - $3000
- Low value: < $1000

Based on that result, get a list of customers in the High value group.

*/
WITH customer_lifetime_value AS (
    SELECT
        customer_id
        , customer_name
        , SUM(net_sales) AS lifetime_value 
    FROM sales 
    GROUP BY 1, 2
)

, customer_lifetime_value_segment AS (
    SELECT
        *
        , CASE 
            WHEN lifetime_value >= 3000 THEN 'High value'
            WHEN lifetime_value >= 1000 THEN 'Normal value'
            WHEN lifetime_value < 1000 THEN 'Low value'
            ELSE 'Undefined' END
        AS lifetime_value_segment
    FROM customer_lifetime_value
)

SELECT *
FROM customer_lifetime_value_segment
WHERE 
    lifetime_value_segment = 'High value'

/*
Calculate total revenue, AOV by month.

Sort results by month for easy tracking.

*/
SELECT
    DATE_TRUNC('MONTH', created_at) AS created_month
    , SUM(net_sales) AS net_sales
    , AVG(net_sales) AS avg_order_value
FROM sales 
GROUP BY 1
ORDER BY 1 
/*
The branch manager in New York State is planning to hire additional part-time warehouse
workers to handle a sudden increase in orders.

However, to decide which days of the week the part-time employees will work,
the branch manager needs to know which days of the week will have a higher volume of orders.

Based on this request, write a report to support the branch manager in making decisions.

*/
SELECT
    TO_CHAR(created_at, 'Day') AS created_day_of_week
    , COUNT(sales_id) AS count_orders
FROM sales
WHERE 
    customer_state = 'NY'
    AND created_at >= '2019-04-01' 
    AND created_at < '2020-04-01' -- Get data in the last 12 months for updated results
GROUP BY 1

/*
Sales Admin needs to view purchase history of customer named Laverne Stanton.
*/
SELECT 
    sales.*
    , customer.customer_name
FROM sales 
LEFT JOIN customer ON sales.customer_id = customer.customer_id
WHERE 
    customer.customer_name = 'Laverne Stanton'

/*
View orders for products whose names end with Table or Bench.

Example: Plastic Bench, Wood Table.

*/
SELECT 
    sales.*
    , product.product_name
FROM sales 
LEFT JOIN product ON sales.product_id = product.product_id
WHERE 
    product.product_name LIKE '%Table'
    OR product.product_name LIKE '%Bench' 

/*
To award vouchers, the Montana Customer Service team needs to report the top 20 customers 
who spent the most money in 2019.
*/
SELECT
    sales.customer_id
    , customer.customer_name
    , SUM(sales.net_sales) AS total_spent_amount
FROM sales
LEFT JOIN customer ON sales.customer_id = customer.customer_id
LEFT JOIN product ON sales.product_id = product.product_id
WHERE 
    customer.customer_state = 'MT'
    AND EXTRACT(YEAR FROM sales.created_at) = 2019
GROUP BY 1, 2
ORDER BY 3 DESC 
LIMIT 20 
/*
How many orders have revenue between $200 and $600?

*/
SELECT COUNT(*)
FROM sales 
WHERE 
    net_sales BETWEEN 200 AND 600 
/*
View total revenue for each state between April 2019 and March 2020.

*/
SELECT
    customer.customer_state 
    , SUM(net_sales) AS net_sales 
FROM sales 
LEFT JOIN customer ON sales.customer_id = customer.customer_id
WHERE 
    DATE_TRUNC('DAY', created_at) BETWEEN '2019-04-01' AND '2020-03-31'
GROUP BY 1 
/*
The company is looking to increase sales in new markets. To do so,
the company wants to understand the purchasing behavior of the states with good sales, and
how they differ from the rest of the states.

Based on that plan, you first need to group the states based on sales:

- Big 10: TX, MT, MN, NY, CO, CA, MI, NC, ND, MO
- Others: The remaining states

*/
SELECT
    *
    , CASE
        WHEN customer_state IN ('TX', 'MT', 'MN', 'NY', 'CO', 'CA', 'MI', 'NC', 'ND', 'MO') THEN 'Big 10'
        ELSE 'Others' END
    AS customer_state_revenue_segment
FROM customer 
/*
Calculate revenue by year and by industry. Need to arrange the industries
by columns. Each column is a product, each row is a year.

Suggested direction: combine SUM and CASE WHEN.

For example: SUM(CASE WHEN THEN END).

*/
SELECT
    DATE_TRUNC('YEAR', sales.created_at) AS created_year
    , SUM(CASE WHEN product.category = 'Doohickey' THEN sales.net_sales END) AS doohickey
    , SUM(CASE WHEN product.category = 'Gadget' THEN sales.net_sales END) AS gadget
    , SUM(CASE WHEN product.category = 'Gizmo' THEN sales.net_sales END) AS gizmo
    , SUM(CASE WHEN product.category = 'Widget' THEN sales.net_sales END) AS widget
FROM sales 
LEFT JOIN product USING (product_id)

/*
The company needs to analyze the change in customer behavior over time.

Based on the order grouping method done in M03 - T01, calculate the AOV of each group
(High/Normal/Low value) over each year.

However, the results need to be arranged into columns. Each column is a group
(High/Normal/Low value). Each row is a year.

Sort the results by year.

*/
WITH sales_order_value_segment AS (
    SELECT 
        *
        , CASE
            WHEN net_sales >= 500 THEN 'High value'
            WHEN net_sales >= 100 THEN 'Normal value'
            WHEN net_sales >= 0 THEN 'Low value'
            ELSE 'Undefined' END
        AS order_value_segment
    FROM sales
)

SELECT 
    DATE_TRUNC('YEAR', created_at) AS created_year
    , AVG(CASE WHEN order_value_segment = 'High value' THEN net_sales END) AS high_value
    , AVG(CASE WHEN order_value_segment = 'Normal value' THEN net_sales END) AS normal_value
    , AVG(CASE WHEN order_value_segment = 'Low value' THEN net_sales END) AS low_value
FROM sales_order_value_segment
GROUP BY 1 