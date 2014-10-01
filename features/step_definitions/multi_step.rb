Then /^I make sure I am logged out$/ do
    res = query("view marked:'"+@logout+"'")
    #res_string = "..." + res.to_s + "..."
    #puts res_string
    if res.to_s == "[]"
        #puts "Login"
        #OK
    else
        #puts "Logout"
        #Need Logout
        touch("view marked:'"+@logout+"'")
        wait_for_elements_exist("view marked:'"+@login+"'", :timeout => 5)
    end
end

Then /^I make sure I am logged in$/ do
    res = query("view marked:'"+@logout+"'")
    #res_string = "..." + res.to_s + "..."
    #puts res_string
    if res.to_s == "[]"
        #puts "Login"
        #Need Login
        #touch("view marked:'"+@logout+"'")
        #wait_for_elements_exist("view marked:'"+@login+"'", :timeout => 5)
        
        step "I touch login option on side menu"
        step "I wait to see the login screen"
        step "I enter the right email and password"
        step "I touch the Login button"
        step "I wait to see the home"
    else
        #puts "Logout"
        #OK
    end
end