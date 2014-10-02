@all @registration
Feature: Registration
#TODO: one button instead of two, newsletter

Background:
* I call the variables
* I wait to see the home
* I touch the hamburger
* I wait to see the side menu
* I touch login option on side menu
* I wait to see the login screen
* I wait for 1 seconds
* I touch the create account option
* I wait to see the create account page
* I wait for 1 seconds

Scenario: Logout
* I touch the hamburger
* I wait to see the side menu
* I make sure I am logged out

@registration_ef
Scenario: Registration Empty Fields
* I touch the Register button
* I wait to see the error please check your input fields

@registration_se
Scenario: Registration Same Email
* I enter the registration data with an already registred email
* I touch the Register button
* I wait to see the error please check your input fields

@registration_dp
Scenario: Registration Different Password
* I enter the registration data with different password
* I touch the Register button
* I wait to see the error please check your input fields

#TODO
@registration_tc
Scenario: Registration Terms and Conditions

@registration_nc
Scenario: Registration Newletter Checkbox
* I should see the newsletter checkbox

@registration_rs
Scenario: Registration Successfully
* I enter the registration data
* I touch the Register button
* I wait to see the home