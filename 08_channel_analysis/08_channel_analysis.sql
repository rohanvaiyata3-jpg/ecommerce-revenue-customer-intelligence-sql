-- =========================================================
-- E-Commerce Revenue & Customer Intelligence
-- 08 - Sales Channel Analysis
-- =========================================================

USE ecommerce_analytics;


-- =========================================================
-- 1. Overall Channel Performance
-- =========================================================

SELECT
    Sales_Channel,
    COUNT(DISTINCT Order_ID) AS total_orders,
    COUNT(DISTINCT Customer_ID) AS total_customers,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) * 100.0 /
        SUM(SUM(Net_Sales)) OVER (),
        2
    ) AS revenue_share_pct,
    ROUND(
        SUM(Net_Sales) /
        COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY Sales_Channel
ORDER BY revenue DESC;


-- =========================================================
-- 2. Channel × Category Performance
-- =========================================================

SELECT
    Sales_Channel,
    Category,
    COUNT(DISTINCT Order_ID) AS total_orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) /
        COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY
    Sales_Channel,
    Category
ORDER BY
    Sales_Channel,
    revenue DESC;


-- =========================================================
-- 3. Channel × Discount Performance
-- =========================================================

SELECT
    Sales_Channel,
    Discount_Percent AS discount_percent,
    COUNT(DISTINCT Order_ID) AS total_orders,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) /
        COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY
    Sales_Channel,
    Discount_Percent
ORDER BY
    Sales_Channel,
    Discount_Percent;


-- =========================================================
-- 4. Channel × Payment Method
-- =========================================================

SELECT
    Sales_Channel,
    COALESCE(Payment_Method, 'Unknown') AS payment_method,
    COUNT(DISTINCT Order_ID) AS total_orders,
    ROUND(SUM(Net_Sales), 2) AS revenue
FROM ecommerce_sales_clean
GROUP BY
    Sales_Channel,
    COALESCE(Payment_Method, 'Unknown')
ORDER BY
    Sales_Channel,
    revenue DESC;


-- =========================================================
-- 5. Channel Performance by Year
-- =========================================================

SELECT
    YEAR(Order_Date) AS order_year,
    Sales_Channel,
    COUNT(DISTINCT Order_ID) AS total_orders,
    COUNT(DISTINCT Customer_ID) AS total_customers,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) /
        COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY
    YEAR(Order_Date),
    Sales_Channel
ORDER BY
    order_year,
    revenue DESC;


-- =========================================================
-- 6. Channel Revenue Share by Year
-- =========================================================

WITH yearly_channel_revenue AS (
    SELECT
        YEAR(Order_Date) AS order_year,
        Sales_Channel,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY
        YEAR(Order_Date),
        Sales_Channel
)
SELECT
    order_year,
    Sales_Channel,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (
            PARTITION BY order_year
        ),
        2
    ) AS revenue_share_pct
FROM yearly_channel_revenue
ORDER BY
    order_year,
    revenue DESC;


-- =========================================================
-- 7. Channel Ranking by Year
-- =========================================================

WITH yearly_channel_performance AS (
    SELECT
        YEAR(Order_Date) AS order_year,
        Sales_Channel,
        COUNT(DISTINCT Order_ID) AS total_orders,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY
        YEAR(Order_Date),
        Sales_Channel
),
ranked_channels AS (
    SELECT
        order_year,
        Sales_Channel,
        total_orders,
        ROUND(revenue, 2) AS revenue,
        DENSE_RANK() OVER (
            PARTITION BY order_year
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM yearly_channel_performance
)
SELECT
    order_year,
    Sales_Channel,
    total_orders,
    revenue,
    revenue_rank
FROM ranked_channels
ORDER BY
    order_year,
    revenue_rank;


-- =========================================================
-- 8. Channel × Customer Type
-- =========================================================

WITH customer_orders AS (
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS order_count
    FROM ecommerce_sales_clean
    GROUP BY Customer_ID
),
customer_type AS (
    SELECT
        Customer_ID,
        CASE
            WHEN order_count = 1
                THEN 'One-Time Customer'
            ELSE 'Repeat Customer'
        END AS customer_type
    FROM customer_orders
)
SELECT
    e.Sales_Channel,
    c.customer_type,
    COUNT(DISTINCT e.Customer_ID) AS customers,
    COUNT(DISTINCT e.Order_ID) AS orders,
    ROUND(SUM(e.Net_Sales), 2) AS revenue
FROM ecommerce_sales_clean e
JOIN customer_type c
    ON e.Customer_ID = c.Customer_ID
GROUP BY
    e.Sales_Channel,
    c.customer_type
ORDER BY
    e.Sales_Channel,
    revenue DESC;