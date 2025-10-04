USE DataWarehouse;
-----'dwh_create_date DATETIME2 DEFAULT GETDATE()'------------- IS ADDED FOR META DATA
IF OBJECT_ID('Silver.crm_cust_info','U') IS NOT NULL
	DROP TABLE Silver.crm_cust_info;

CREATE TABLE Silver.crm_cust_info
(
cst_id INT,
cst_key NVARCHAR(25),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_marital_sataus NVARCHAR(25),
cst_gender NVARCHAR(15),
cst_create_date	DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('Silver.crm_prd_info','U') IS NOT NULL -- 'U' is user table type of object
	DROP TABLE Silver.crm_prd_info;
CREATE TABLE Silver.crm_prd_info
(
prd_id INT,	
cat_id NVARCHAR(25),
prd_key	NVARCHAR(25),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(15),
prd_start_dt DATE,
prd_end_dt DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('Silver.crm_sales_details','U') IS NOT NULL
	DROP TABLE Silver.crm_sales_details;
CREATE TABLE Silver.crm_sales_details
(
sls_ord_num NVARCHAR(50),
sls_prd_key	NVARCHAR(50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
sls_price INT,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('Silver.erp_CUST_AZ12','U') IS NOT NULL
	DROP TABLE Silver.erp_CUST_AZ12;
CREATE TABLE Silver.erp_CUST_AZ12
(
cid	NVARCHAR(50),
bdate DATE,
gen CHAR(15),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('Silver.erp_LOC_A101','U') IS NOT NULL
	DROP TABLE Silver.erp_LOC_A101;
CREATE TABLE Silver.erp_LOC_A101
(
cid	NVARCHAR(50),
Cntry VARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('Silver.erp_PX_CAT_G1V2','U') IS NOT NULL
	DROP TABLE Silver.erp_PX_CAT_G1V2;
CREATE TABLE Silver.erp_PX_CAT_G1V2
(
ID NVARCHAR(25),
cat NVARCHAR(50),
Subcat NVARCHAR(50),
maintenance NVARCHAR(25),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);












