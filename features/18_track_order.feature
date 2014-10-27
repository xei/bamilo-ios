@all @track_order
Feature: Track Order

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I verify if a promotion is showing
* I wait to see the home
* I touch the hamburger
* I wait to see the side menu
* I touch the track order option
* I wait to see the track order screen
* I wait for 1 seconds

Scenario: Track Order Screen

@track_order_va
Scenario: Track Valid
* I enter a valid order
* I touch the track order button
* I wait to see the valid order information

@track_order_in
Scenario: Track Invalid
* I enter a invalid order
* I touch the track order button
* I wait to see the invalid order information

@track_order_vi
Scenario: Track Valid and Invalid
* I enter a valid order
* I touch the track order button
* I wait to see the valid order information
* I enter a invalid order
* I touch the track order button
* I wait to see the invalid order information

@track_order_iv
Scenario: Track Invalid and Valid
* I enter a invalid order
* I touch the track order button
* I wait to see the invalid order information
* I enter a valid order
* I touch the track order button
* I wait to see the valid order information

@track_order_vv
Scenario: Track Valid and Valid
* I enter a valid order
* I touch the track order button
* I wait to see the valid order information
* I enter a valid order
* I touch the track order button
* I wait to see the valid order information

@track_order_oe
Scenario: Track Order empty
* I touch the track order button
* I wait to see the error track order field empty