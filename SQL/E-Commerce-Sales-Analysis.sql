-- How many customers does the business have in each city?
SELECT
    city,
    COUNT(customer_id) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;

-- Which payment methods do customers use most frequently?
SELECT
    payment_method,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC;

-- Which customer segment (New, Regular or Premium) generates the highest revenue?
SELECT
    c.customer_segment,
    SUM(o.order_total) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_segment
ORDER BY total_revenue DESC;

-- Which product categories generate the highest revenue?
SELECT
    category,
    SUM(order_total) AS total_revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY category
ORDER BY total_revenue DESC;

-- Who are the customers making purchases, and what products have they bought?
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_id,
    o.product_name,
    o.order_total,
    o.order_date
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC
Limit 5;

-- Which registered customers have never placed an order?
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- How has monthly revenue changed over time, and what is the month-on-month revenue growth?
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(order_total) AS total_revenue
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
revenue_comparison AS (
    SELECT
        sales_month,
        total_revenue,
        LAG(total_revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    sales_month,
    total_revenue,
    previous_month_revenue,
    total_revenue - previous_month_revenue AS revenue_change,
    ROUND(
        (total_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS growth_percentage
FROM revenue_comparison
ORDER BY sales_month;