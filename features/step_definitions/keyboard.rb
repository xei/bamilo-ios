Then /^I enter the wrong email and password$/ do
    touch("view marked:'"+@email+"'")
    keyboard_enter_text @invalid_email
    done
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @invalid_password
end

Then /^I enter the right email and password$/ do
    touch("view marked:'"+@email+"'")
    wait_for_keyboard
    #keyboard_enter_text @valid_email
    keyboard_enter_text "testcalabash"
    keyboard_enter_char "@"
    keyboard_enter_text "mailinator.com"
    done
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @valid_password
end

Then /^I enter the right email and wrong password$/ do
    touch("view marked:'"+@email+"'")
    #keyboard_enter_text @valid_email
    keyboard_enter_text "testcalabash"
    keyboard_enter_char "@"
    keyboard_enter_text "mailinator.com"
    done
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @invalid_password
end

Then /^I enter passwords not matching$/ do
    sleep(1)
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @valid_password
    done
    touch("view marked:'"+@retype_password+"'")
    keyboard_enter_text @invalid_password
end

Then /^I enter passwords smaller than 6 characters$/ do
    sleep(1)
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @password_min_6
    done
    touch("view marked:'"+@retype_password+"'")
    keyboard_enter_text @password_min_6
end

Then /^I enter passwords matching$/ do
    sleep(1)
    touch("view marked:'"+@password+"'")
    keyboard_enter_text @valid_password
    done
    touch("view marked:'"+@retype_password+"'")
    keyboard_enter_text @valid_password
end

Then /^I enter a invalid email$/ do
    touch("view marked:'"+@email+"'")
    sleep(1)
    keyboard_enter_text @invalid_email
    done
end

Then /^I enter a valid email$/ do
    touch("view marked:'"+@email+"'")
    sleep(2)
    #keyboard_enter_text @valid_email
    keyboard_enter_text "testcalabash"
    keyboard_enter_char "@"
    keyboard_enter_text "mailinator.com"
    done
end

Then /^I enter the registration data with an already registred email$/ do
    touch("view marked:'"+@birthday+"'")
    touch("view marked:'"+@done+"'")
    touch("view marked:'"+@gender+"'")
    touch("view marked:'"+@done+"'")
    touch("UISwitch marked:'"+@receive_newsletter+"'")
    touch("view marked:'"+@email+"'")
    #keyboard_enter_text @valid_email
    keyboard_enter_text "testcalabash"
    keyboard_enter_char "@"
    keyboard_enter_text "mailinator.com"
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

Then /^I enter the registration data with different password$/ do
    touch("view marked:'"+@birthday+"'")
    touch("view marked:'"+@done+"'")
    touch("view marked:'"+@gender+"'")
    touch("view marked:'"+@done+"'")
    touch("UISwitch marked:'"+@receive_newsletter+"'")
    touch("view marked:'"+@email+"'")
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
    done
    touch("view marked:'"+@newsletter+"'")
end

Then /^I enter the registration data$/ do
    touch("view marked:'"+@birthday+"'")
    touch("view marked:'2013'")
    touch("view marked:'"+@done+"'")
    touch("view marked:'"+@gender+"'")
    touch("view marked:'"+@done+"'")
    touch("UISwitch marked:'"+@receive_newsletter+"'")
    touch("view marked:'"+@email+"'")
    keyboard_enter_text @new_email
    #puts @new_email
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

Then /^I enter a valid search$/ do
    touch("view marked:'"+@search+"'")
    keyboard_enter_text @valid_search
    done
end

Then /^I enter a valid search without press search$/ do
    touch("view marked:'"+@search+"'")
    keyboard_enter_text @valid_search
end

Then /^I enter an invalid search$/ do
    touch("view marked:'"+@search+"'")
    keyboard_enter_text @invalid_search
    done
end

Then /^I enter a review$/ do
    touch("view marked:'"+@name+"'")
    keyboard_enter_text @review_name
    done
    keyboard_enter_text @review_title
    done
    keyboard_enter_text @review_comment
    done
end

Then /^I enter a (valid|invalid) order$/ do |option|
    res = element_exists("view marked:'"+@order_id+"'")
    if res == true
        touch("view marked:'"+@order_id+"'")
    else
        res_2 = element_exists("view marked:'"+@track_order_id_valid+"'")
        if res_2 == true
            touch("view marked:'"+@track_order_id_valid+"'")
            wait_for_keyboard
            #touch("view marked:'"+@keyboard_delete_key+"'")
            #TODO
            #keyboard_enter_char 'Delete'
            set_text("textField index:0", "")
            #keyboard_enter_text('Delete')
        else
            touch("view marked:'"+@track_order_id_invalid+"'")
            wait_for_keyboard
            #touch("view marked:'"+@keyboard_delete_key+"'")
            #TODO
            #touch("button marked:'Select All'")
            #keyboard_enter_char 'Delete'
            set_text("textField index:0", "")
            #keyboard_enter_text('Delete')
        end
    end
    case option.to_s
    when "valid"
    	keyboard_enter_text @track_order_id_valid
    when "invalid"
        keyboard_enter_text @track_order_id_invalid
    end
end