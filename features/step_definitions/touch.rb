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