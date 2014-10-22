@all @native_checkout
Feature: Native Checkout

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I verify if a promotion is showing
* I wait to see the home
* I wait for 1 seconds
* I touch the hamburger
* I wait to see the side menu
* I make sure I am logged in
* I touch the catagories option
* I wait for 1 seconds
* I touch list item number 3
* I wait for 1 seconds
* I touch list item number 1
* I wait to see the catalog
* I touch collection view item number 2
* I wait for 2 seconds
* I wait to see the product detail screen
* I touch add to cart button
* I wait to see the product added message
* I touch the cart button
* I wait to see the cart screen
* I wait to see the cart screen not empty
* I touch the proceed to checkout button

@native_checkout_nc
Scenario: Native Checkout
* I wait for the shippping address screen
* I touch the next button
* I wait for the shipping method screen
* I touch the next button
* I wait to see the payment screen
* I touch the next button
* I wait to see the my order screen
* I touch the confirm order button
* I wait to see the thank you screen