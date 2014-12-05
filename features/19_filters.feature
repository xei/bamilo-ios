@all @filters
Feature: Catalog - Filters

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
* I wait for 5 seconds
* I touch list item number 1
* I wait to see the catalog
* I touch the filter button
* I wait to see the filters screen
* I wait for 1 seconds

Scenario: Filters Screen

@filters_af
Scenario: Apply Filter
* I touch the table list item number 0
* I wait for 1 seconds
* I touch the table list item number 0
* I wait for 1 seconds
* I touch done button
* I wait for 1 seconds
* I touch done button
* I wait for 1 seconds
* I wait to see the catalog

@filters_rf
Scenario: Remove Filter
* I touch the table list item number 0
* I wait for 1 seconds
* I touch the table list item number 0
* I wait for 1 seconds
* I touch done button
* I wait for 1 seconds
* I touch done button
* I wait for 1 seconds
* I wait to see the catalog
* I touch the filter button
* I wait for 1 seconds
* I wait to see the filters screen
* I touch the table list item number 0
* I wait for 1 seconds
* I touch the table list item number 0
* I wait for 1 seconds
* I touch done button
* I wait for 1 seconds
* I touch done button
* I wait for 1 seconds
* I wait to see the catalog
