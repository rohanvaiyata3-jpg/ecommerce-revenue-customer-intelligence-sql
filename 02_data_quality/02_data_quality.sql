-- =========================================================
-- E-Commerce Revenue & Customer Intelligence
-- 02 - Data Quality Checks
-- =========================================================

USE ecommerce_analytics;


-- =========================================================
-- 1. Record Count
-- =========================================================

SELECT
    COUNT(*) AS total_records
FROM ecommerce_sales_clean;


-- =========================================================
-- 2. Unique Orders
-- =========================================================

SELECT
    COUNT(DISTINCT Order_ID) AS unique_orders
FROM ecommerce_sales_clean;


-- =========================================================
-- 3. Unique Customers
-- =========================================================

SELECT
    COUNT(DISTINCT Customer_ID) AS unique_customers
FROM ecommerce_sales_clean;


-- =========================================================
-- 4. Duplicate Order IDs
-- =========================================================

SELECT
    Order_ID,
    COUNT(*) AS record_count
FROM ecommerce_sales_clean
GROUP BY Order_ID
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


-- =========================================================
-- 5. Missing Values
-- =========================================================

SELECT
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN Customer_Name IS NULL THEN 1 ELSE 0 END) AS missing_customer_name,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS missing_state,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS missing_category,
    SUM(CASE WHEN Product IS NULL THEN 1 ELSE 0 END) AS missing_product,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
    SUM(CASE WHEN Unit_Price IS NULL THEN 1 ELSE 0 END) AS missing_unit_price,
    SUM(CASE WHEN Discount_Percent IS NULL THEN 1 ELSE 0 END) AS missing_discount,
    SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END) AS missing_payment_method,
    SUM(CASE WHEN Sales_Channel IS NULL THEN 1 ELSE 0 END) AS missing_sales_channel,
    SUM(CASE WHEN Customer_Rating IS NULL THEN 1 ELSE 0 END) AS missing_rating,
    SUM(CASE WHEN Gross_Sales IS NULL THEN 1 ELSE 0 END) AS missing_gross_sales,
    SUM(CASE WHEN Net_Sales IS NULL THEN 1 ELSE 0 END) AS missing_net_sales
FROM ecommerce_sales_clean;


-- =========================================================
-- 6. Invalid Numeric Values
-- =========================================================

SELECT
    COUNT(*) AS invalid_numeric_records
FROM ecommerce_sales_clean
WHERE
    Quantity <= 0
    OR Unit_Price < 0
    OR Discount_Percent < 0
    OR Discount_Percent > 100
    OR Gross_Sales < 0
    OR Net_Sales < 0;


-- =========================================================
-- 7. Invalid Customer Ratings
-- =========================================================

SELECT
    COUNT(*) AS invalid_ratings
FROM ecommerce_sales_clean
WHERE
    Customer_Rating IS NOT NULL
    AND (
        Customer_Rating < 1
        OR Customer_Rating > 5
    );


-- =========================================================
-- 8. Invalid Dates
-- =========================================================

SELECT
    COUNT(*) AS invalid_dates
FROM ecommerce_sales_clean
WHERE Order_Date IS NULL;


-- =========================================================
-- 9. Gross vs Net Sales Validation
-- =========================================================

SELECT
    COUNT(*) AS inconsistent_sales_records
FROM ecommerce_sales_clean
WHERE Net_Sales > Gross_Sales;


-- =========================================================
-- 10. Final Data Quality Summary
-- =========================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT Order_ID) AS unique_orders,
    COUNT(DISTINCT Customer_ID) AS unique_customers,
    SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END) AS missing_payment_methods,
    SUM(CASE WHEN Customer_Rating IS NULL THEN 1 ELSE 0 END) AS missing_customer_ratings,
    COUNT(DISTINCT Product) AS unique_products,
    COUNT(DISTINCT Category) AS unique_categories,
    COUNT(DISTINCT State) AS unique_states
FROM ecommerce_sales_clean;