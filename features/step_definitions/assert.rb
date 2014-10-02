Then /^I should see the Account Settings section$/ do
    check_element_exists("view marked:'"+@account_settings+"'")
end

Then /^I should see the Notification Settings$/ do
    check_element_exists("view marked:'"+@notification_settings+"'")
end

Then /^I should see the newsletter checkbox$/ do
    check_element_exists("view marked:'"+@newsletter+"'")
end

Then /^I should see the popular categories$/ do
    check_element_exists("view marked:'"+@popular_categories+"'")
    touch("view marked:'"+@popular_categories+"'")
end

Then /^I should see the top brands$/ do
    check_element_exists("view marked:'"+@top_brands+"'")
end