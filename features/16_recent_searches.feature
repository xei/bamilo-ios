@all @recent_searches
Feature: Recent Searches

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I verify if a promotion is showing
* I wait to see the home
* I touch the hamburger
* I wait to see the side menu
* I touch the recent searches option
* I should see the recent searches screen
* I wait for 1 seconds

Scenario: Recent Searches Screen

Scenario: Dummy Search
* I touch the hamburger
* I wait to see the side menu
* I should see the search section
* I enter a valid search
* I wait to see the catalog

@recent_searches_rs
Scenario: Touch a recent search
* I wait for 1 seconds
* I touch the table list item number 0
* I wait to see the catalog

@recent_searches_cs
Scenario: Clear recent searches
* I touch the clear recent searches button
* I wait to see the no recent searches screen

