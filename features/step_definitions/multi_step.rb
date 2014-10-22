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
        step "I touch the hamburger"
    else
        #puts "Logout"
        #OK
    end
end

Then /^I wait to see if the choose country screen shows$/ do
    #res = wait_for(:timeout => 5) { element_exists("view marked:'"+@choose_country+"'") }
    res = query("view marked:'"+@choose_country+"'")
    if res.to_s == "[]"
        #puts "not found"
    else
        #puts "found"
        touch("view marked:'Nigeria'")
        touch("view marked:'"+@apply+"'")
    end
end

Then /^I wait to see if the choose country screen shows and choose one$/ do
    puts $country
    case $country
    when "CM"
        country_choosed = @country_cm
    when "EG"
        country_choosed = @country_eg
    when "CI"
        country_choosed = @country_ci
    when "GH"
        country_choosed = @country_gh
    when "KE"
        country_choosed = @country_ke
    when "MA"
        country_choosed = @country_ma
    when "NG"
        country_choosed = @country_ng
    when "UG"
        country_choosed = @country_ug
    end
    puts country_choosed
    #res = wait_for(:timeout => 5) { element_exists("view marked:'"+@choose_country+"'") }
    res = query("view marked:'"+@choose_country+"'")
    if res.to_s == "[]"
        #puts "not found"
        step "I touch the hamburger"
        step "I wait to see the side menu"
        touch("view marked:'"+@choose_country+"'")
        sleep(1)
        touch("view marked:'"+country_choosed+"'")
        touch("view marked:'"+@apply+"'")
        sleep(5)
        else
        #puts "found"
        touch("view marked:'"+country_choosed+"'")
        touch("view marked:'"+@apply+"'")
        sleep(5)
    end
end