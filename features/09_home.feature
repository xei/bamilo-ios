@all @home
Feature: Home

Background:
* I call the variables
* I wait to see the home
* I wait for 1 seconds

Scenario: Home section

@home_pc
Scenario: Popular Categories and Top Brands
* I should see the popular categories
#* I scroll down
#* I scroll up
* I wait for 2 seconds
* I swipe down
* I wait for 2 seconds
* I swipe up
* I wait for 2 seconds
* I should see the top brands

Scenario: Side Bar
* I touch the hamburger
* I wait to see the side menu

