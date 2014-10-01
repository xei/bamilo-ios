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