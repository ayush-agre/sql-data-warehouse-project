/*
===============================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================
Script Purpose:  
    This stored procedure performs the ETL(Extract, Transform, Load) process
    to populate 'silver' schema table from 'bronze' schema.
  Action Performed:
    -Truncate Silver Table.
    -Inserts transforms and cleansed data from Bronze to Silver table

Parameter:
   This stored procedure does ot accept any parameter or return any value.

How to use ?
    EXEC silver.load_silver;
=================================================================
*/
     
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
 DECLARE @start_time DATETIME, @end_time DATETIME, @silver_start_time DATETIME, @silver_end_time DATETIME; 
 BEGIN TRY

    PRINT '------------------------------------';
    PRINT 'Loading CRM Table';
    PRINT '------------------------------------';

    SET @silver_start_time = GETDATE();
    PRINT '============================================'
    PRINT '>> Loading Silver Layer'
    PRINT '============================================'

    SET @start_time = GETDATE();
    PRINT '>>Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info
    PRINT '>> Inserting Data Into: silver.crm_cust_info';
    INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_martial_status,
    cst_gndr,
    cst_create_date )

    SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname),
    TRIM(cst_lastname),
    CASE WHEN UPPER(TRIM(cst_martial_status)) = 'S' THEN 'Single'
         WHEN UPPER(TRIM(cst_martial_status)) = 'M' THEN 'Married' 
         ELSE 'n/a'
    END cst_martial_status,
    CASE WHEN UPPER(TRIM(cst_gndr_cst)) = 'F' THEN 'Female'
         WHEN UPPER(TRIM(cst_gndr_cst)) = 'M' THEN 'Male' 
         ELSE 'n/a'
    END  cst_gndr_cst,                               
    cst_create_date
    FROM
    ( SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS last_flag
    FROM bronze.crm_cust_info 
     )t WHERE last_flag = 1 AND cst_id IS NOT NULL
    SET @end_time = GETDATE();
    PRINT 'Total Duration' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR); 
    PRINT '----------------------------------------------';



    SET @start_time = GETDATE();
     PRINT '>>Truncating Table: silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info
    PRINT '>> Inserting Data Into: silver.crm_prd_info';
    INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id, 
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start,
    prd_end
    )
    SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    COALESCE(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
         WHEN 'M' THEN 'Mountain'
         WHEN 'R' THEN 'Road'
         WHEN 'T' THEN 'Touring'
         WHEN 'S' THEN 'Other Sales'
         ELSE 'n/a'
    END AS prd_line,  
    CAST(prd_start AS DATE),
    CAST(LEAD(prd_start) OVER (PARTITION BY prd_key ORDER BY prd_start ASC) - 1 AS DATE) AS prd_end 
    FROM bronze.crm_prd_info
    SET @end_time = GETDATE();
    PRINT 'Total Duration' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
    PRINT '----------------------------------------------';



    SET @start_time = GETDATE();
    PRINT '>>Truncating Table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details
    PRINT '>> Inserting Data Into: silver.crm_sales_details';
    INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cst_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_price,
    sls_quantity)

    SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cst_id,
    CASE WHEN sls_order_dt = 0 THEN NULL
         WHEN LEN(sls_order_dt) != 8    THEN NULL
         ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END sls_order_dt,
    CASE WHEN sls_ship_dt = 0 THEN NULL
         WHEN LEN(sls_ship_dt) != 8    THEN NULL
         ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END sls_ship_dt,
    CASE WHEN sls_due_dt = 0 THEN NULL
         WHEN LEN(sls_due_dt) != 8    THEN NULL
         ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END sls_due_dt,
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
         THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
    END sls_sales,
    CASE WHEN sls_price IS NULL OR sls_price <= 0 
         THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE sls_price
    END sls_price,
    CASE WHEN sls_quantity < 0 
         THEN ABS(sls_quantity)
         ELSE sls_quantity
    END sls_quantity   
    FROM bronze.crm_sales_details
    SET @end_time = GETDATE();
    PRINT 'Total Duration' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
    PRINT '----------------------------------------------';


    PRINT '------------------------------------';
    PRINT 'Loading ERP Table';
    PRINT '------------------------------------';

    SET @start_time = GETDATE();
    PRINT '>>Truncating Table: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12
    PRINT '>> Inserting Data Into: silver.erp_cust_az12';
    INSERT INTO silver.erp_cust_az12(
    cid,
    bdate,
    gen)
    SELECT 
    CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
         ELSE cid
    END cid,
    CASE WHEN bdate > GETDATE() THEN NULL 
         ELSE bdate
    END bdate,
    CASE WHEN UPPER(TRIM(gen)) = 'F' THEN 'FEMALE' 
         WHEN UPPER(TRIM(gen)) = 'M' THEN 'MALE'
         ELSE 'n/a'
    END gen
    FROM bronze.erp_cust_az12
    SET @end_time = GETDATE();
    PRINT 'Total Duration' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
    PRINT '----------------------------------------------';



    SET @start_time = GETDATE();
    PRINT '>>Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101
    PRINT '>> Inserting Data Into: silver.erp_loc_a101';
    INSERT INTO silver.erp_loc_a101(
    cid,
    cntry
    )
    SELECT 
    REPLACE(cid, '-', '') AS cid,
    CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
         WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
         WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
         ELSE TRIM(cntry)
    END cntry
    FROM bronze.erp_loc_a101
    SET @end_time = GETDATE();
    PRINT 'Total Duration' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
    PRINT '----------------------------------------------';



    SET @start_time = GETDATE();
    PRINT '>>Truncating Table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2
    PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
    INSERT INTO silver.erp_px_cat_g1v2(
    id,
    cat,
    subcaat,
    maintenance
    )
    SELECT 
    id,
    cat,
    subcaat,
    maintenance
    FROM bronze.erp_px_cat_g1v2
    SET @end_time = GETDATE();
    PRINT 'Total Duration' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
    PRINT '----------------------------------------------';
    SET @silver_end_time = GETDATE();

    PRINT 'Total Duration of Silver Table:' + CAST(DATEDIFF(second, @silver_start_time, @silver_end_time) AS NVARCHAR);
 
 END TRY
 BEGIN CATCH
  PRINT '================================='; 
  PRINT 'ERROR OCCURED DURING SILVER LAYER'; 
  PRINT 'Error Message' + ERROR_MESSAGE();
  PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
  PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
  PRINT '=================================';
 END CATCH
END
