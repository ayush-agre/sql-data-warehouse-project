/*
===============================================================================================================
Quality Checks
===============================================================================================================
Script Purpose: 
    This script performs various data quality checks for data consistency, accuracy and
    standardization across the 'bronze' schema and 'silver' schema. It include check for
    - NULL or Duplicate Primary Key.
    - Unwanted Spaces in String Field.
    - Data Standardization and Consistency.
      Invalid Data Ranges and Order.
    - Data Consistency Between Relative Field.

Usage note:
    - Run these checks after data loading Silver layer.
    - Investigate and Ressolve any Issue Found During Check.
================================================================================================================
*/

-- This is the checking wheather the data is cleaned or not of the bronze layer of Table bronze.crm_cust_info
-- Checking for NULLS or Duplicates in Primary Key. 
-- Expectation: No Result. 

SELECT 
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL


 -- Check unwanted spaces
 -- Expectation: No result
SELECT * FROM
( SELECT 
 cst_firstname,
 cst_lastname, 
 TRIM(cst_firstname) AS fs,
 TRIM(cst_lastname) AS ls
 FROM bronze.crm_cust_info )t WHERE cst_firstname != fs OR cst_lastname != ls


 -- Data standardization and Consistency
 SELECT DISTINCT
 cst_gndr_cst
 FROM bronze.crm_cust_info 

-- This is the checking wheather the data is cleaned or not of the silver layer of Table silver.crm_cust_info
  
-- Check unwanted spaces
-- Expectation: No result
SELECT * FROM
( SELECT 
 cst_firstname,
 cst_lastname, 
 TRIM(cst_firstname) AS fs,
 TRIM(cst_lastname) AS ls
 FROM silver.crm_cust_info )t WHERE cst_firstname != fs OR cst_lastname != ls


 -- Data standardization and Consistency
 SELECT DISTINCT
 cst_gndr
 FROM silver.crm_cust_info 

-- Checking for NULLS or Duplicates in Primary Key. 
-- Expectation: No Result. 

SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL


--=====================================================================================================================

-- This is the checking wheather the data is cleaned or not of the bronze layer of Table bronze.crm_prd_info
  
-- Checking for Null or Duplicate Primary Key
-- Expectatiopn: None
SELECT
prd_id,
COUNT(prd_id)
FROM
bronze.crm_prd_info
GROUP BY prd_id HAVING COUNT(prd_id) > 1 OR prd_id IS NULL

-- Checking for Null or Duplicate Key
-- Expectation: None
SELECT
prd_key,
COUNT(prd_key)
FROM
bronze.crm_prd_info
GROUP BY prd_key HAVING COUNT(prd_key) > 1

-- Check if any Extra spaces present in prd_nm
SELECT
prd_nm,
TRIM(prd_nm)
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm) 


-- Check for Nulls or Negative Values in Product Cost
SELECT
prd_cost FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0

-- Data Standardization and Consistency
SELECT DISTINCT prd_line FROM bronze.crm_prd_info 

-- Check for Invalid Date Order
SELECT * 
FROM bronze.crm_prd_info 
WHERE ped_end < prd_start

-- This is the checking wheather the data is cleaned or not of the silver layer of Table silver.crm_prd_info
  
-- Checking for Null or Duplicate Primary Key
-- Expectatiopn: None
SELECT
prd_id,
COUNT(prd_id)
FROM
silver.crm_prd_info
GROUP BY prd_id HAVING COUNT(prd_id) > 1 OR prd_id IS NULL

-- Checking for Null or Duplicate Key
-- Expectation: None
SELECT
prd_key,
COUNT(prd_key)
FROM
silver.crm_prd_info
GROUP BY prd_key HAVING COUNT(prd_key) > 1

-- Check if any Extra spaces present in prd_nm
SELECT
prd_nm,
TRIM(prd_nm)
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm) 


-- Check for Nulls or Negative Values in Product Cost
SELECT
prd_cost FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0

-- Data Standardization and Consistency
SELECT DISTINCT prd_line FROM silver.crm_prd_info 

-- Check for Invalid Date Order
SELECT * 
FROM silver.crm_prd_info 
WHERE prd_end < prd_start


--=====================================================================================================================


--   This is the checking wheather the data is cleaned or not of the bronze layer of Table bronze.sales_details



-- Check Wheather the White Spaces are Present in Order Number or Not
SELECT
sls_ord_num 
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)


-- Checking Whether Key is Present or not in Product info. Table
SELECT
sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)


-- Checking Whether Key is Present or not in Customer info. Table
SELECT
sls_cst_id
FROM bronze.crm_sales_details
WHERE sls_cst_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)


-- Check for Invalid Date
SELECT
sls_ship_dt,
sls_due_dt,
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 OR sls_due_dt <= 0 OR sls_order_dt <= 0;

SELECT
sls_order_dt
FROM bronze.crm_sales_details
WHERE LEN(sls_order_dt) != 8;

SELECT
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt > 20250617

SELECT 
sls_order_dt,
sls_ship_dt,
sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_ship_dt > sls_due_dt


