Purpose: 
Extract step:
    1. (AI responsibility) Field mapping:
    2. (User responsibility)Review other possible tables that could be useful in V1 and V2
    3. (User responsibility)Based on field mapping, add Dump of the required data to the Project for further analysis.
    4. (AI responsibility) Preconditions: Create the menuca_v3 tables according to the columns and format of the data dumps.
    5. (User responsibility) Extract data as CSV from the tables and columns defined in step 1 (Field mapping) 
    6. (AI responsibility) Based on the CSV data build the staging tables.
Transform Step:
    1. Verify format discrepencies accoross the CSV file
Load step: 
    1. Build a Transform and Upsert step to load the data from the staging tables to the menuca_v3 tables
Verification step: 
    (AI responsibility) Create verification queries that verify data integrity and that ensure that all the relevant data was migrated from the staging tables to menuca_v3 tables. Always include an explanation of the query and the expected outcome.




#### Extract the Data Stage:
-- Prompt ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
I want to create a migration plan for the table menuca_v3.[]. 
First: Review the mapping convention for menuca_v3.[] defined in @restaurant-management-mapping.md compare it with the data stored in menuca_v1_restaurants.sql and menuca_v2_restaurants.sql. Analyze @menuca_v2 structure.sql and @menuca_v1 structure.sql what tables and columns would be fit to work for the  menuca_v3.[] table.
Second: Create a database migration strategy that follows an Extract-Transform-Load approach. The plan should include defined steps, explanation and Verification queries that ensure that the data requires will be successfully migrated and that the data integrity is maintained. Follow this format:



#### Transform the Data Stage ***********************************************************************************

Analysis: ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Review the format of the CSV data. Using AI review the format of the data and modify it to conform to the structure and requirements of the Supabase Schema. Check for key discrepancies between data and accuracy (correct latitude/longitude)


** Load the Data Stage ***********************************************************************************
1. Build stating and menuca_v3 tables
2. Load data from CSV files

Prompt: ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Ok. I want to start the migration for menuca_v3.[table name]. the mapping convention is defined [Location & Geography]-mapping.md . I want to import the data in [Location & Geography table dumps] dumps into a database called menuca_v3.[table name] stored in Supabase. The sql script provided @menuca_v3.sql contains the schema definition for that database, including the table definition for menuca_v3.[table names]. Create a database migration strategy with defined steps, explanation and Verification queries that ensure that the data was successfully migrated. 













