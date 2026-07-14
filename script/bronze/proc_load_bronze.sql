/*
===============================================================
Stored Procedure: Load Bronze Layer
===============================================================
Script Purpose:
 This stored procedure load the data into 'bronze' schema from external CSV file.
 It perform the following action:
   -- Firstly it trucates the tables present in bronze schema before loading the data.
   -- Uses the 'BULK INSERT' command to load the data into bronze tables.
Parameter:
 none 
  This stored procedure does not accept any parameter or return value

How to use?
 EXEC bronze.load_bronze;

==================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN

 DECLARE @start_time DATETIME, @end_time DATETIME, @bronze_start_time DATETIME, @bronze_end_time DATETIME;

 BEGIN TRY
   SET @bronze_start_time = GETDATE();

   PRINT '=====================';
   PRINT 'Loading Bronze Layer';
   PRINT '=====================';

   PRINT '---------------------';
   PRINT 'Loading CRM Tables' ;
   PRINT '---------------------';

   PRINT '>> Truncating the table : bronze.crm_cust_info';

   SET @start_time = GETDATE();

   TRUNCATE TABLE bronze.crm_cust_info

   PRINT '>> Inserting Data in Table : bronze.crm_cust_info';

   BULK INSERT bronze.crm_cust_info 
   FROM 'C:\Users\AYUSH\OneDrive\sql_project_DWH\sql_data_warehouse_project\datasets\source_crm\cust_info.csv'
   WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
    );

   SET @end_time = GETDATE();
   PRINT 'Load Time :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
   PRINT '---------------';
   SET @start_time = GETDATE();

   PRINT '>> Truncating the table : bronze.crm_prd_info';

   TRUNCATE TABLE bronze.crm_prd_info

   PRINT '>> Inserting Data in Table : bronze.crm_prd_info';

   BULK INSERT bronze.crm_prd_info 
   FROM 'C:\Users\AYUSH\OneDrive\sql_project_DWH\sql_data_warehouse_project\datasets\source_crm\prd_info.csv'
   WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
   );

   SET @end_time = GETDATE();
   PRINT 'Load Time :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
   PRINT '---------------';
   SET @start_time = GETDATE();

   PRINT '>> Truncating the table : bronze.crm_sales_details';

   TRUNCATE TABLE bronze.crm_sales_details

   PRINT '>> Inserting Data in Table : bronze.crm_sales_details';
 
   BULK INSERT bronze.crm_sales_details
   FROM 'C:\Users\AYUSH\OneDrive\sql_project_DWH\sql_data_warehouse_project\datasets\source_crm\sales_details.csv'
   WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
  );
   
   SET @end_time = GETDATE();
   PRINT 'Load Time :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
   PRINT '---------------';

   PRINT '---------------------';
   PRINT 'Loading ERP Tables' ;
   PRINT '---------------------';

   PRINT '>> Truncating the table : bronze.erp_cust_az12';

   SET @start_time = GETDATE();

   TRUNCATE TABLE bronze.erp_cust_az12

   PRINT '>> Inserting Data in Table : bronze.erp_cust_az12';

   BULK INSERT bronze.erp_cust_az12
   FROM 'C:\Users\AYUSH\OneDrive\sql_project_DWH\sql_data_warehouse_project\datasets\source_erp\CUST_AZ12.csv'
   WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
    );

   SET @end_time = GETDATE();
   PRINT 'Load Time :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
   PRINT '---------------';
   SET @start_time = GETDATE();

   PRINT '>> Truncating the table : bronze.erp_loc_a101';

   TRUNCATE TABLE bronze.erp_loc_a101

   PRINT '>> Inserting Data in Table : bronze.erp_loc_a101';

   BULK INSERT bronze.erp_loc_a101
   FROM 'C:\Users\AYUSH\OneDrive\sql_project_DWH\sql_data_warehouse_project\datasets\source_erp\LOC_A101.csv'
   WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
    ); 

   SET @end_time = GETDATE();
   PRINT 'Load Time :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
   PRINT '---------------';
   SET @start_time = GETDATE();

   PRINT '>> Truncating the table : bronze.erp_px_cat_g1v2';

   TRUNCATE TABLE bronze.erp_px_cat_g1v2

   PRINT '>> Inserting Data in Table : bronze.erp_px_cat_g1v2';

   BULK INSERT bronze.erp_px_cat_g1v2
   FROM 'C:\Users\AYUSH\OneDrive\sql_project_DWH\sql_data_warehouse_project\datasets\source_erp\PX_CAT_G1V2.csv'
   WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
    )
   SET @end_time = GETDATE();
   PRINT 'Load Time :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
   PRINT '---------------';

   SET @bronze_end_time = GETDATE();
   PRINT 'Total Bronze Duration :' + CAST(DATEDIFF(second, @bronze_start_time, @bronze_end_time) AS NVARCHAR) + 'seconds';
   PRINT '============================='

    END TRY

    BEGIN CATCH
    PRINT '==============================='
    PRINT 'ERROR OCCURED DURING LOADING OF BRONZE LAYER'
    PRINT 'Error Message' + ERROR_MESSAGE();
    PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
    PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
    END CATCH 
    
END
