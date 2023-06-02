-- Show table schema 
\d+ retail;

-- Show first 10 rows
SELECT * FROM retail limit 10;

-- Check # of records
SELECT COUNT(*) FROM retail;

-- number of clients (e.g. unique client ID)
SELECT COUNT(DISTINCT customer_id) FROM retail;

-- Latest and earliest date of transactions
SELECT MAX(invoice_date), MIN(invoice_date) FROM retail;

-- number of SKU/merchants (e.g. unique stock code)
SELECT COUNT(DISTINCT stock_code) from retail;

--  Calculate average invoice amount excluding invoices with a negative amount (e.g. canceled orders have negative amount)
WITH amounts(invoice_no, amt) AS (SELECT invoice_no, quantity*unit_price FROM retail WHERE quantity>0 and unit_price>0)
SELECT AVG(total) FROM (SELECT invoice_no, sum(amt) AS total FROM amounts GROUP BY invoice_no) as invoices;

-- Calculate total revenue (e.g. sum of unit_price * quantity)
SELECT SUM(unit_price*quantity) FROM retail;

-- Calculate total revenue by YYYYMM
WITH monthly_revenue(month, lamt) AS (SELECT to_char(invoice_date, 'YYYYMM'), quantity*unit_price FROM retail)
SELECT month, sum(amt) FROM monthly_revenue GROUP BY month ORDER BY month;

