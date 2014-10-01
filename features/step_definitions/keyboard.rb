Then /^I enter the wrong email and password$/ do
    touch("view marked:'"+@e_mail+"'")
    keyboard_enter_text @invalid_email
    done
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @invalid_password
end

Then /^I enter the right email and password$/ do
    touch("view marked:'"+@e_mail+"'")
    keyboard_enter_text @valid_email
    done
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @valid_password
end

Then /^I enter the right email and wrong password$/ do
    touch("view marked:'"+@e_mail+"'")
    keyboard_enter_text @valid_email
    done
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @invalid_password
end

Then /^I enter passwords not matching$/ do
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @valid_password
    done
    touch("view marked:'"+@retype_password+"'")
    keyboard_enter_text @invalid_password
end

Then /^I enter passwords smaller than 6 characters$/ do
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @password_min_6
    done
    touch("view marked:'"+@retype_password+"'")
    keyboard_enter_text @password_min_6
end

Then /^I enter passwords matching$/ do
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @valid_password
    done
    touch("view marked:'"+@retype_password+"'")
    keyboard_enter_text @valid_password
end
