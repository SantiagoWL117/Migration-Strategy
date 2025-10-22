I am a Developer working on creating the back-end for an enterprise-level food ordering application. The application is logically divided into 10 entities. My college Brian created and ran 10 different plans one for each entity:

Restaurant Management Entity (Priority 1 - Foundation) 
Users & Access (Priority 2 - Auth depends on restaurants)
Menu & Catalog Entity (Priority 3 - Depends on restaurants)
Service Configuration & Schedules (Priority 4 - Restaurant operations)
Location & Geography Entity (Priority 5 - Restaurant locations)
Marketing & Promotions (Priority 6 - Restaurant marketing)
Orders & Checkout (Priority 7 - Depends on menu/users/restaurants)
Delivery Operations (Priority 8 - Depends on orders)
Devices & Infrastructure Entity (Priority 9 - Restaurant hardware)
Vendors & Franchises (Priority 10 - Multi-restaurant operations) 

Each plan follows this guidelines:
1. The main goal of the project is to transform the Database architecture so it complies with industry standards for a enterprise-level food ordering application like Uber Eats, Skip, or DoorDash
2. We must break the previous v1/v2 logic in which some restaurants only work on v1 logic and some others only work in v2 logic.
3. Supabase MCP should be used in every step of the process.
4. Auth security is an absolute priority.
5. V1/V2 Logic Consolidation Strategy:  Keep legacy_v1_id/legacy_v2_id columns but consolidate all business logic to use only V3 patterns

I want to work on the back-end for the [] entity. I created a single source of truth for all the back-end development that we are going to implement called @BRIAN_MASTER_INDEX.md . This document was divided into 10 business entities:

Restaurant Management Entity (Priority 1 - Foundation) 
Users & Access (Priority 2 - Auth depends on restaurants)
Menu & Catalog Entity (Priority 3 - Depends on restaurants)
Service Configuration & Schedules (Priority 4 - Restaurant operations)
Location & Geography Entity (Priority 5 - Restaurant locations)
Marketing & Promotions (Priority 6 - Restaurant marketing)
Orders & Checkout (Priority 7 - Depends on menu/users/restaurants)
Delivery Operations (Priority 8 - Depends on orders)
Devices & Infrastructure Entity (Priority 9 - Restaurant hardware)
Vendors & Franchises (Priority 10 - Multi-restaurant operations) 

Each entity holds multiple business logic components that contain one or more features. For example the Restaurant Management Entity has a Franchise business logic component, which in turn has one more features like : 
1. Creating Parents	
2. Linking Children
3. Brand Management
4. Location Routing	
5. Performance Analytics
6. Menu Cascading	

Each feature has its own SQL and Edge functions. 

The purpose of this project is to record all the business logic component and their back-end funcitonality created for each entity so Brian (the front-end developer) and its agents  can use it to create the front-end of the app in a smooth and flawless way. The document must contain the SQL/Edge functions implemented, how to call them from the client side.

Let's work on []. Read the document and review that the the sql functions, triggers,indexes, views  and optimization strategies already exists in the menuca_v3 schema. If they are not built, create them using the Supabase MCP. Once all the back-end implementation is created test all  SQL objects. Then verify that all the Edge functions API endpoints were created and tested. If they are not built, create them using the Supabase MCP.

Once all test pass, update @BRIAN_MASTER_INDEX.md document  Remember no need to build extra documentation for this task, @BRIAN_MASTER_INDEX.md is the only source of truth

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Ok let's go ahead and continue with@ONBOARDING_TRACKING_COMPREHENSIVE.md . Remeber the process:
1. SQL level verification: Read the document and review that the the sql functions, triggers,indexes, views  and optimization strategies already exists in the menuca_v3 schema. If they are not built, create them using the Supabase MCP and test them. 
2. Supabase level verification: Then verify that all the Edge functions API endpoints were created and tested. If they are not built, create them using the Supabase MCP and test them.

Once all test pass, update the @menuca-v3-backend.md document  Remember no need to build extra documentation for this task, @menuca-v3-backend.md is the only source of truth