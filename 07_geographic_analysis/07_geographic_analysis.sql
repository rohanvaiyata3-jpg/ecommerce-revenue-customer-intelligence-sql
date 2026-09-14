-- =========================================================
-- E-Commerce Revenue & Customer Intelligence
-- 07 - Geographic Analysis
-- =========================================================

USE ecommerce_analytics;


-- =========================================================
-- 1. State-Level Performance
-- =========================================================

SELECT
    State,
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
    ) AS average_order_value,

    ROUND(
        SUM(Net_Sales) /
        COUNT(DISTINCT Customer_ID),
        2
    ) AS revenue_per_customer

FROM ecommerce_sales_clean

GROUP BY State
ORDER BY revenue DESC;


-- =========================================================
-- 2. Top 10 States by Revenue
-- =========================================================

SELECT
    State,
    COUNT(DISTINCT Order_ID) AS total_orders,
    COUNT(DISTINCT Customer_ID) AS total_customers,
    ROUND(SUM(Net_Sales), 2) AS revenue
FROM ecommerce_sales_clean
GROUP BY State
ORDER BY revenue DESC
LIMIT 10;


-- =========================================================
-- 3. State Revenue Ranking
-- =========================================================

WITH state_performance AS (
    SELECT
        State,
        COUNT(DISTINCT Order_ID) AS total_orders,
        COUNT(DISTINCT Customer_ID) AS total_customers,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY State
),
ranked_states AS (
    SELECT
        State,
        total_orders,
        total_customers,
        ROUND(revenue, 2) AS revenue,
        DENSE_RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM state_performance
)
SELECT
    State,
    total_orders,
    total_customers,
    revenue,
    revenue_rank
FROM ranked_states
WHERE revenue_rank <= 10
ORDER BY revenue_rank;


-- =========================================================
-- 4. Geographic Revenue Concentration
-- =========================================================

WITH state_revenue AS (
    SELECT
        State,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY State
),
state_concentration AS (
    SELECT
        State,
        revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_revenue
    FROM state_revenue
)
SELECT
    State,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct,
    ROUND(
        cumulative_revenue * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS cumulative_revenue_share_pct
FROM state_concentration
ORDER BY revenue DESC;


-- =========================================================
-- 5. State Revenue per Customer
-- =========================================================

SELECT
    State,
    COUNT(DISTINCT Customer_ID) AS total_customers,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) /
        COUNT(DISTINCT Customer_ID),
        2
    ) AS revenue_per_customer
FROM ecommerce_sales_clean
GROUP BY State
ORDER BY revenue_per_customer DESC;


-- =========================================================
-- 6. State Average Order Value
-- =========================================================

SELECT
    State,
    COUNT(DISTINCT Order_ID) AS total_orders,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) /
        COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY State
ORDER BY average_order_value DESC;


-- =========================================================
-- 7. State × Category Performance
-- =========================================================

SELECT
    State,
    Category,
    COUNT(DISTINCT Order_ID) AS total_orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales), 2) AS revenue
FROM ecommerce_sales_clean
GROUP BY
    State,
    Category
ORDER BY
    State,
    revenue DESC;


-- =========================================================
-- 8. State Performance by Year
-- =========================================================

SELECT
    YEAR(Order_Date) AS order_year,
    State,
    COUNT(DISTINCT Order_ID) AS total_orders,
    ROUND(SUM(Net_Sales), 2) AS revenue
FROM ecommerce_sales_clean
GROUP BY
    YEAR(Order_Date),
    State
ORDER BY
    order_year,
    revenue DESC;


-- =========================================================
-- 9. Top State Within Each Year
-- =========================================================

WITH yearly_state_revenue AS (
    SELECT
        YEAR(Order_Date) AS order_year,
        State,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY
        YEAR(Order_Date),
        State
),
ranked_states AS (
    SELECT
        order_year,
        State,
        ROUND(revenue, 2) AS revenue,
        DENSE_RANK() OVER (
            PARTITION BY order_year
            ORDER BY revenue DESC
        ) AS state_rank
    FROM yearly_state_revenue
)
SELECT
    order_year,
    State,
    revenue,
    state_rank
FROM ranked_states
WHERE state_rank <= 5
ORDER BY
    order_year,
    state_rank;