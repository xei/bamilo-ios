@all @search
Feature: Search

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I verify if a promotion is showing
* I wait to see the home
* I wait for 1 seconds
* I touch the hamburger
* I wait to see the side menu
* I should see the search section

Scenario: Search Section

Scenario: Search Valid
* I enter a valid search
* I wait to see the catalog

Scenario: Search Invalid
* I enter an invalid search
* I wait to see the no results found screen

@search_ss
Scenario: Search Suggestions
* I enter a valid search without press search
* I wait for 1 seconds
* I touch the table list item number 0
* I wait to see the catalog

@search_sp
Scenario: Related items from search product
* I enter a valid search
* I wait to see the catalog
* I touch collection view item number 1
* I wait for 2 seconds
* I wait to see the product detail screen
* I scroll down
* I should see the related items