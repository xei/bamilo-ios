Then /^I should see the Account Settings section$/ do
    check_element_exists("view marked:'"+@account_settings+"'")
end

Then /^I should see the Notification Settings$/ do
    check_element_exists("view marked:'"+@notification_settings+"'")
end

Then /^I should see the newsletter checkbox$/ do
    check_element_exists("view marked:'"+@newsletter+"'")
end

Then /^I should see the popular categories$/ do
    check_element_exists("view marked:'"+@popular_categories+"'")
    touch("view marked:'"+@popular_categories+"'")
end

Then /^I should see the top brands$/ do
    check_element_exists("view marked:'"+@top_brands+"'")
end

Then /^I verify if a promotion is showing$/ do
    res = element_exists("view marked:'"+@shop_now+"'")
    if res == true
        touch("view marked:'"+@shop_now+"'")
    end
end

Then /^I should see the search section$/ do
    check_element_exists("view marked:'"+@search+"'")
end

Then /^I should see the filter (best rating|popularity|new in|price up|price down|name|brand)$/ do |option|
    case option.to_s
    when "best rating"
        check_element_exists("view marked:'"+@best_rating+"'")
    when "popularity"
        check_element_exists("view marked:'"+@popularity+"'")
    when "new in"
        check_element_exists("view marked:'"+@new_in+"'")
    when "price up"
        check_element_exists("view marked:'"+@price_up+"'")
    when "price down"
        check_element_exists("view marked:'"+@price_down+"'")
    when "name"
        check_element_exists("view marked:'"+@name+"'")
    when "brand"
        check_element_exists("view marked:'"+@brand+"'")
    end
end

Then /^I should see the product (desctiption|features)$/ do |option|
    case option.to_s
    when "desctiption"
    check_element_exists("view marked:'"+@product_features+"'")
    when "features"
    wait_for_element_exists("view marked:'"+@product_description+"'", :timeout => @wait_timeout)
    end
end

Then /^I should see the rating screen$/ do
    wait_for_element_exists("view marked:'"+@rate_message+"'", :timeout => @wait_timeout)
end

Then /^I should see the related items$/ do
    wait_for_element_exists("view marked:'"+@related_items+"'", :timeout => @wait_timeout)
end

Then /^I should see all the side menu options$/ do
    check_element_exists("view marked:'"+@shopping_cart+"'")
    check_element_exists("view marked:'"+@home+"'")
    check_element_exists("view marked:'"+@categories+"'")
    check_element_exists("view marked:'"+@my_favorites+"'")
    check_element_exists("view marked:'"+@recent_searches+"'")
    check_element_exists("view marked:'"+@recently_viewed+"'")
    check_element_exists("view marked:'"+@my_account+"'")
    check_element_exists("view marked:'"+@track_my_order+"'")
    check_element_exists("view marked:'"+@change_country+"'")
    check_element_exists("view marked:'"+@login+"'")
end

