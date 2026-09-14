-- =========================================================
-- E-Commerce Revenue & Customer Intelligence
-- 01 - Database Setup
-- =========================================================

-- Create database
CREATE DATABASE IF NOT EXISTS ecommerce_analytics;

USE ecommerce_analytics;


-- =========================================================
-- Raw Data Table
-- =========================================================

CREATE TABLE IF NOT EXISTS ecommerce_sales (
    Order_ID TEXT,
    Order_Date TEXT,
    Customer_ID TEXT,
    Customer_Name TEXT,
    Gender TEXT,
    Age INT,
    City TEXT,
    State TEXT,
    Category TEXT,
    Product TEXT,
    Quantity INT,
    Unit_Price INT,
    Discount_Percent INT,
    Payment_Method TEXT,
    Sales_Channel TEXT,
    Customer_Rating DOUBLE,
    Gross_Sales INT,
    Net_Sales DOUBLE
);


-- =========================================================
-- Clean Analysis Table
-- =========================================================

DROP TABLE IF EXISTS ecommerce_sales_clean;

CREATE TABLE ecommerce_sales_clean AS
SELECT
    CAST(Order_ID AS CHAR(50)) AS Order_ID,
    STR_TO_DATE(Order_Date, '%Y-%m-%d') AS Order_Date,
    CAST(Customer_ID AS CHAR(50)) AS Customer_ID,
    Customer_Name,
    Gender,
    Age,
    City,
    State,
    Category,
    Product,
    Quantity,
    CAST(Unit_Price AS DECIMAL(12,2)) AS Unit_Price,
    CAST(Discount_Percent AS DECIMAL(5,2)) AS Discount_Percent,
    Payment_Method,
    Sales_Channel,
    CAST(Customer_Rating AS DECIMAL(3,2)) AS Customer_Rating,
    CAST(Gross_Sales AS DECIMAL(14,2)) AS Gross_Sales,
    CAST(Net_Sales AS DECIMAL(14,2)) AS Net_Sales
FROM ecommerce_sales;


-- =========================================================
-- Basic Validation
-- =========================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT Order_ID) AS unique_orders,
    COUNT(DISTINCT Customer_ID) AS unique_customers
FROM ecommerce_sales_clean;