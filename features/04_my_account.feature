@all @my_account
Feature: My Account

Background:
* I call the variables
* I wait to see the home
* I touch the hamburger
* I wait to see the side menu

Scenario: Login before My Account
* I touch login option on side menu
* I wait to see the login screen
* I enter the right email and password
* I touch the Login button
* I wait to see the home

@my_account_s
Scenario: My Account Section
* I touch my account option on side menu
* I wait to see the my account screen
* I should see the Account Settings section
* I should see the Notification Settings

@my_account_vs
Scenario: Vibrate and Sound
* I touch my account option on side menu
* I wait to see the my account screen
* I wait for 2 seconds
* I change the notifications and sound settings
* I wait for 2 seconds