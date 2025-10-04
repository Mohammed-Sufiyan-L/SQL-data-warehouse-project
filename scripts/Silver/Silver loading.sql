--- DATA HANDLING--
EXEC Silver.load_silver


CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		-- Loading silver.crm_cust_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Data Into: silver.crm_cust_info';
	-----    crm_cust_info -----------
			INSERT INTO Silver.crm_cust_info
				(
				[cst_id]
				  ,[cst_key]
				  ,[cst_firstname]
				  ,[cst_lastname]
				  ,[cst_marital_sataus]
				  ,[cst_gender]
				  ,[cst_create_date]
      
				)
			SELECT
				   [cst_id]
				  ,[cst_key]
				  ,COALESCE (TRIM([cst_firstname]) ,' ')AS [cst_firstname]
				  ,COALESCE (TRIM([cst_lastname]),' ' )AS [cst_lastname]
				  ,CASE 
						WHEN [cst_marital_sataus] = 'M' THEN 'Married'
						WHEN [cst_marital_sataus] = 'S' THEN 'Single'
						ELSE 'N/A'
				   END [cst_marital_sataus] 
				  ,CASE
						WHEN UPPER(TRIM ([cst_gender])) = 'M' THEN 'Male'
						WHEN UPPER(TRIM([cst_gender])) = 'F' THEN 'Female'
						ELSE 'N/A'
				   END [cst_gender]
				  ,[cst_create_date]
			FROM(
				SELECT 
				*,
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date) AS last_flag
				FROM Bronze.crm_cust_info
				WHERE cst_id IS NOT NULL
				) AS T
			WHERE last_flag = 1
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

	----------[crm_prd_info]-------------------
	---- Changes in dates should be checked with source management before changing
	SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting Data Into: silver.crm_prd_info';
			INSERT INTO Silver.crm_prd_info
			(
				   [prd_id]
				  ,[cat_id]
				  ,[prd_key]
				  ,[prd_nm]
				  ,[prd_cost]
				  ,[prd_line]
				  ,[prd_start_dt]
				  ,[prd_end_dt]
			)
			SELECT 
				   [prd_id]
				  ,REPLACE(SUBSTRING( [prd_key],1,5),'-','_') AS cat_id
				  ,SUBSTRING( [prd_key],7,LEN( [prd_key])) AS [prd_key]
				  ,[prd_nm]
				  ,ISNULL([prd_cost],0) AS [prd_cost]
				  ,CASE
						WHEN prd_line = 'R' THEN 'Road'
						WHEN prd_line = 'M' THEN 'Mountain'
						WHEN prd_line = 'S' THEN 'Other Sales'
						WHEN prd_line = 'T' THEN 'Touring'
						ELSE 'N/A'
					END prd_line
				  ,CAST([prd_start_dt] AS DATE) AS [prd_start_dt]
				  ,CAST (LEAD([prd_start_dt]) OVER (PARTITION BY prd_key ORDER BY [prd_start_dt] )-1 AS DATE) AS [prd_end_dt]
			FROM [Bronze].[crm_prd_info]
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
	----------- crm_sales_details ----------
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting Data Into: silver.crm_sales_details';
			INSERT INTO silver.crm_sales_details (
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price
			)
			SELECT 
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				CASE 
					WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
				END AS sls_order_dt,
				CASE 
					WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
				END AS sls_ship_dt,
				CASE 
					WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
				END AS sls_due_dt,
				CASE 
					WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
						THEN sls_quantity * ABS(sls_price)
					ELSE sls_sales
				END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
				sls_quantity,
				CASE 
					WHEN sls_price IS NULL OR sls_price <= 0 
						THEN sls_sales / NULLIF(sls_quantity, 0)
					ELSE sls_price  -- Derive price if original value is invalid
				END AS sls_price
			FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
	----- erp_CUST_AZ12 -----------
		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';
	 SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_CUST_AZ12';
		TRUNCATE TABLE silver.erp_CUST_AZ12;
		PRINT '>> Inserting Data Into: silver.erp_CUST_AZ12';

		INSERT INTO Silver.erp_CUST_AZ12 (cid,bdate,gen)
		SELECT 
		   SUBSTRING(cid,4,LEN(cid)) cid
		  ,[bdate]
		  ,CASE 
			WHEN TRIM(gen) IN ('F','FEMALE') THEN 'Female'
			WHEN TRIM(gen) IN ('M','FEMALE') THEN 'Male'
			WHEN gen IS NULL OR gen = '' THEN 'N/A'
			ELSE gen
		   END gen
		FROM [DataWarehouse].[Bronze].[erp_CUST_AZ12]
	  	    SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

	----- erp_LOC_A101 -----
	    SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_LOC_A101';
		TRUNCATE TABLE silver.erp_LOC_A101;
		PRINT '>> Inserting Data Into: silver.erp_LOC_A101';

	INSERT INTO Silver.erp_LOC_A101 (cid,Cntry)
	SELECT REPLACE([cid],'-','') AS cid
		  ,CASE 
			WHEN [Cntry] IN ('US','United states') THEN 'USA'
			WHEN Cntry = 'DE' THEN 'Germany'
			WHEN Cntry IS NULL OR Cntry = '' THEN 'N/A'
		   ELSE Cntry
		   END Cntry   
	  FROM [DataWarehouse].[Bronze].[erp_LOC_A101]
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
	----- erp_PX_CAT_G1V2 ---- 
	SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_PX_CAT_G1V2';
		TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
		PRINT '>> Inserting Data Into: silver.erp_PX_CAT_G1V2';
	INSERT INTO Silver.erp_PX_CAT_G1V2 (
		   [ID]
		  ,[cat]
		  ,[Subcat]
		  ,[maintenance])

	SELECT [ID]
		  ,[cat]
		  ,[Subcat]
		  ,[maintenance]
	  FROM [DataWarehouse].[Bronze].[erp_PX_CAT_G1V2]
	SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END