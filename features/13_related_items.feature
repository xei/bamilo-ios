@all @related_items
Feature: Product Details - Related Items

Background:
* I call the variables
* I wait for 5 seconds
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
* I touch collection view item number 1
* I wait for 2 seconds
* I wait to see the product detail screen

@related_items_ov
Scenario: Related Items Overview
* I scroll down
* I should see the related items

#TODO
Scenario: Navigate throw the products
#scroll("UIScrollView index:2", :right)

#TODO
Scenario: Related items from search product

#TODO
Scenario: Related items from home product