-- =========================================================
-- E-Commerce Revenue & Customer Intelligence
-- 06 - Discount Analysis
-- =========================================================

USE ecommerce_analytics;


-- =========================================================
-- 1. Performance by Discount Level
-- =========================================================

SELECT
    Discount_Percent AS discount_percent,
    COUNT(DISTINCT Order_ID) AS total_orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Gross_Sales), 2) AS gross_sales,
    ROUND(SUM(Net_Sales), 2) AS net_sales,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY Discount_Percent
ORDER BY Discount_Percent;


-- =========================================================
-- 2. Revenue Impact of Discounts
-- =========================================================

SELECT
    Discount_Percent AS discount_percent,
    ROUND(SUM(Gross_Sales), 2) AS gross_sales,
    ROUND(SUM(Net_Sales), 2) AS net_sales,
    ROUND(
        SUM(Gross_Sales) - SUM(Net_Sales),
        2
    ) AS discount_value,
    ROUND(
        (SUM(Gross_Sales) - SUM(Net_Sales))
        * 100.0 / SUM(Gross_Sales),
        2
    ) AS effective_discount_pct
FROM ecommerce_sales_clean
GROUP BY Discount_Percent
ORDER BY Discount_Percent;


-- =========================================================
-- 3. Revenue Share by Discount Level
-- =========================================================

SELECT
    Discount_Percent AS discount_percent,
    ROUND(SUM(Net_Sales), 2) AS net_sales,
    ROUND(
        SUM(Net_Sales) * 100.0 /
        SUM(SUM(Net_Sales)) OVER (),
        2
    ) AS revenue_share_pct
FROM ecommerce_sales_clean
GROUP BY Discount_Percent
ORDER BY net_sales DESC;


-- =========================================================
-- 4. Discount Group Analysis
-- =========================================================

SELECT
    CASE
        WHEN Discount_Percent = 0
            THEN 'No Discount'

        WHEN Discount_Percent <= 10
            THEN 'Low Discount'

        WHEN Discount_Percent <= 20
            THEN 'Medium Discount'

        ELSE 'High Discount'
    END AS discount_group,

    COUNT(DISTINCT Order_ID) AS total_orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Gross_Sales), 2) AS gross_sales,
    ROUND(SUM(Net_Sales), 2) AS net_sales,

    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value

FROM ecommerce_sales_clean

GROUP BY
    CASE
        WHEN Discount_Percent = 0
            THEN 'No Discount'

        WHEN Discount_Percent <= 10
            THEN 'Low Discount'

        WHEN Discount_Percent <= 20
            THEN 'Medium Discount'

        ELSE 'High Discount'
    END

ORDER BY
    CASE
        WHEN discount_group = 'No Discount' THEN 1
        WHEN discount_group = 'Low Discount' THEN 2
        WHEN discount_group = 'Medium Discount' THEN 3
        WHEN discount_group = 'High Discount' THEN 4
    END;


-- =========================================================
-- 5. Discount vs Average Order Value
-- =========================================================

SELECT
    Discount_Percent AS discount_percent,
    COUNT(DISTINCT Order_ID) AS total_orders,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY Discount_Percent
ORDER BY Discount_Percent;


-- =========================================================
-- 6. Discount Performance by Category
-- =========================================================

SELECT
    Category,
    Discount_Percent AS discount_percent,
    COUNT(DISTINCT Order_ID) AS total_orders,
    ROUND(SUM(Net_Sales), 2) AS net_sales,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY
    Category,
    Discount_Percent
ORDER BY
    Category,
    Discount_Percent;


-- =========================================================
-- 7. Discount Performance by Sales Channel
-- =========================================================

SELECT
    Sales_Channel,
    Discount_Percent AS discount_percent,
    COUNT(DISTINCT Order_ID) AS total_orders,
    ROUND(SUM(Net_Sales), 2) AS net_sales,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
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
-- 8. Category-Level Discount Comparison
-- =========================================================

SELECT
    Category,
    ROUND(AVG(Discount_Percent), 2) AS average_discount,
    ROUND(SUM(Gross_Sales), 2) AS gross_sales,
    ROUND(SUM(Net_Sales), 2) AS net_sales,
    ROUND(
        SUM(Gross_Sales) - SUM(Net_Sales),
        2
    ) AS discount_value,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value
FROM ecommerce_sales_clean
GROUP BY Category
ORDER BY net_sales DESC;