Then /^I touch the hamburger$/ do
    touch("view marked:'"+@hamburger_btn+"'")
end

Then /^I touch login option on side menu$/ do
    touch("view marked:'"+@login+"'")
end

Then /^I touch the Login button$/ do
    touch("view marked:'"+@login+"'")
end

Then /^I touch the Logout button$/ do
    touch("view marked:'"+@logout+"'")
end

Then /^I touch my account option on side menu$/ do
    touch("view marked:'"+@my_account+"'")
end

Then /^I change the notifications and sound settings$/ do
    touch("UISwitch marked:'"+@notifications+"'")
    touch("UISwitch marked:'"+@sound+"'")
end

Then /^I touch the user data option$/ do
    touch("view marked:'"+@user_data+"'")
end

Then /^I touch the Save button$/ do
    touch("view marked:'"+@save+"'")
end

Then /^I touch the email notification option$/ do
    touch("view marked:'"+@email_notifications+"'")
end

Then /^I change the newsletter settings$/ do
    touch("UISwitch marked:'"+@newsletter_male+"'")
    touch("UISwitch marked:'"+@newsletter_female+"'")
end

Then /^I touch the forgot password option$/ do
    touch("view marked:'"+@forgot_password+"'")
end

Then /^I touch the Submit button$/ do
    touch("view marked:'"+@submit+"'")
end

Then /^I touch the create account option$/ do
    touch("view marked:'"+@crate_account+"'")
end

Then /^I touch the Register button$/ do
    touch("view marked:'"+@register+"'")
end