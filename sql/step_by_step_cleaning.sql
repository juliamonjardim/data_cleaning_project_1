-- Author: Julia Monjardim
-- Date: 21/09/2025
-- File: sql/step_by_step_cleaning.sql
-- Purpose: Standardize and Clean columns for Analysis
-- Source table: `data-cleaning-project-09-2025.customer_orders.order_info`

SELECT * FROM `data-cleaning-project-09-2025.customer_orders.order_info`;

-- 1. standardizing the column 'order_status'

SELECT order_status,

CASE
  WHEN LOWER(order_status) LIKE "%deliver%" THEN "Delivered"
  WHEN LOWER(order_status) LIKE "%return%" THEN "Returned"
  WHEN LOWER(order_status) LIKE "%refund%" THEN "Refunded"
  WHEN LOWER(order_status) LIKE "%pend%" THEN "Pending"
  WHEN LOWER(order_status) LIKE "%ship%" THEN "Shipped"
  ELSE "Other" 
END AS cleaned_order_status

FROM `data-cleaning-project-09-2025.customer_orders.order_info`;

-- 2. standardizing the column 'product_name'

SELECT product_name,

CASE
  WHEN LOWER(product_name) LIKE "%samsung galaxy s22%" THEN "Samsung Galaxy S22" 
  WHEN LOWER(product_name) LIKE "%apple watch%" THEN "Apple Watch"
  WHEN LOWER(product_name) LIKE "%google pixel%" THEN "Google Pixel"
  WHEN LOWER(product_name) LIKE "%iphone 14%" THEN "iPhone 14"
  WHEN LOWER(product_name) LIKE "%macbook pro%" THEN "MacBook Pro"
  ELSE "Other"
END AS cleaned_product_name

FROM `data-cleaning-project-09-2025.customer_orders.order_info`;

-- 3. Casting quantity from STRING into INT column and standardizing it

SELECT *,
  CASE
    WHEN LOWER(quantity) = "two" THEN 2

  ELSE CAST(quantity AS INT64)
  END AS cleaned_quantity
FROM `data-cleaning-project-09-2025.customer_orders.order_info`;

-- 4. Capitalizing customer_name column using INITCAP()

SELECT customer_name,
  INITCAP(customer_name) AS customer_name
FROM `data-cleaning-project-09-2025.customer_orders.order_info`
WHERE customer_name IS NOT NULL;

-- 5. Identifying duplicates using ROW_NUMBER()

SELECT *,
  ROW_NUMBER() OVER(
    PARTITION BY LOWER(email), LOWER(product_name)
    ORDER BY order_id
  ) AS rn 
FROM `data-cleaning-project-09-2025.customer_orders.order_info`;

-- 5.1. Removing duplicates 

SELECT *
FROM(
  SELECT *,
  ROW_NUMBER() OVER(
    PARTITION BY LOWER(email), LOWER(product_name)
    ORDER BY order_id
  ) AS rn 
  FROM `data-cleaning-project-09-2025.customer_orders.order_info`;
)
WHERE rn = 1;

-- 6. Standerdizing date column

SELECT *,
  COALESCE(
    SAFE.PARSE_DATE("%Y-%m-%d", CAST(order_date AS STRING)),
    SAFE.PARSE_DATE("%m/%d/%Y", CAST(order_date AS STRING))
  ) AS standardized_order_date
FROM `data-cleaning-project-09-2025.customer_orders.order_info`;


