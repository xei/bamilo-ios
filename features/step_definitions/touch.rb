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

Then /^I change the notifications and sound settings$/ do
    touch("UISwitch marked:'"+@notifications+"'")
    sleep(1)
    touch("UISwitch marked:'"+@sound+"'")
end

Then /^I touch the user data option$/ do
    touch("view marked:'"+@user_data+"'")
end

Then /^I touch the Save button$/ do
    touch("view marked:'"+@save+"'")
end

Then /^I touch the email notification option$/ do
    touch("view marked:'"+@email_notifications+"'")
end

Then /^I change the newsletter settings$/ do
    touch("UISwitch marked:'"+@newsletter_male+"'")
    touch("UISwitch marked:'"+@newsletter_female+"'")
end

Then /^I touch the forgot password option$/ do
    touch("view marked:'"+@forgot_password+"'")
end

Then /^I touch the Submit button$/ do
    touch("view marked:'"+@submit+"'")
end

Then /^I touch the create account option$/ do
    touch("view marked:'"+@crate_account+"'")
end

Then /^I touch the Register button$/ do
    touch("view marked:'"+@register+"'")
end

Then /^I touch the catagories option$/ do
    touch("view marked:'"+@categories+"'")
end

Then /^I touch the grid button$/ do
    touch("view marked:'"+@grid_icon+"'")
end

Then /^I touch the favorites button$/ do
    touch("view marked:'"+@fav_button+"'")
end

Then /^I touch the scroll up button$/ do
    touch("view marked:'"+@catalog_top_button+"'")
end

Then /^I touch collection view item number (\d+)$/ do |option|
    touch("UICollectionViewCell index:"+option)
end

Then /^I touch the specification option$/ do
    touch("view marked:'"+@specification+"'")
end

Then /^I touch the rate button$/ do
    if (element_does_not_exist("view marked:'"+@rate_button+"'"))
        touch(nil, :offset => {:x => 159, :y => 460})
    else
        touch("view marked:'"+@rate_button+"'")
    end
    #touch("view marked:'"+@rate_button+"'")
    #touch(nil, :offset => {:x => 159, :y => 460})
end

Then /^I touch send review button$/ do
    touch("view marked:'"+@send_review+"'")
end

Then /^I touch the share image button$/ do
    touch("view marked:'"+@share_button+"'")
end

Then /^I touch cancel option$/ do
    touch("view marked:'"+@cancel+"'")
end

Then /^I touch the shopping cart in the side menu$/ do
    touch("view marked:'"+@shopping_cart+"'")
end

Then /^I touch the home in the side menu$/ do
    touch("view marked:'"+@home+"'")
end

Then /^I touch the categories$/ do
    touch("view marked:'"+@categories+"'")
end

Then /^I touch the choose country option$/ do
    touch("view marked:'"+@choose_country+"'")
end

Then /^I touch the my favourites option$/ do
    touch("view marked:'"+@my_favorites+"'")
end

Then /^I touch the back button$/ do
    touch("view marked:'"+@back_button+"'")
end

Then /^I touch the delete favourite button$/ do
    touch("view marked:'"+@favorite_remove_button+"'")
end

Then /^I make sure the size is selected$/ do
    res = element_exists("view marked:'"+@size+"'")
    if res == true
        touch("view marked:'"+@size+"'")
        touch("view marked:'"+@done+"'")
    end
end

Then /^I touch the add all items to cart screen$/ do
    touch("view marked:'"+@add_all_items_to_cart+"'")
end

Then /^I touch the cart button$/ do
    wait_for_elements_do_not_exist("view marked:'"+@item_added_to_cart_message+"'")
    touch("view marked:'"+@cart_button+"'")
end

Then /^I touch the recent searches option$/ do
    touch("view marked:'"+@recent_searches+"'")
end

Then /^I touch the clear recent searches button$/ do
    touch("view marked:'"+@clear_recent_searches_button+"'")
end

Then /^I touch the recently viewed option$/ do
    touch("view marked:'"+@recently_viewed+"'")
end

Then /^I touch the clear recently viewed button$/ do
    touch("view marked:'"+@clear_recently+"'")
end

Then /^I touch the track order option$/ do
    touch("view marked:'"+@track_my_order+"'")
end

Then /^I touch the track order button$/ do
    touch("view marked:'"+@track_order+"'")
end

Then /^I touch the filter button$/ do
    touch("view marked:'"+@filter_icon+"'")
end

Then /^I touch done button$/ do
    touch("view marked:'"+@done+"'")
end

Then /^I touch the table list item number (\d+)$/ do |option|
    touch("UITableViewCell index:"+option)
end

Then /^I touch add to cart button$/ do
    touch("view marked:'"+@add_to_cart+"'")
    sleep(1)
    res = element_exists("view marked:'"+@done+"'")
    if res == true
        touch("view marked:'"+@done+"'")
    end
end

Then /^I touch the quantity button$/ do
    touch("view marked:'"+@change_quantity_1+"'")
end

Then /^I touch the remove from cart button$/ do
    touch("view marked:'"+@favorite_remove_button+"'")
end

Then /^I touch the proceed to checkout button$/ do
    touch("view marked:'"+@proceed_to_chechout+"'")
end

Then /^I touch the product detail image$/ do
    touch(nil, :offset => {:x => 159, :y => 220})
    #touch("UIImageView marked:'pdv_main_image'")
end

Then /^I touch the write review button$/ do
    touch("view marked:'"+@write_review+"'")
end

Then /^I touch the next button$/ do
    touch("view marked:'"+@next+"'")
end

Then /^I touch the confirm order button$/ do
    touch("view marked:'"+@confirm_order+"'")
end

Then /^I touch the Nigeria Country$/ do
    touch("view marked:'Nigeria'")
end

Then /^I touch the Maroc Country$/ do
    touch("view marked:'Maroc'")
end

Then /^I touch the apply button$/ do
    touch("view marked:'Apply'")
end