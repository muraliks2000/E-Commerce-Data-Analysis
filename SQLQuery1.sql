--Show all data

select * from Data

--Data Cleaning and Analysing

DECLARE @TableName NVARCHAR(MAX) = 'Data'; -- Your table name
DECLARE @SQL NVARCHAR(MAX) = '';
-- Generate SQL to count NULL values for each column
SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, COUNT(*) - COUNT(' + COLUMN_NAME + ') AS NullCount FROM ' + @TableName,
    ' UNION ALL '
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TableName
AND COLUMN_NAME IN ('ID', 'Warehouse_block', 'Mode_of_Shipment', 'Customer_care_calls', 'Customer_rating', 'Cost_of_the_Product', 'Prior_purchases', 'Product_importance', 'Gender', 'Discount_offered', 'Weight_in_gms', 'Reached.on.Time_Y.N');
-- Execute the dynamic SQL
EXEC sp_executesql @SQL;

--Shipping Performance by Mode of Shipment

select mode_of_shipment,
(SUM(CASE WHEN Reached_on_time_y_n = 1 THEN 1 END) * 100.0 / COUNT(*)) as perc from Data
group by mode_of_shipment

--Analyze if there is a relationship between discount offered and the percentage of on-time deliveries.

SELECT 
    Discount_offered,
    COUNT(*) AS Total_Shipments,
    SUM(CASE WHEN Reached_on_time_y_n = 1 THEN 1 ELSE 0 END) AS OnTime_Shipments,
    cast(SUM(CASE WHEN Reached_on_time_y_n = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)as decimal(10,2))  AS OnTime_Percentage
FROM Data
GROUP BY Discount_offered
ORDER BY Discount_offered;

--Investigate the relationship between customer care calls and customer ratings.

SELECT 
    Customer_care_calls,
    avg(Customer_rating) AS rating,
	cast(SUM(CASE WHEN Reached_on_time_y_n = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)as decimal(10,2))  AS OnTime_Percentage
FROM Data
GROUP BY Customer_care_calls
ORDER BY Customer_care_calls;

--: Check if high-priority products are delivered on time more often than lower-priority products.

SELECT 
    Product_importance,
    COUNT(*) AS Total_Shipments,
    cast(SUM(CASE WHEN Reached_on_time_y_n= 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as decimal(6,2)) AS OnTime_Percentage
FROM Data
GROUP BY Product_importance;

--: Evaluate the delivery performance based on the warehouse block where the product is stored.

SELECT 
    Warehouse_block,
    COUNT(*) AS Total_Shipments,
    cast(sum(CASE WHEN Reached_on_time_y_n= 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as decimal(8,2)) AS OnTime_Percentage
FROM Data
GROUP BY Warehouse_block
order by OnTime_Percentage desc


-- Calculate counts and percentages for each gender
-- Step 1: Calculate the total count of records
WITH Total AS (
    SELECT COUNT(*) AS total
    FROM data
)

-- Step 2: Calculate counts and percentages for each gender
SELECT
    gender,
    COUNT(*) AS num,
    ROUND(COUNT(*) * 100.0 / (SELECT total FROM Total), 2) AS percentage
FROM data
GROUP BY gender;



