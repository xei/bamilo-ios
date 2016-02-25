Then /^I call the variables$/ do
    ##FR - EG,CI,MA | EN - CM,GH,KE,NG,UG
    puts $country
    case $country
        when "CI","MA","CM"
            puts "FR"
            initvars_fr
        when "EG","GH","KE","NG","UG"
            puts "EN"
            initvars
    end
end