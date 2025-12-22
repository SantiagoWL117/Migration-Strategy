La Maison du Burger (ID: 727) - 574 Boulevard Saint-Joseph, Hull
⚠️ Data Inconsistency Found:
Restaurant: NOT deleted ✅
All 12 courses: Soft-deleted on 2025-11-10 ❌
81 active dishes still reference deleted courses
This is an orphaned data situation. The combo duplicates exist but won't be visible to customers because their parent courses are deleted.
Options:
Fix the data structure first - Restore courses (or the restaurant may need a menu re-import)
Clean up duplicates anyway - Keep 1 combo per type, delete the other 12
Skip for now - Since the whole menu is in a broken state
What would you like to do with La Maison du Burger?


______________________________________________________________________
ok these are three perfect examples of the current logic of the legacy V1 CRM for special combo groups. 

Some special combo groups can have the dish_selections populated, like the case of Little Gyros and some don't, like the case of Centretown Donair & Pizza. 

The main purpose of the special combo groups is to allow the user to 


1. Allow the user to select from a group of different dishes one time and add modifiers to each of the selected dish. 
1.1 Amicci Pizza : Large Pizza with Wings dish -> 1 Large Pizza from Menu special combo group

 
2. Allow the user to select from a group of different dishes two or more times and add modifiers to each of the selected dish
2.1 Little Gyros Greek Grill -> Pita Combo for 2 dish -> Pita Combo for 2 special combo group

3. Allow the user to select the same dish two or more times and add modifiers to each of the selected dish 
3.1 Centretown Donair & Pizza -> 2 Small Donairs and Garlic Fingers -> 2 Small Donairs special combo group

Help me analyze if the current schema architecture for special combo groups support this cases