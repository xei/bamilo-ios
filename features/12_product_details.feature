@all @pdv
Feature: Product Details

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
* I scroll down
* I touch the rate button
* I should see the rating screen

@pdv_wr
Scenario: Write Review
* I scroll down
* I touch the rate button
* I should see the rating screen
* I enter a review
* I wait for 1 seconds
* I touch send review button
* I wait to see the message review sent

@pdv_sh
Scenario: Share
* I touch the share image button
* I wait to see the mail option
* I touch cancel option

#TODO
@pdv_fs
Scenario: Full screen image

#TODO
@pdv_zo
Scenario: Zoom in and out
* I pinch to zoom in
* I pinch to zoom out

#TODO
@pdv_do
Scenario: Done in product zoom page

@pdv_fa
Scenario: Favourites
* I touch the favorites button
* I wait to see the message item added to favorites
* I touch the favorites button
* I wait to see the message item removed from favorites
