# E-Commerce Revenue & Customer Intelligence - SQL

## Project Overview

This project analyzes transactional e-commerce data using SQL to understand revenue performance, customer behavior, product performance, discount effectiveness, geographic trends, and sales-channel performance.

The analysis follows a business-oriented workflow: first validating and preparing the data, then analyzing key performance indicators, customers, products, discounts, geography, and channels.

The goal is to turn transactional data into insights that can support decisions around revenue growth, customer retention, product strategy, and commercial performance.

---

## Business Questions

The analysis focuses on questions such as:

- How much revenue is the business generating, and how is it changing over time?
- Which products and categories contribute the most revenue?
- Who are the highest-value and repeat customers?
- Which customer segments contribute the greatest share of revenue?
- How do discounts affect revenue and Average Order Value?
- Which states contribute most to overall revenue?
- Which sales channels perform best?
- How does channel performance vary across products, discounts, and customer types?

---

## Dataset

The dataset contains transactional e-commerce sales information covering:

- Orders and order dates
- Customer information and demographics
- Products and categories
- Quantity and unit price
- Discount percentage
- Payment methods
- Sales channels
- Customer ratings
- Gross and net sales
- City and state

---

## Analysis Structure

### 01 - Database Setup

- Created the analytical database
- Created the raw sales table
- Created a cleaned analysis table
- Converted dates and numeric fields into appropriate data types
- Performed initial record validation

### 02 - Data Quality

- Record and entity counts
- Duplicate checks
- Missing-value checks
- Numeric validation
- Customer-rating validation
- Date validation
- Gross vs. net sales validation

### 03 - KPI Analysis

- Total revenue, orders, customers, and units sold
- Average Order Value (AOV)
- Yearly performance
- Year-over-Year revenue growth
- Monthly revenue trends
- Month-over-Month growth
- Category revenue contribution
- Sales-channel performance
- Payment-method performance

### 04 - Customer Analysis

- Customer-level revenue and order analysis
- Top customer ranking
- Repeat-purchase analysis
- RFM analysis
- RFM scoring
- Customer segmentation
- Segment-level revenue contribution

### 05 - Product Analysis

- Category performance
- Product revenue and volume analysis
- Top products by revenue
- Top products by units sold
- Product ranking
- Revenue vs. quantity performance
- Category contribution to total revenue
- Product rating and discount analysis

### 06 - Discount Analysis

- Performance by discount level
- Discount value and effective discount rate
- Revenue share by discount level
- Discount group analysis
- Discount vs. AOV
- Category-level discount performance
- Channel-level discount performance

### 07 - Geographic Analysis

- State-level performance
- Top states by revenue
- State revenue ranking
- Geographic revenue concentration
- Revenue per customer
- State-level AOV
- State × category performance
- Yearly geographic performance
- Top-performing state by year

### 08 - Channel Analysis

- Overall channel performance
- Channel × category analysis
- Channel × discount analysis
- Channel × payment method
- Yearly channel performance
- Channel revenue share by year
- Channel ranking by year
- Channel × customer type analysis

---

## SQL Techniques Demonstrated

- Aggregations and `GROUP BY`
- `CASE` expressions
- Common Table Expressions (CTEs)
- Subqueries
- Window functions
- `LAG()`
- `DENSE_RANK()`
- `NTILE()`
- `SUM() OVER()`
- `PARTITION BY`
- Conditional aggregation
- Date functions
- Revenue-share analysis
- Cumulative revenue analysis
- Data-quality validation
- RFM customer segmentation

---

## Project Structure

<img width="982" height="607" alt="image" src="https://github.com/user-attachments/assets/5a875bce-9d06-40d8-9748-96717c3e12d3" />
