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