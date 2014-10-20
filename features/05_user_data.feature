@all @user_data
Feature: My Account - User Data

Background:
* I call the variables
* I wait for 5 seconds
* I wait to see if the choose country screen shows
* I wait to see the home
* I touch the hamburger
* I wait to see the side menu
* I make sure I am logged in
* I touch my account option on side menu
* I wait to see the my account screen
* I wait for 1 seconds
* I touch the user data option
* I wait to see the user data section

@user_data_se
Scenario: User Data Section

@user_data_ef
Scenario: Change Password Empty Fields
* I touch the Save button
* I wait to see the error change password empty fields

@user_data_dp
Scenario: Change Password Different Password
* I enter passwords not matching
* I touch the Save button
* I wait to see the error password did not match

@user_data_lc
Scenario: Change Password Less than 6 characters
* I enter passwords smaller than 6 characters
* I touch the Save button
* I wait to see the error min 6 characters

@user_data_su
Scenario: Change Password Successfully
* I enter passwords matching
* I touch the Save button
* I wait to see the message password changed with success

