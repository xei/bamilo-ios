@all @search
Feature: Search

Background:
* I call the variables
* I wait for 5 seconds
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

#TODO
#Scenario: Search Suggestions

