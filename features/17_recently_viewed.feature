@all @recently_viewed
Feature: Recently Viewed

Background:
* I call the variables
* I wait for 5 seconds
* I verify if a promotion is showing
* I wait to see the home
* I touch the hamburger
* I wait to see the side menu
* I touch the recently viewed option
* I wait to see the recently viewed screen
* I wait for 1 seconds

Scenario: Recently Viewed Screen

Scenario: Dummy View
* I touch the hamburger
* I wait to see the side menu
* I touch the catagories option
* I wait for 1 seconds
* I touch list item number 3
* I wait for 1 seconds
* I touch list item number 1
* I wait to see the catalog
* I touch collection view item number 1
* I wait for 2 seconds
* I wait to see the product detail screen

@recently_viewed_cs
Scenario: Clear recently viewed
* I touch the clear recently viewed button
* I wait to see the no recently viewed products screen

#TODO
#Scenario: Touch a recently viewed