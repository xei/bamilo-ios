# Requiring this file will import Calabash and the Calabash predefined Steps.
require 'calabash-cucumber/cucumber'

# To use Calabash without the predefined Calabash Steps, uncomment these
# three lines and delete the require above.
# require 'calabash-cucumber/wait_helpers'
# require 'calabash-cucumber/operations'
# World(Calabash::Cucumber::Operations)

def initvars
    
    #home
    @fashion = "Fashion"
    
    #side bar
    @hamburger_btn = "btn menu"
    @shopping_cart = "Shopping Cart"
    @login = "Login"
    @logout = "Logout"
    @my_account = "My Account"
    
    #login
    @credentials = "Credentials"
    @error_form_validation = "Form Validation Failed."
    @error_check_username = "Check your username and password"
    @e_mail = "E-Mail"
    @password = "Password"
    @invalid_email = "Email@invalido.com"
    @invalid_password = "umapasswordqualquer"
    @valid_email = "testcalabash@mailinator.com"
    @valid_password = "password1"
    
    
    
end