-- Check Data Consistency Between Sales, Quantity and Price
-- >>	Sales: Quantity * Price
-- Value must not be Null, Zero or Negaqtive
SELECT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price;

SELECT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales IS NULL OR sls_sales <= 0 OR
sls_quantity IS NULL OR sls_quantity <= 0 OR
sls_price IS NULL OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price


--   This is the checking wheather the data is cleaned or not of the silver layer of Table silver.sales_details

-- Check Wheather the White Spaces are Present in Order Number or Not
SELECT
sls_ord_num 
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)


-- Checking Whether Key is Present or not in Product info. Table
SELECT
sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)


-- Checking Whether Key is Present or not in Customer info. Table
SELECT
sls_cst_id
FROM silver.crm_sales_details
WHERE sls_cst_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)


-- Check for Invalid Date
SELECT
sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > 20250617

SELECT
sls_order_dt
FROM silver.crm_sales_details
WHERE LEN(sls_order_dt) != 10;

-- Check Data Consistency Between Sales, Quantity and Price
-- >>	Sales: Quantity * Price
-- Value must not be Null, Zero or Negaqtive
SELECT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price;

SELECT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS NULL OR sls_sales <= 0 OR
sls_quantity IS NULL OR sls_quantity <= 0 OR
sls_price IS NULL OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

  
--=====================================================================================================================


--   This is the checking wheather the data is cleaned or not of the bronze layer of loc_a101

-- Check Wheather Column cid id Present in Table cust_info 
SELECT 
REPLACE(cid, '-', '')
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM bronze.crm_cust_info)

-- Data Standardization and Consistency
SELECT DISTINCT 
cntry
FROM bronze.erp_loc_a101

--   This is the checking wheather the data is cleaned or not of the silver layer of loc_a101

-- Check Wheather Column cid id Present in Table cust_info 
SELECT 
REPLACE(cid, '-', '')
FROM silver.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM bronze.crm_cust_info)

-- Data Standardization and Consistency
SELECT DISTINCT 
cntry
FROM silver.erp_loc_a101


--=====================================================================================================================


--   This is the checking wheather the data is cleaned or not of the bronze layer of Table bronze.cust_az12

-- Check Wheather cid Column is Present in Table crm_cust_info or not
SELECT 
cid 
FROM 
bronze.erp_cust_az12 
WHERE cid IN (SELECT cst_key FROM bronze.crm_cust_info)


-- Check for Invalid Date
SELECT 
bdate 
FROM 
bronze.erp_cust_az12 
WHERE bdate IS NULL

SELECT 
bdate 
FROM 
bronze.erp_cust_az12 
WHERE LEN(bdate) != 10 

-- Check if Whitespace is Present or Not
SELECT 
gen 
FROM bronze.erp_cust_az12 
WHERE gen != TRIM(gen)

-- Check Wheather Null is Present or Not
SELECT 
gen 
FROM bronze.erp_cust_az12 
WHERE gen IS NULL

-- Identify Out of Range 
SELECT 
bdate 
FROM 
bronze.erp_cust_az12 
WHERE bdate < '1925-01-01' OR bdate > GETDATE()

-- Data Standardization and Consistency 
SELECT DISTINCT 
gen 
FROM 
bronze.erp_cust_az12

--   This is the checking wheather the data is cleaned or not of the silver layer of Table silver.cust_az12

-- Check Wheather cid Column is Present in Table crm_cust_info or not
SELECT 
cid 
FROM 
silver.erp_cust_az12 
WHERE cid IN (SELECT cst_key FROM bronze.crm_cust_info)


-- Check for Invalid Date
SELECT 
bdate 
FROM 
silver.erp_cust_az12 
WHERE bdate IS NULL

SELECT 
bdate 
FROM 
silver.erp_cust_az12 
WHERE LEN(bdate) != 10 

-- Check if Whitespace is Present or Not
SELECT 
gen 
FROM silver.erp_cust_az12 
WHERE gen != TRIM(gen)

-- Check Wheather Null is Present or Not
SELECT 
gen 
FROM silver.erp_cust_az12 
WHERE gen IS NULL

-- Identify Out of Range 
SELECT 
bdate 
FROM 
silver.erp_cust_az12 
WHERE bdate < '1925-01-01' OR bdate > GETDATE()

-- Data Standardization and Consistency 
SELECT DISTINCT 
gen 
FROM 
silver.erp_cust_az12


--=====================================================================================================================


--   This is the checking wheather the data is cleaned or not of the bronze layer of Table bronze.px_cat_g1v2

-- Check Wheather for White Spaces and Null
SELECT
cat
FROM bronze.erp_px_cat_g1v2
WHERE LEN(TRIM(cat)) != LEN(cat) OR cat IS NULL

-- Check Wheather for White Spaces and Null
SELECT
subcaat
FROM bronze.erp_px_cat_g1v2
WHERE LEN(TRIM(subcaat)) != LEN(subcaat) OR subcaat IS NULL

SELECT
maintenance
FROM bronze.erp_px_cat_g1v2
WHERE LEN(TRIM(maintenance)) != LEN(maintenance) OR maintenance IS NULL



-- Data Standardization and Consistency
SELECT DISTINCT
cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
subcaat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2
