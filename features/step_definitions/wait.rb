Then /^I wait to see the home$/ do
    wait_for_elements_exist("view marked:'"+@fashion+"'", :timeout => @wait_timeout_a_lot)
end

Then /^I wait to see the side menu$/ do
    wait_for_elements_exist("view marked:'"+@shopping_cart+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the login screen$/ do
    wait_for_elements_exist("view marked:'"+@credentials+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error form validation failed$/ do
    wait_for_elements_exist("view marked:'"+@error_form_validation+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error check your username and password$/ do
    wait_for_elements_exist("view marked:'"+@error_check_username+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the login option$/ do
    wait_for_elements_exist("view marked:'"+@login+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the my account screen$/ do
    wait_for_elements_exist("view marked:'"+@account_settings+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the user data section$/ do
    wait_for_elements_exist("view marked:'"+@your_personal_data+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error empty fields$/ do
    wait_for_elements_exist("view marked:'"+@error_empty_fields+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error password did not match$/ do
    wait_for_elements_exist("view marked:'"+@error_password_not_match+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error min 6 characters$/ do
    wait_for_elements_exist("view marked:'"+@error_min_characters+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the message password changed with success$/ do
    wait_for_elements_exist("view marked:'"+@password_changed_success+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the email notifications section$/ do
    wait_for_elements_exist("view marked:'"+@newsletters_subscribed+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the message preferences updated$/ do
    wait_for_elements_exist("view marked:'"+@preferences_updated+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the forgot password section$/ do
    wait_for_elements_exist("view marked:'"+@please_type_email+"'", :timeout => @wait_timeout)
end

Then /^I wait see the error please fill in the email$/ do
    wait_for_elements_exist("view marked:'"+@error_empty_fields_fp+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error please check your input fields$/ do
    wait_for_elements_exist("view marked:'"+@error_please_check_input+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the message sent successfully$/ do
    wait_for_elements_exist("view marked:'"+@email_sent+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the create account page$/ do
    wait_for_elements_exist("view marked:'"+@account_data+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the catalog$/ do
    wait_for_elements_exist("view marked:'"+@popularity+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the no results found screen$/ do
    wait_for_elements_exist("view marked:'"+@message_no_search_found+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the message item added to favorites$/ do
    wait_for_elements_exist("view marked:'"+@message_item_add_favourites+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the message item removed from favorites$/ do
    wait_for_elements_exist("view marked:'"+@message_item_removed_favourites+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the product detail screen$/ do
    wait_for_elements_exist("view marked:'"+@share_button+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the message review sent$/ do
    wait_for_elements_exist("view marked:'"+@review_sent+"'", :timeout => @wait_timeout_extra)
end

Then /^I wait to see the mail option$/ do
    wait_for_elements_exist("view marked:'"+@mail+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the shopping cart$/ do
    wait_for_elements_exist("view marked:'"+@no_items_message+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the categories$/ do
    wait_for_elements_exist("view marked:'"+@categories+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the choose country screen$/ do
    wait_for_elements_exist("view marked:'"+@choose_country+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the my favourites screen$/ do
    wait_for_elements_exist("view marked:'"+@my_favorites+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the empty favourites screen$/ do
    wait_for_elements_exist("view marked:'"+@no_favourites_message+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the cart screen not empty$/ do
    wait_for_elements_exist("view marked:'"+@proceed_to_chechout+"'", :timeout => @wait_timeout_extra)
end

Then /^I should see the recent searches screen$/ do
    wait_for_elements_exist("view marked:'"+@recent_searches+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the no recent searches screen$/ do
    wait_for_elements_exist("view marked:'"+@no_recent_searches_message+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the recently viewed screen$/ do
    wait_for_elements_exist("view marked:'"+@recently_viewed+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the no recently viewed products screen$/ do
    wait_for_elements_exist("view marked:'"+@no_recent_viewed_message+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the track order screen$/ do
    wait_for_elements_exist("view marked:'"+@order_status+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the (valid|invalid) order information$/ do |option|
    case option.to_s
    when "valid"
    	wait_for_elements_exist("view marked:'"+@creation_date+"'", :timeout => @wait_timeout_extra)
    when "invalid"
        wait_for_elements_exist("view marked:'"+@no_results_track_order_message+"'", :timeout => @wait_timeout)
    end
end

Then /^I wait to see the filters screen$/ do
    wait_for_elements_exist("view marked:'"+@filters+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the product added message$/ do
    wait_for_elements_exist("view marked:'"+@item_added_to_cart_message+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the cart screen$/ do
    wait_for_elements_exist("view marked:'"+@cart+"'", :timeout => @wait_timeout_extra)
end

Then /^I wait to see the error change password empty fields$/ do
    wait_for_elements_exist("view marked:'"+@error_empty_fields_cp+"'", :timeout => @wait_timeout)
end

Then /^I wait see the error empty fields on forgot password$/ do
    wait_for_elements_exist("view marked:'"+@error_empty_fields_cp+"'", :timeout => @wait_timeout)
end

Then /^I wait to see the error track order field empty$/ do
    wait_for_elements_exist("view marked:'"+@empty_order_id_message+"'", :timeout => @wait_timeout)
end

Then /^I wait for the shippping address screen$/ do
    wait_for_elements_exist("view marked:'"+@default_shipping_address+"'", :timeout => @wait_timeout_extra)
end

Then /^I wait for the shipping method screen$/ do
    wait_for_elements_exist("view marked:'"+@shipping+"'", :timeout => @wait_timeout_extra)
end

Then /^I wait to see the payment screen$/ do
    wait_for_elements_exist("view marked:'"+@payment+"'", :timeout => @wait_timeout_extra)
end

Then /^I wait to see the my order screen$/ do
    wait_for_elements_exist("view marked:'"+@my_order+"'", :timeout => @wait_timeout_extra)
end

Then /^I wait to see the thank you screen$/ do
    wait_for_elements_exist("view marked:'"+@thank_you+"'", :timeout => @wait_timeout_extra)
end

Then /^I wait to see the countries$/ do
    wait_for_elements_exist("view marked:'Nigeria'", :timeout => @wait_timeout)
end

Then /^I wait to see the error$/ do
    wait_for_elements_exist("view marked:'"+@error+"'")
end