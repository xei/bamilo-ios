Then /^I wait to see the home$/ do
    wait_for_elements_exist("view marked:'"+@fashion+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the side menu$/ do
    wait_for_elements_exist("view marked:'"+@shopping_cart+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the login screen$/ do
    wait_for_elements_exist("view marked:'"+@credentials+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error form validation failed$/ do
    wait_for_elements_exist("view marked:'"+@error_form_validation+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error check your username and password$/ do
    wait_for_elements_exist("view marked:'"+@error_check_username+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the login option$/ do
    wait_for_elements_exist("view marked:'"+@login+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the my account screen$/ do
    wait_for_elements_exist("view marked:'"+@account_settings+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the user data section$/ do
    wait_for_elements_exist("view marked:'"+@your_personal_data+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error empty fields$/ do
    wait_for_elements_exist("view marked:'"+@error_empty_fields+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error password did not match$/ do
    wait_for_elements_exist("view marked:'"+@error_password_not_match+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error min 6 characters$/ do
    wait_for_elements_exist("view marked:'"+@error_min_characters+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the message password changed with success$/ do
    wait_for_elements_exist("view marked:'"+@password_changed_success+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the email notifications section$/ do
    wait_for_elements_exist("view marked:'"+@newsletters_subscribed+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the message preferences updated$/ do
    wait_for_elements_exist("view marked:'"+@preferences_updated+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the forgot password section$/ do
    wait_for_elements_exist("view marked:'"+@please_type_email+"'", :timeout => @wait_timeout)
end

Then /^I wait see the error please fill in the email$/ do
    wait_for_elements_exist("view marked:'"+@error_empty_fields_fp+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error please check your input fields$/ do
    wait_for_elements_exist("view marked:'"+@error_please_check_input+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the message sent successfully$/ do
    wait_for_elements_exist("view marked:'"+@email_sent+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the create account page$/ do
    wait_for_elements_exist("view marked:'"+@account_data+"'", :timeout => @wait_timeout)
end