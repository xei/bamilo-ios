@all @side_menu
Feature: Side Menu

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I verify if a promotion is showing
* I wait to see the home
* I touch the hamburger
* I wait to see the side menu

@side_menu_ov
Scenario: Side menu Overview
* I should see all the side menu options

@side_menu_sc
Scenario: Shopping cart
* I touch the shopping cart in the side menu
* I wait to see the shopping cart

@side_menu_hm
Scenario: Home
* I touch the home in the side menu
* I wait to see the home

@side_menu_ca
Scenario: Categories
* I touch the categories
* I wait to see the categories

@side_menu_cc
Scenario: Choose country
* I touch the choose country option
* I wait to see the choose country screen