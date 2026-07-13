/*
=====================================================================
Create Database and Schemas
=====================================================================
Script Purpose: 
    This script create a new database with the name 'Datawaehouse' after checking if it already exists.
    if database exists, it is dropped and recreated. Additionally this script provide 3 schemas sets 
    within database as 'broze' , 'silver' and 'gold'.
Warning:
    Running this script will drop database if already exists as 'Datawarehouse'.
    All the data present in database will be permanently deleted. proceed with catuon.
    Also ensure that you have proper backup before running this script.
*/

-- Drop and Recreate database 'Datawarehouse'
IF EXISTS(SELECT 1 FROM sys.databases WHERE name='Datawarehouse')
  BEGIN
   ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
   DROP DATABASE Datawarehouse;
  END;
  GO

-- Create Database 'DataWarehouse'


 USE master; 

 CREATE DATABASE Datawarehouse; 

 USE Datawarehouse;

 CREATE SCHEMA bronze;
 GO
 CREATE SCHEMA silver;
 GO
 CREATE SCHEMA gold;
 GO
