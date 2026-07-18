/*
===================================================================================
Quality Checks
===================================================================================
Script Purpose:
    This script performs quality checks to validate the integraity, consistency
    and accuracy of the Gold layer this checks ensure
      - Uniquenes of surrogate keys in dimension tables.
      - Referential integraity between fact and dimension table.
      - Validation of relationship in the data model for analytical purpose.

 Usage notes: 
      - Run these checks after data loading silver layer.
      - Investigate and resolve any discrepancies found during check.
=====================================================================================
*/

-- Check Wheather any Duplicate is Present

SELECT 
    cst_id,
COUNT(*)
FROM(
SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_martial_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ci.dwh_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid
)t GROUP BY cst_id 
HAVING COUNT(*) > 1


-- Data STandardization and Consistency

SELECT DISTINCT
	ci.cst_gndr,
	ca.gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.cid
ORDER BY 1, 2

-- =====================================================================================


SELECT 
    prd_key,
    COUNT(*)
FROM(
SELECT 
    pn.prd_id,
    pn.prd_key,
    pn.cat_id,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pn.prd_start,
    pc.cat,
    pc.subcaat,
    pc.maintenance
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE pn.prd_end IS NULL -- Filter Out Historical Data 
)t GROUP BY prd_key 
HAVING COUNT(*) > 1


-- Foreign Key Integregrity (Dimension)

SELECT
*
FROM gold.fact_sales s 
LEFT JOIN gold.dim_customers c 
ON s.customer_id = c.customer_id
LEFT JOIN gold.dim_product p 
ON p.product_key = s.product_key
WHERE c.customer_id IS NULL OR p.product_key IS NULL 
