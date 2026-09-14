-- =========================================================
-- E-Commerce Revenue & Customer Intelligence
-- 03 - KPI Analysis
-- =========================================================

USE ecommerce_analytics;


-- =========================================================
-- 1. Overall Business KPIs
-- =========================================================

SELECT
    ROUND(SUM(Net_Sales), 2) AS total_revenue,
    COUNT(DISTINCT Order_ID) AS total_orders,
    COUNT(DISTINCT Customer_ID) AS total_customers,
    SUM(Quantity) AS total_units_sold,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean;


-- =========================================================
-- 2. Revenue and Orders by Year
-- =========================================================

SELECT
    YEAR(Order_Date) AS order_year,
    COUNT(DISTINCT Order_ID) AS total_orders,
    COUNT(DISTINCT Customer_ID) AS total_customers,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY YEAR(Order_Date)
ORDER BY order_year;


-- =========================================================
-- 3. Year-over-Year Revenue Growth
-- =========================================================

WITH yearly_revenue AS (
    SELECT
        YEAR(Order_Date) AS order_year,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY YEAR(Order_Date)
),
yearly_comparison AS (
    SELECT
        order_year,
        revenue,
        LAG(revenue) OVER (
            ORDER BY order_year
        ) AS previous_year_revenue
    FROM yearly_revenue
)
SELECT
    order_year,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_year_revenue, 2) AS previous_year_revenue,
    ROUND(
        (revenue - previous_year_revenue)
        * 100.0 / previous_year_revenue,
        2
    ) AS yoy_growth_pct
FROM yearly_comparison
ORDER BY order_year;


-- =========================================================
-- 4. Monthly Revenue Trend
-- =========================================================

SELECT
    YEAR(Order_Date) AS order_year,
    MONTH(Order_Date) AS order_month,
    DATE_FORMAT(Order_Date, '%Y-%m') AS month,
    COUNT(DISTINCT Order_ID) AS total_orders,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY
    order_year,
    order_month;


-- =========================================================
-- 5. Monthly Revenue Growth
-- =========================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(Order_Date, '%Y-%m') AS month,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
),
monthly_comparison AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        * 100.0 / previous_month_revenue,
        2
    ) AS mom_growth_pct
FROM monthly_comparison
ORDER BY month;


-- =========================================================
-- 6. Revenue Share by Category
-- =========================================================

SELECT
    Category,
    COUNT(DISTINCT Order_ID) AS total_orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) * 100.0 /
        SUM(SUM(Net_Sales)) OVER (),
        2
    ) AS revenue_share_pct
FROM ecommerce_sales_clean
GROUP BY Category
ORDER BY revenue DESC;


-- =========================================================
-- 7. Sales Channel Performance
-- =========================================================

SELECT
    Sales_Channel,
    COUNT(DISTINCT Order_ID) AS total_orders,
    COUNT(DISTINCT Customer_ID) AS total_customers,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY Sales_Channel
ORDER BY revenue DESC;


-- =========================================================
-- 8. Payment Method Performance
-- =========================================================

SELECT
    COALESCE(Payment_Method, 'Unknown') AS payment_method,
    COUNT(DISTINCT Order_ID) AS total_orders,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY COALESCE(Payment_Method, 'Unknown')
ORDER BY revenue DESC;