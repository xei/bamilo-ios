@all @catalog
Feature: Catalog

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I verify if a promotion is showing
* I wait to see the home
* I wait for 1 seconds
* I touch the hamburger
* I wait to see the side menu
* I touch the catagories option
* I wait for 1 seconds
* I touch list item number 3
* I wait for 1 seconds
* I touch list item number 1
* I wait to see the catalog

Scenario: Catalog Section

Scenario: List/Grid View
* I touch the grid button

@catalog_fav
Scenario: Favorites
* I touch the favorites button
* I wait to see the message item added to favorites
* I touch the favorites button
* I wait to see the message item removed from favorites

@catalog_sort
Scenario: Sorting
* I swipe right
* I wait for 1 seconds
* I should see the filter best rating
* I swipe left
* I swipe left
* I wait for 1 seconds
* I should see the filter popularity
* I swipe left
* I wait for 1 seconds
* I should see the filter new in
* I swipe left
* I wait for 1 seconds
* I should see the filter price up
* I swipe left
* I wait for 1 seconds
* I should see the filter price down
* I swipe left
* I wait for 1 seconds
* I should see the filter name
* I swipe left
* I wait for 1 seconds
* I should see the filter brand

@catalog_up
Scenario: Scroll up button
* I scroll down
* I touch the scroll up button