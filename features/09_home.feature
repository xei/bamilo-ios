@all @home
Feature: Home

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I wait for 5 seconds
* I verify if a promotion is showing
* I wait to see the home
* I wait for 1 seconds

@home_se
Scenario: Home section

@home_pc
Scenario: Popular Categories and Top Brands
#* I scroll to cell with "teaserPageScrollView" label
* I scroll down the quantity
#* I swipe down inside home
* I wait for 1 seconds
* I should see the popular categories
#* I should see the top brands

@home_sb
Scenario: Side Bar
* I touch the hamburger
* I wait to see the side menu

