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

Then /^I enter a invalid email$/ do
    touch("view marked:'"+@e_mail+"'")
    keyboard_enter_text @invalid_email
    done
end

Then /^I enter a valid email$/ do
    touch("view marked:'"+@e_mail+"'")
    keyboard_enter_text @valid_email
    done
end

Then /^I enter the registration data with an already registred email$/ do
    touch("view marked:'"+@birthday+"'")
    touch("view marked:'"+@done+"'")
    touch("view marked:'"+@gender+"'")
    touch("view marked:'"+@done+"'")
    touch("UISwitch marked:'"+@receive_newsletter+"'")
    touch("view marked:'"+@e_mail+"'")
    keyboard_enter_text @valid_email
    done
    keyboard_enter_text @first_name_text
    done
    keyboard_enter_text @last_name_text
    done
    keyboard_enter_text @valid_password
    done
    keyboard_enter_text @valid_password
    touch("view marked:'"+@newsletter+"'")
end

Then /^I enter the registration data with different password$/ do
    touch("view marked:'"+@birthday+"'")
    touch("view marked:'"+@done+"'")
    touch("view marked:'"+@gender+"'")
    touch("view marked:'"+@done+"'")
    touch("UISwitch marked:'"+@receive_newsletter+"'")
    touch("view marked:'"+@e_mail+"'")
    keyboard_enter_text @new_email
    puts @new_email
    done
    keyboard_enter_text @first_name_text
    done
    keyboard_enter_text @last_name_text
    done
    keyboard_enter_text @valid_password
    done
    keyboard_enter_text @invalid_password
    touch("view marked:'"+@newsletter+"'")
end

Then /^I enter the registration data$/ do
    touch("view marked:'"+@birthday+"'")
    touch("view marked:'2013'")
    touch("view marked:'"+@done+"'")
    touch("view marked:'"+@gender+"'")
    touch("view marked:'"+@done+"'")
    touch("UISwitch marked:'"+@receive_newsletter+"'")
    touch("view marked:'"+@e_mail+"'")
    keyboard_enter_text @new_email
    puts @new_email
    done
    keyboard_enter_text @first_name_text
    done
    keyboard_enter_text @last_name_text
    done
    keyboard_enter_text @valid_password
    done
    keyboard_enter_text @valid_password
    done
    touch("view marked:'"+@newsletter+"'")
end