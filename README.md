# README

# Database comments: 

I'm keeping as strings in te recipes table authors and categories since no other data is attached to this entities. 

Please run rails db:seed if necessary to seed the database. 

# User stories

User Story 1: Search Recipes with a Single Core Ingredient
----------------------------------------------------------
As a user,
I want to search for recipes that contain a core ingredient I have,
So that I can quickly find recipes that match the key ingredient I want to cook with.

Acceptance Criteria:

Users can search for recipes using one core ingredient (e.g., "Chicken", "Tomato", "Pesto").

The app will return all recipes that contain that ingredient, whether it's in the title or the list of ingredients.

Recipes that do not contain the searched ingredient should not be displayed.

The results should include a list of recipes with the title, ratings, and key details for quick preview.

Example:
Search term: "Chicken"

Expected result: Recipes that have chicken in title first, ordered by rating. Recipes with chicken within their ingredients, even when the title doesn't contains "chicken". 

User Story 2: Search Recipes with Three Ingredients, One Being Core
-------------------------------------------------------------------
As a user,
I want to search for recipes that contain at least one core ingredient I have, but also match two other ingredients from my fridge,
So that I can find recipes based on a more diverse selection of ingredients.

Acceptance Criteria:
Users can search for recipes using three ingredients, with one of them being a core ingredient they want to use.

The app should return recipes that contain all of the specified ingredients.

If any recipe lacks even one of the ingredients, it will appear below in the results / later pages.

Example:
Search term: "chicken curry broccoli"

Expected result: Recipes that contain Chicken, Curry, and Broccoli (e.g., "Chicken and Broccoli Curry"). Recipes matching the three ingredients will be shown first, ordered by rating. Then, recipes with two or one of the ingredients in title, an then recipes with the ingredients, but title doesn't contains them. 

User Story 3: Search Recipes Using Random Ingredients in My Fridge
------------------------------------------------------------------
As a user,
I want to search for recipes using a set of random ingredients I currently have in my fridge,
So that I can make a meal without needing to go shopping for additional items.

Acceptance Criteria:
Users can search for recipes using multiple random ingredients (e.g., "Cucumber", "Eggplant", "Cheese", "Olive Oil").

The app will return recipes that include any of the listed ingredients, but it should match the ingredients closely or be flexible enough to suggest recipes that might have similar substitutes.

If the recipe doesn't contain all the listed ingredients, it should still be included as long as some match.

Results should prioritize recipes with the most ingredients that match those in the fridge.

Example:
Search term: "onion eggplant cheese olives"

Expected result: Recipes that use any combination of the listed ingredients, like "Pesto Chicken Casserole with Feta Cheese and Olives " or "Backed Eggplant with Garlic and Cheese". Recipes with just two ingredients (like "Eggplant Parmesan" with cheese and olive oil) should also appear.






