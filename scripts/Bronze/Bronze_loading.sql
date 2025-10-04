/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
--USE DataWarehouse
EXEC Bronze.load_bronze

CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME,@end_time DATETIME;
	SET @start_time = GETDATE();
	BEGIN TRY
		PRINT '==========================================';
		PRINT 'LOADING BRONZE LAYER';
		PRINT '==========================================';

		PRINT '--------------------------------------------';
		PRINT 'LOADING CRM LAYER';
		PRINT '---------------------------------------------';
		-------
		PRINT '--------------------------------------------';
		PRINT 'TRUNCATING  TABLE.........';
		PRINT '---------------------------------------------';
		
		TRUNCATE TABLE Bronze.crm_cust_info;
		PRINT '--------------------------------------------';
		PRINT 'Inserting data from csv into the table.........';
		PRINT '---------------------------------------------';
		SET @start_time = GETDATE();
		BULK INSERT Bronze.crm_cust_info
		FROM 'D:\DATA Projects\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		----------------
		SET @start_time = GETDATE();
		PRINT '--------------------------------------------';
		PRINT 'TRUNCATING  TABLE.........';
		PRINT '---------------------------------------------';
		TRUNCATE TABLE Bronze.crm_prd_info;;
		PRINT '--------------------------------------------';
		PRINT 'Inserting data from csv into the table.........';
		PRINT '---------------------------------------------';
		BULK INSERT Bronze.crm_prd_info
		FROM 'D:\DATA Projects\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
		---------------------------
		SET @start_time = GETDATE();
		PRINT '--------------------------------------------';
		PRINT 'TRUNCATING  TABLE.........';
		PRINT '---------------------------------------------';
		TRUNCATE TABLE Bronze.crm_sales_details;
		PRINT '--------------------------------------------';
		PRINT 'Inserting data from csv into the table.........';
		PRINT '---------------------------------------------';
		BULK INSERT Bronze.crm_sales_details
		FROM 'D:\DATA Projects\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + 'seconds';
		----------------------------------
		
		PRINT '--------------------------------------------';
		PRINT 'LOADING ERP LAYER';
		PRINT '---------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '--------------------------------------------';
		PRINT 'TRUNCATING  TABLE.........';
		PRINT '---------------------------------------------';
		TRUNCATE TABLE Bronze.erp_CUST_AZ12;
		PRINT '--------------------------------------------';
		PRINT 'Inserting data from csv into the table.........';
		PRINT '---------------------------------------------';
		BULK INSERT Bronze.erp_CUST_AZ12
		FROM 'D:\DATA Projects\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + 'seconds';
		------------------------------------------
		PRINT '--------------------------------------------';
		PRINT 'TRUNCATING  TABLE.........';
		PRINT '---------------------------------------------';
		TRUNCATE TABLE Bronze.erp_LOC_A101;
		PRINT '--------------------------------------------';
		PRINT 'Inserting data from csv into the table.........';
		PRINT '---------------------------------------------';
		BULK INSERT Bronze.erp_LOC_A101
		FROM 'D:\DATA Projects\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH 
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + 'seconds';
		-----------------------------------------
		SET @start_time = GETDATE();
		PRINT '--------------------------------------------';
		PRINT 'TRUNCATING  TABLE.........';
		PRINT '---------------------------------------------';
		TRUNCATE TABLE Bronze.erp_PX_CAT_G1V2;
		PRINT '--------------------------------------------';
		PRINT 'Inserting data from csv into the table.........';
		PRINT '---------------------------------------------';
		BULK INSERT Bronze.erp_PX_CAT_G1V2
		FROM 'D:\DATA Projects\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH 
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + 'seconds';
	END TRY
	BEGIN CATCH 
		PRINT '-------------------x-----------------------';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR STATE' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '-------------------x-----------------------';
	END CATCH
	SET @end_time = GETDATE();
	PRINT '=================================';
	PRINT '>> Load Duration for whole Bronze layer:'+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + 'seconds';
	PRINT '=================================';
END

