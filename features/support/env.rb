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
    
    #my account
    @account_settings = "Account Settings"
    @notification_settings = "Notification Settings"
    @user_data = "User Data"
    @email_notifications = "Email Notifications"
    @notifications = "Notifications"
    @sound = "Sound"
    
    #user data
    @your_personal_data = "Your Personal Data"
    @retype_password = "Re-type password"
    @save = "Save"
    @error_empty_fields = "Empty Fields"
    @error_min_characters = "Min 6 characters"
    @error_password_not_match = "Passwords did not match"
    @password_min_6 = "12345"
    @password_changed_success = "Password changed with success."
    
    #email notifications
    @newsletters_subscribed = "Newsletters Subscribed"
    @newsletter_male = "Newsletter Male"
    @newsletter_female = "Newsletter Female"
    @preferences_updated = "Preferences updated"
    
    
    
end
