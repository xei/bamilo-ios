@all @pdv
Feature: Product Details

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I verify if a promotion is showing
* I wait to see the home
* I wait for 1 seconds
* I touch the hamburger
* I wait to see the side menu
* I touch the catagories option
* I wait for 1 seconds
* I touch list item number 5
* I wait for 1 seconds
* I touch list item number 4
* I wait to see the catalog
* I touch collection view item number 2
* I wait for 2 seconds
* I wait to see the product detail screen

@pdv_po
Scenario: Product Overview

@pdv_ps
Scenario: Product Specifications
* I scroll down
* I touch the specification option
* I should see the product features
* I should see the product desctiption

@pdv_ro
Scenario: Review Overview
#* I scroll down
* I touch the rate button
* I wait for 1 seconds
* I should see the rating screen

@pdv_wr
Scenario: Write Review
#* I scroll down
* I touch the rate button
* I wait for 1 seconds
* I should see the rating screen
* I touch the write review button
* I wait for 2 seconds
* I enter a review
* I wait for 1 seconds
* I touch send review button
* I wait to see the message review sent

@pdv_sh
Scenario: Share
* I touch the share image button
* I wait to see the mail option
* I touch cancel option

@pdv_fs
Scenario: Full screen image
* I touch the product detail image
* I touch done button

@pdv_zo
Scenario: Zoom in and out
* I touch the product detail image
* I pinch to zoom in
* I pinch to zoom out
* I touch done button

@pdv_do
Scenario: Done in product zoom page
* I wait for 2 seconds
* I touch the product detail image
* I pinch to zoom in
* I pinch to zoom out
* I touch done button

@pdv_clean_favs
Scenario: Clean Favourites
* I touch the cart button
* I wait for 3 seconds
* I touch the hamburger
* I wait for 1 seconds
* I touch the back button
* I wait for 1 seconds
* I touch the back button
* I wait for 1 seconds
* I touch the my favourites option
* I wait to see the my favourites screen
* I wait for 2 seconds
* I make sure I have no favourites

@pdv_fa
Scenario: Favourites
* I touch the favorites button
* I wait to see the message item added to favorites
* I wait for 6 seconds
* I touch the favorites button
* I wait to see the message item removed from favorites
