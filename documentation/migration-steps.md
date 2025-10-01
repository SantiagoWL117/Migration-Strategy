Purpose: 
Extract step:
    1. (AI responsibility) F    ield mapping:
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


-- Prompt -----------------------------------------------------------------------------------------------------------------------------------
I want to create a migration plan for the table menuca_v3.[]. 
First: Review the mapping convention for menuca_v3.[] defined in @restaurant-management-mapping.md compare it with the data stored in menuca_v1_restaurants.sql and menuca_v2_restaurants.sql. Analyze @menuca_v2_structure.sql and @menuca_v1_structure.sql what tables and columns would be fit to work for the  menuca_v3.[] table.
Second: Create a database migration strategy that follows an Extract-Transform-Load approach. The plan should include defined steps, explanation and Verification queries that ensure that the data requires will be successfully migrated and that the data integrity is maintained. Follow the example of restaurant_admin_users migration plan.md to create the plan













