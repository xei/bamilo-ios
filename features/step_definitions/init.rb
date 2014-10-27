Then /^I call the variables$/ do
    ##FR - EG,CI,MA | EN - CM,GH,KE,NG,UG
    puts $country
    case $country
        when "EG","CI","MA"
            puts "FR"
        when "CM","GH","KE","NG","UG"
            puts "EN"
    end
    
    initvars
end