-- Author: Julia Monjardim
-- Date: 21/09/2025
-- File: sql/cleaned_data.sql
-- Purpose: Showcase cleaned data script
-- Source table: `data-cleaning-project-09-2025.customer_orders.order_info`

WITH cleaned_data AS (
    SELECT
        order_id,
        -- Clean customer name:
        INITCAP(customer_name) AS customer_name,
        email,

        -- Standardized order_status:
        CASE
            WHEN LOWER(order_status) LIKE "%deliver%" THEN "Delivered"
            WHEN LOWER(order_status) LIKE "%return%" THEN "Returned"
            WHEN LOWER(order_status) LIKE "%refund%" THEN "Refunded"
            WHEN LOWER(order_status) LIKE "%pend%" THEN "Pending"
            WHEN LOWER(order_status) LIKE "%ship%" THEN "Shipped"
        ELSE "Other" 
        END AS cleaned_order_status

        -- Standardized product_name: 
        CASE
            WHEN LOWER(product_name) LIKE "%samsung galaxy s22%" THEN "Samsung Galaxy S22" 
            WHEN LOWER(product_name) LIKE "%apple watch%" THEN "Apple Watch"
            WHEN LOWER(product_name) LIKE "%google pixel%" THEN "Google Pixel"
            WHEN LOWER(product_name) LIKE "%iphone 14%" THEN "iPhone 14"
            WHEN LOWER(product_name) LIKE "%macbook pro%" THEN "MacBook Pro"
        ELSE "Other"
        END AS cleaned_product_name

        -- Cleaned quantity:
        CASE
            WHEN LOWER(quantity) = "two" THEN 2

        ELSE CAST(quantity AS INT64)
        END AS cleaned_quantity

        -- Standardize date:
        COALESCE(
            SAFE.PARSE_DATE("%Y-%m-%d", CAST(order_date AS STRING)),
            SAFE.PARSE_DATE("%m/%d/%Y", CAST(order_date AS STRING))
        ) AS standardized_order_date

    FROM `data-cleaning-project-09-2025.customer_orders.order_info`
    WHERE customer_name IN NOT NULL
),

deduplicated_data AS (
    SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY LOWER(email), LOWER(cleaned_product_name)
    ORDER BY order_id
    ) AS rn
    FROM cleaned_data
);