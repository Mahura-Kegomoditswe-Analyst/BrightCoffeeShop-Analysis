/*
==========================================================
   ☕ BRIGHT COFFEE SHOP — DATA EXPLORATION & ANALYSIS
   Dataset: coffee.analysis.coffee_analysis
   Objective: Explore sales, revenue, store performance, 
              and operational patterns from transaction data.
   Author: Mahura Kegomoditswe
   Date: 2025-10-27
==========================================================
*/

-- 1️⃣ Preview all data from the table
-----------------------------------------------------------
SELECT *
FROM coffee.analysis.coffee_analysis;

-- 📝 Notes:
--  - Check for null or missing values in key fields (transaction_id, store_id, product_category).
--  - Verify data types (transaction_date should be DATE, transaction_time TIME, etc.).
--  - Confirm consistent naming (e.g., “Cappuccino” vs “Cappucino”).
--  - Ensure no duplicate transaction_id entries.


-- 2️⃣ Calculate revenue per transaction
-----------------------------------------------------------
SELECT 
    transaction_id,
    transaction_qty * unit_price AS revenue
FROM coffee.analysis.coffee_analysis;

-- 📝 Notes:
--  - Useful for creating individual-level metrics.
--  - Check if unit_price or transaction_qty ever equals zero (could indicate data errors).
--  - Later, this field will be aggregated to find total and average revenue.


-- 3️⃣ Count the total number of transactions (sales volume)
-----------------------------------------------------------
SELECT 
    COUNT(transaction_id) AS number_of_transactions
FROM coffee.analysis.coffee_analysis;

-- 📝 Notes:
--  - Confirms dataset size.
--  - Compare this count against unique transaction dates to understand sales frequency.


-- 4️⃣ Count the number of unique shops in the dataset
-----------------------------------------------------------
SELECT 
    COUNT(DISTINCT store_id) AS number_of_shops
FROM coffee.analysis.coffee_analysis;

-- 📝 Notes:
--  - Helps identify store coverage.
--  - Verify that store_id is not duplicated for different locations.


-- 5️⃣ List all store locations and their IDs
-----------------------------------------------------------
SELECT 
    DISTINCT store_location, 
    store_id
FROM coffee.analysis.coffee_analysis;

-- 📝 Notes:
--  - Confirms mapping between IDs and actual store names.
--  - Check if any store_id has multiple names (possible input inconsistency).


-- 6️⃣ Calculate total revenue per store location
-----------------------------------------------------------
SELECT 
    store_location,
    SUM(transaction_qty * unit_price) AS total_revenue
FROM coffee.analysis.coffee_analysis
GROUP BY store_location;

-- 📝 Notes:
--  - Identify which store performs best overall.
--  - You can later join this with the number of transactions to find “revenue per transaction”.
--  - Consider adding a “percentage contribution” column to compare performance.


-- 7️⃣ Determine the earliest (opening) time of transactions
-----------------------------------------------------------
SELECT 
    MIN(transaction_time) AS opening_time
FROM coffee.analysis.coffee_analysis;

-- 📝 Notes:
--  - Represents the earliest recorded sale.
--  - Check for outliers (e.g., sales before 06:00 may be data-entry errors).


-- 8️⃣ Determine the latest (closing) time of transactions
-----------------------------------------------------------
SELECT 
    MAX(transaction_time) AS closing_time
FROM coffee.analysis.coffee_analysis;

-- 📝 Notes:
--  - Represents the latest sale.
--  - Useful for defining daily business hours.
--  - Could check per store to see if they all close at the same time:
--    SELECT store_location, MAX(transaction_time) FROM ... GROUP BY store_location;


-- 9️⃣ Analyze revenue and sales patterns by multiple dimensions
-----------------------------------------------------------
SELECT 
    product_category,
    SUM(transaction_qty * unit_price) AS Revenue,
    store_location,
    product_detail,
    product_type,
    transaction_date,
    DAYNAME(transaction_date) AS day_name,
    CASE
        WHEN DAYNAME(transaction_date) IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_classification,
    MONTHNAME(transaction_date) AS month_name,
    CASE
        WHEN transaction_time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN transaction_time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
        WHEN transaction_time >= '17:00:00' THEN 'Evening'
    END AS time_bucket,
    HOUR(transaction_time) AS hour_of_day
FROM coffee.analysis.coffee_analysis
GROUP BY ALL
ORDER BY Revenue DESC;

-- 📝 Notes:
--  - Identifies top-performing product categories, times, and stores.
--  - GROUP BY ALL ensures grouping by all selected dimensions (Snowflake feature).
--  - Consider using EXTRACT(MONTH FROM transaction_date) for numerical month grouping.
--  - You can visualize this later in Excel using Pivot Charts (e.g., Revenue by Day, Store, and Product).



/*
EXTRA ANALYSIS SUGGESTIONS
-----------------------------------------------------------
1. Average revenue per transaction:
   SELECT AVG(transaction_qty*unit_price) AS avg_revenue FROM coffee.analysis.coffee_analysis;

2. Top 5 products by total sales:
   SELECT product_detail, SUM(transaction_qty) AS total_qty
   FROM coffee.analysis.coffee_analysis
   GROUP BY product_detail
   ORDER BY total_qty DESC
   LIMIT 5;

3. Sales trends over time:
   SELECT transaction_date, SUM(transaction_qty*unit_price) AS daily_revenue
   FROM coffee.analysis.coffee_analysis
   GROUP BY transaction_date
   ORDER BY transaction_date;

4. Check missing/nulls:
   SELECT COUNT(*) - COUNT(transaction_id) AS missing_transaction_ids FROM coffee.analysis.coffee_analysis;

5. Revenue contribution by product category (%):
   SELECT product_category,
          SUM(transaction_qty*unit_price) AS revenue,
          ROUND(SUM(transaction_qty*unit_price) / (SELECT SUM(transaction_qty*unit_price) FROM coffee.analysis.coffee_analysis) * 100, 2) AS percent_contribution
   FROM coffee.analysis.coffee_analysis
   GROUP BY product_category
   ORDER BY percent_contribution DESC;
*/