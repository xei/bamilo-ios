@all @forgot_password
Feature: Login - Forgot Password

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I wait to see the home
* I touch the hamburger
* I wait to see the side menu
* I make sure I am logged out

Scenario: Logout

@password_recovery_ef
Scenario: Password Recovery Empty Fields
* I touch login option on side menu
* I wait to see the login screen
* I wait for 1 seconds
* I touch the forgot password option
* I wait to see the forgot password section
* I touch the Submit button
* I wait for 1 seconds
* I wait to see the error please check your input fields
#* I wait see the error empty fields on forgot password

@password_recovery_nr
Scenario: Password Recovery Non Registred Email
* I touch login option on side menu
* I wait to see the login screen
* I wait for 1 seconds
* I touch the forgot password option
* I wait to see the forgot password section
* I wait for 5 seconds
* I enter a invalid email
* I touch the Submit button
* I wait for 1 seconds
* I wait to see the error please check your input fields

@password_recovery_su
Scenario: Password Recovery Successfully
* I touch login option on side menu
* I wait to see the login screen
* I wait for 1 seconds
* I touch the forgot password option
* I wait to see the forgot password section
* I wait for 5 seconds
* I enter a valid email
* I touch the Submit button
* I wait for 1 seconds
* I wait to see the message sent successfully