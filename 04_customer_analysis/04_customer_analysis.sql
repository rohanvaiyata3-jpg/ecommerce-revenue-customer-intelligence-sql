-- =========================================================
-- E-Commerce Revenue & Customer Intelligence
-- 04 - Customer Analysis
-- =========================================================

USE ecommerce_analytics;


-- =========================================================
-- 1. Customer-Level Summary
-- =========================================================

SELECT
    Customer_ID,
    MAX(Customer_Name) AS Customer_Name,
    MAX(Gender) AS Gender,
    MAX(Age) AS Age,
    MAX(City) AS City,
    MAX(State) AS State,
    COUNT(DISTINCT Order_ID) AS total_orders,
    SUM(Quantity) AS total_units,
    ROUND(SUM(Net_Sales), 2) AS total_revenue,
    ROUND(
        SUM(Net_Sales) / COUNT(DISTINCT Order_ID),
        2
    ) AS customer_aov,
    MAX(Order_Date) AS last_order_date,
    MIN(Order_Date) AS first_order_date
FROM ecommerce_sales_clean
GROUP BY Customer_ID
ORDER BY total_revenue DESC;


-- =========================================================
-- 2. Customer Revenue Ranking
-- =========================================================

WITH customer_revenue AS (
    SELECT
        Customer_ID,
        MAX(Customer_Name) AS Customer_Name,
        COUNT(DISTINCT Order_ID) AS total_orders,
        SUM(Net_Sales) AS revenue
    FROM ecommerce_sales_clean
    GROUP BY Customer_ID
),
ranked_customers AS (
    SELECT
        Customer_ID,
        Customer_Name,
        total_orders,
        ROUND(revenue, 2) AS revenue,
        DENSE_RANK() OVER (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM customer_revenue
)
SELECT
    Customer_ID,
    Customer_Name,
    total_orders,
    revenue,
    revenue_rank
FROM ranked_customers
WHERE revenue_rank <= 10
ORDER BY revenue_rank;


-- =========================================================
-- 3. Customer Repeat Purchase Analysis
-- =========================================================

WITH customer_orders AS (
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS order_count
    FROM ecommerce_sales_clean
    GROUP BY Customer_ID
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS customer_share_pct
FROM customer_orders
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END
ORDER BY customer_count DESC;


-- =========================================================
-- 4. RFM Base Table
-- =========================================================

WITH customer_rfm AS (
    SELECT
        Customer_ID,
        MAX(Customer_Name) AS Customer_Name,
        DATEDIFF(
            (SELECT MAX(Order_Date) FROM ecommerce_sales_clean),
            MAX(Order_Date)
        ) AS recency,
        COUNT(DISTINCT Order_ID) AS frequency,
        ROUND(SUM(Net_Sales), 2) AS monetary
    FROM ecommerce_sales_clean
    GROUP BY Customer_ID
)
SELECT
    Customer_ID,
    Customer_Name,
    recency,
    frequency,
    monetary
FROM customer_rfm
ORDER BY monetary DESC;


-- =========================================================
-- 5. RFM Scoring
-- =========================================================

WITH customer_rfm AS (
    SELECT
        Customer_ID,
        MAX(Customer_Name) AS Customer_Name,
        DATEDIFF(
            (SELECT MAX(Order_Date) FROM ecommerce_sales_clean),
            MAX(Order_Date)
        ) AS recency,
        COUNT(DISTINCT Order_ID) AS frequency,
        SUM(Net_Sales) AS monetary
    FROM ecommerce_sales_clean
    GROUP BY Customer_ID
),
rfm_scores AS (
    SELECT
        Customer_ID,
        Customer_Name,
        recency,
        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY recency DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS monetary_score

    FROM customer_rfm
)
SELECT
    Customer_ID,
    Customer_Name,
    recency,
    frequency,
    ROUND(monetary, 2) AS monetary,
    recency_score,
    frequency_score,
    monetary_score
FROM rfm_scores
ORDER BY monetary DESC;


-- =========================================================
-- 6. Customer Segmentation
-- =========================================================

WITH customer_rfm AS (
    SELECT
        Customer_ID,
        MAX(Customer_Name) AS Customer_Name,
        DATEDIFF(
            (SELECT MAX(Order_Date) FROM ecommerce_sales_clean),
            MAX(Order_Date)
        ) AS recency,
        COUNT(DISTINCT Order_ID) AS frequency,
        SUM(Net_Sales) AS monetary
    FROM ecommerce_sales_clean
    GROUP BY Customer_ID
),
rfm_scores AS (
    SELECT
        Customer_ID,
        Customer_Name,
        recency,
        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY recency DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS monetary_score

    FROM customer_rfm
),
segmented_customers AS (
    SELECT
        *,
        CASE
            WHEN recency_score >= 4
                 AND frequency_score >= 4
                 AND monetary_score >= 4
                THEN 'Champions'

            WHEN frequency_score >= 4
                 AND monetary_score >= 4
                THEN 'Loyal Customers'

            WHEN recency_score >= 4
                 AND frequency_score >= 3
                THEN 'Potential Loyalists'

            WHEN recency_score <= 2
                 AND frequency_score >= 3
                 AND monetary_score >= 3
                THEN 'At Risk'

            WHEN recency_score <= 2
                 AND frequency_score <= 2
                THEN 'Lost Customers'

            ELSE 'Others'
        END AS customer_segment
    FROM rfm_scores
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(
        SUM(monetary),
        2
    ) AS customer_revenue,
    ROUND(
        SUM(monetary) * 100.0 /
        SUM(SUM(monetary)) OVER (),
        2
    ) AS revenue_share_pct
FROM segmented_customers
GROUP BY customer_segment
ORDER BY customer_revenue DESC;


-- =========================================================
-- 7. Customer Segment Detail
-- =========================================================

WITH customer_rfm AS (
    SELECT
        Customer_ID,
        MAX(Customer_Name) AS Customer_Name,
        DATEDIFF(
            (SELECT MAX(Order_Date) FROM ecommerce_sales_clean),
            MAX(Order_Date)
        ) AS recency,
        COUNT(DISTINCT Order_ID) AS frequency,
        SUM(Net_Sales) AS monetary
    FROM ecommerce_sales_clean
    GROUP BY Customer_ID
),
rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_rfm
)
SELECT
    Customer_ID,
    Customer_Name,
    recency,
    frequency,
    ROUND(monetary, 2) AS monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CASE
        WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
            THEN 'Champions'

        WHEN frequency_score >= 4
             AND monetary_score >= 4
            THEN 'Loyal Customers'

        WHEN recency_score >= 4
             AND frequency_score >= 3
            THEN 'Potential Loyalists'

        WHEN recency_score <= 2
             AND frequency_score >= 3
             AND monetary_score >= 3
            THEN 'At Risk'

        WHEN recency_score <= 2
             AND frequency_score <= 2
            THEN 'Lost Customers'

        ELSE 'Others'
    END AS customer_segment
FROM rfm_scores
ORDER BY monetary DESC;