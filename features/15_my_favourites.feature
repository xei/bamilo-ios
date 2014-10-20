@all @my_favourites
Feature: My Favourites

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I verify if a promotion is showing
* I wait to see the home
* I touch the hamburger
* I wait to see the side menu
* I touch the my favourites option
* I wait to see the my favourites screen

Scenario: My Favourites Section

@my_favourites_db
Scenario: Delete Button
* I touch the hamburger
* I wait to see the side menu
* I touch the catagories option
* I wait for 1 seconds
* I touch list item number 3
* I wait for 1 seconds
* I touch list item number 1
* I wait to see the catalog
* I touch the favorites button
* I wait to see the message item added to favorites
* I wait for 1 seconds
* I touch the hamburger
* I touch the back button
* I wait for 1 seconds
* I touch the back button
* I wait to see the side menu
* I wait for 1 seconds
* I touch the my favourites option
* I wait to see the my favourites screen
* I touch the delete favourite button
* I wait to see the empty favourites screen

@my_favourites_ai
Scenario: Add all items to cart
* I touch the hamburger
* I wait to see the side menu
* I touch the catagories option
* I wait for 1 seconds
* I touch list item number 3
* I wait for 1 seconds
* I touch list item number 1
* I wait to see the catalog
* I touch the favorites button
* I wait to see the message item added to favorites
* I wait for 1 seconds
* I touch the hamburger
* I touch the back button
* I wait for 1 seconds
* I touch the back button
* I wait to see the side menu
* I wait for 1 seconds
* I touch the my favourites option
* I wait to see the my favourites screen
* I make sure the size is selected
* I touch the add all items to cart screen
* I wait to see the empty favourites screen
* I touch the cart button
* I wait to see the cart screen not empty