@all @login
Feature: Login

Background:
* I call the variables
* I wait to see the home
* I touch the hamburger
* I wait to see the side menu
* I touch login option on side menu
* I wait to see the login screen

@login_ef
Scenario: Login Empty Fields
* I touch the Login button
* I wait to see the error form validation failed

@login_wu
Scenario: Login Wrong Username
* I enter the wrong email and password
* I touch the Login button
* I wait to see the error check your username and password

@login_wp
Scenario: Login Wrong Password
* I enter the right email and wrong password
* I touch the Login button
* I wait to see the error check your username and password

@login_s
Scenario: Login Successfull
* I enter the right email and password
* I touch the Login button
* I wait to see the home