@all @email_notifications
Feature: My Account - Email Notifications

Background:
* I call the variables
* I wait to see the home
* I touch the hamburger
* I wait to see the side menu
* I touch my account option on side menu
* I wait to see the my account screen
* I wait for 1 seconds

@email_notifications_lo
Scenario: Logout
* I touch the hamburger
* I wait to see the side menu
* I make sure I am logged out

@email_notifications_wl
Scenario: Email Notifications Section Without Login
* I touch the email notification option
* I wait to see the login screen

@email_notifications_li
Scenario: Login
* I touch the hamburger
* I wait to see the side menu
* I make sure I am logged in

@email_notifications_se
Scenario: Email Notifications Section
* I touch the email notification option
* I wait to see the email notifications section

@email_notifications_no
Scenario: Change Email Notifications
* I touch the email notification option
* I wait to see the email notifications section
* I change the newsletter settings
* I touch the Save button
* I wait to see the message preferences updated