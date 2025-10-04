-- Create database for "data warehouse"

USE master;
GO

IF EXISTS(SELECT 1 FROM sys.databases where name = 'DataWarehouse')
BEGIN 
	ALTER DATABASE DataWarehouse SET Single_User WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DATAWAREHOUSE;
END;
GO

CREATE DATABASE DataWarehouse;

USE DataWarehouse;

CREATE SCHEMA Bronze;
GO
CREATE SCHEMA Silver;
GO 
CREATE SCHEMA Gold;
GO

