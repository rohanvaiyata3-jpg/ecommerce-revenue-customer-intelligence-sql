-- =========================================================
-- E-Commerce Revenue & Customer Intelligence
-- 05 - Product Analysis
-- =========================================================

USE ecommerce_analytics;


-- =========================================================
-- 1. Category Performance
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
    ) AS revenue_share_pct,
    ROUND(
        SUM(Net_Sales) / SUM(Quantity),
        2
    ) AS revenue_per_unit,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY Category
ORDER BY revenue DESC;


-- =========================================================
-- 2. Product Performance
-- =========================================================

SELECT
    Product,
    Category,
    COUNT(DISTINCT Order_ID) AS total_orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales), 2) AS revenue,
    ROUND(
        SUM(Net_Sales) / SUM(Quantity),
        2
    ) AS revenue_per_unit,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value,
    ROUND(AVG(Discount_Percent), 2) AS average_discount,
    ROUND(AVG(Customer_Rating), 2) AS average_rating
FROM ecommerce_sales_clean
GROUP BY
    Product,
    Category
ORDER BY revenue DESC;


-- =========================================================
-- 3. Top 10 Products by Revenue
-- =========================================================

SELECT
    Product,
    Category,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales), 2) AS revenue
FROM ecommerce_sales_clean
GROUP BY
    Product,
    Category
ORDER BY revenue DESC
LIMIT 10;


-- =========================================================
-- 4. Top 10 Products by Units Sold
-- =========================================================

SELECT
    Product,
    Category,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales), 2) AS revenue
FROM ecommerce_sales_clean
GROUP BY
    Product,
    Category
ORDER BY units_sold DESC
LIMIT 10;


-- =========================================================
-- 5. Product Revenue Ranking
-- =========================================================

WITH product_performance AS (
    SELECT
        Product,
        Category,
        SUM(Quantity) AS units_sold,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY
        Product,
        Category
),
ranked_products AS (
    SELECT
        Product,
        Category,
        units_sold,
        ROUND(revenue, 2) AS revenue,
        DENSE_RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM product_performance
)
SELECT
    Product,
    Category,
    units_sold,
    revenue,
    revenue_rank
FROM ranked_products
WHERE revenue_rank <= 10
ORDER BY revenue_rank;


-- =========================================================
-- 6. Product Quantity Ranking
-- =========================================================

WITH product_performance AS (
    SELECT
        Product,
        Category,
        SUM(Quantity) AS units_sold,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY
        Product,
        Category
),
ranked_products AS (
    SELECT
        Product,
        Category,
        units_sold,
        ROUND(revenue, 2) AS revenue,
        DENSE_RANK() OVER (
            ORDER BY units_sold DESC
        ) AS quantity_rank
    FROM product_performance
)
SELECT
    Product,
    Category,
    units_sold,
    revenue,
    quantity_rank
FROM ranked_products
WHERE quantity_rank <= 10
ORDER BY quantity_rank;


-- =========================================================
-- 7. Revenue vs Quantity Performance
-- =========================================================

WITH product_performance AS (
    SELECT
        Product,
        Category,
        SUM(Quantity) AS units_sold,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY
        Product,
        Category
),
product_metrics AS (
    SELECT
        Product,
        Category,
        units_sold,
        ROUND(revenue, 2) AS revenue,
        NTILE(4) OVER (
            ORDER BY revenue
        ) AS revenue_quartile,
        NTILE(4) OVER (
            ORDER BY units_sold
        ) AS quantity_quartile
    FROM product_performance
)
SELECT
    Product,
    Category,
    units_sold,
    revenue,
    revenue_quartile,
    quantity_quartile,
    CASE
        WHEN revenue_quartile = 4
             AND quantity_quartile = 4
            THEN 'High Revenue - High Volume'

        WHEN revenue_quartile = 4
             AND quantity_quartile <= 2
            THEN 'High Revenue - Low Volume'

        WHEN revenue_quartile <= 2
             AND quantity_quartile = 4
            THEN 'Low Revenue - High Volume'

        ELSE 'Middle Performance'
    END AS product_position
FROM product_metrics
ORDER BY revenue DESC;


-- =========================================================
-- 8. Category Contribution to Total Revenue
-- =========================================================

WITH category_revenue AS (
    SELECT
        Category,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY Category
)
SELECT
    Category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS cumulative_revenue_share_pct
FROM category_revenue
ORDER BY revenue DESC;


-- =========================================================
-- 9. Product Rating and Discount Analysis
-- =========================================================

SELECT
    Product,
    Category,
    ROUND(AVG(Customer_Rating), 2) AS average_rating,
    ROUND(AVG(Discount_Percent), 2) AS average_discount,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales), 2) AS revenue
FROM ecommerce_sales_clean
GROUP BY
    Product,
    Category
ORDER BY revenue DESC;