Then /^I should see the Account Settings section$/ do
    check_element_exists("view marked:'"+@account_settings+"'")
end

Then /^I should see the Notification Settings$/ do
    check_element_exists("view marked:'"+@notification_settings+"'")
end