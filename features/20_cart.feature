@all @cart
Feature: Cart

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I verify if a promotion is showing
* I wait to see the home
* I wait for 1 seconds
#* I touch the hamburger
#* I wait to see the side menu
#* I make sure I am logged out
#* I touch login option on side menu
#* I wait for 2 seconds
#* I wait to see the login screen
#* I enter the right email and password
#* I touch the Login button
#* I wait to see the home

@cart_add
Scenario: Add to cart
* I touch the hamburger
* I wait to see the side menu
* I touch the catagories option
* I wait for 1 seconds
* I touch list item number 3
* I wait for 1 seconds
* I touch list item number 1
* I wait to see the catalog
* I wait for 1 seconds
* I touch collection view item number 1
* I wait for 2 seconds
* I wait to see the product detail screen
* I touch add to cart button
* I wait to see the product added message
* I touch the cart button
* I wait for 1 seconds
* I wait to see the cart screen
* I wait for 1 seconds
* I wait to see the cart screen not empty

@cart_change
Scenario: Change quantity
* I touch the cart button
* I wait for 1 seconds
* I wait to see the cart screen
* I wait for 1 seconds
* I wait to see the cart screen not empty
* I touch the quantity button
* I wait for 1 seconds
* I scroll down the quantity
* I wait for 1 seconds
* I touch done button

@cart_remove
Scenario: Remove form Cart
* I wait for 2 seconds
* I touch the cart button
* I wait for 1 seconds
* I wait to see the cart screen
* I wait for 1 seconds
* I wait to see the cart screen not empty
* I wait for 1 seconds
* I touch the remove from cart button
* I wait for 1 seconds
* I wait to see the shopping cart

@cart_empty
Scenario: Empty Cart
* I touch the cart button
* I wait for 1 seconds
* I wait to see the cart screen
* I wait for 1 seconds
* I wait to see the shopping cart

@cart_call
Scenario: Call to Order
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
* I touch add to cart button
* I wait for 1 seconds
* I wait to see the product added message
* I touch the cart button
* I wait for 1 seconds
* I wait to see the cart screen
* I should see call to order button

Scenario: Remove form Cart
* I wait for 2 seconds
* I touch the cart button
* I wait for 1 seconds
* I wait to see the cart screen
* I wait to see the cart screen not empty
* I wait for 1 seconds
* I touch the remove from cart button
* I wait for 1 seconds
* I wait to see the shopping cart