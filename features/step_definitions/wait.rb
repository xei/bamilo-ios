Then /^I wait to see the home$/ do
    wait_for_elements_exist("view marked:'"+@fashion+"'", :timeout => 5)
end

Then /^I wait to see the side menu$/ do
    wait_for_elements_exist("view marked:'"+@shopping_cart+"'", :timeout => 5)
end

Then /^I wait to see the login screen$/ do
    wait_for_elements_exist("view marked:'"+@credentials+"'", :timeout => 5)
end

Then /^I wait to see the error form validation failed$/ do
    wait_for_elements_exist("view marked:'"+@error_form_validation+"'", :timeout => 5)
end

Then /^I wait to see the error check your username and password$/ do
    wait_for_elements_exist("view marked:'"+@error_check_username+"'", :timeout => 5)
end

Then /^I wait to see the login option$/ do
    wait_for_elements_exist("view marked:'"+@login+"'", :timeout => 5)
end

Then /^I wait to see the my account screen$/ do
    wait_for_elements_exist("view marked:'"+@account_settings+"'", :timeout => 5)
end

Then /^I wait to see the user data section$/ do
    wait_for_elements_exist("view marked:'"+@your_personal_data+"'", :timeout => 5)
end

Then /^I wait to see the error empty fields$/ do
    wait_for_elements_exist("view marked:'"+@error_empty_fields+"'", :timeout => 5)
end

Then /^I wait to see the error password did not match$/ do
    wait_for_elements_exist("view marked:'"+@error_password_not_match+"'", :timeout => 5)
end

Then /^I wait to see the error min 6 characters$/ do
    wait_for_elements_exist("view marked:'"+@error_min_characters+"'", :timeout => 5)
end

Then /^I wait to see the message password changed with success$/ do
    wait_for_elements_exist("view marked:'"+@password_changed_success+"'", :timeout => 5)
end

Then /^I wait to see the email notifications section$/ do
    wait_for_elements_exist("view marked:'"+@newsletters_subscribed+"'", :timeout => 5)
end

Then /^I wait to see the message preferences updated$/ do
    wait_for_elements_exist("view marked:'"+@preferences_updated+"'")
end