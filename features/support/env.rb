# Requiring this file will import Calabash and the Calabash predefined Steps.
require 'calabash-cucumber/cucumber'

# To use Calabash without the predefined Calabash Steps, uncomment these
# three lines and delete the require above.
# require 'calabash-cucumber/wait_helpers'
# require 'calabash-cucumber/operations'
# World(Calabash::Cucumber::Operations)

def initvars
    
    #init
    @wait_timeout = 5
    @wait_timeout_extra = 20
    
    #choose country
    @choose_country = "Choose Country"
    @apply = "Apply"
    
    #home
    @fashion = "Fashion"
    @popular_categories = "PopularCategories"
    @top_brands = "Top Brands"
    @shop_now = "Shop Now"
    @cart_button = "btn cart"
    
    #side bar
    @hamburger_btn = "btn menu"
    @shopping_cart = "Shopping Cart"
    @login = "Login"
    @logout = "Logout"
    @my_account = "My Account"
    @categories = "Categories"
    @my_favorites = "My Favourites"
    @recent_searches = "Recent Searches"
    @recently_viewed = "Recently Viewed"
    @track_my_order = "Track my Order"
    @change_country = "Change Country"
    @home = "Home"
    @back_button = "btn back"
    
    #login
    @credentials = "Credentials"
    @error_form_validation = "Form Validation Failed."
    @error_check_username = "Check your username and password"
    @e_mail = "E-Mail"
    @password = "Password"
    @invalid_email = "Email@invalido.com"
    @invalid_password = "umapasswordqualquer"
    @valid_email = "testcalabash@mailinator.com"
    @valid_password = "password1"
    @forgot_password = "Forgot Password?"
    
    #my account
    @account_settings = "Account Settings"
    @notification_settings = "Notification Settings"
    @user_data = "User Data"
    @email_notifications = "Email Notifications"
    @notifications = "Notifications"
    @sound = "Sound"
    @error_empty_fields_cp = "There were errors on the data submited, please check your input fields."
    
    #user data
    @your_personal_data = "Your Personal Data"
    @retype_password = "Re-type password"
    @save = "Save"
    @error_empty_fields = "Form Validation Failed."
    @error_min_characters = "Min 6 characters"
    @error_password_not_match = "Passwords did not match"
    @password_min_6 = "12345"
    @password_changed_success = "Password changed with success."
    
    #email notifications
    @newsletters_subscribed = "Newsletters Subscribed"
    @newsletter_male = "Newsletter Male"
    @newsletter_female = "Newsletter Female"
    @preferences_updated = "Preferences updated"
    
    #forgot password
    @please_type_email = "Please type in your email."
    @submit = "Submit"
    @error_empty_fields_fp = "Empty Fields"
    @error_please_check_input = "There were errors on the data submited, please check your input fields."
    @email_sent = "Email sent"
    
    #create account
    @crate_account = "Create Account"
    @account_data = "Account Data"
    @birthday = "Birthday"
    @done = "Done"
    @gender = "Gender"
    @receive_newsletter = "Receive Newsletter?"
    @first_name = "First name"
    @last_name = "Last name"
    @retype_password_2 = "Retype password"
    @newsletter = "Newsletter"
    @register = "Register"
    
    #new user data
    @first_name_text = "Tester"
    @last_name_text = "Test"
    @random = Time.now.to_i
    @new_email = "testjumia+brunoqa"+@random.to_s+"@gmail.com"
    
    #search
    @search = "Search"
    @valid_search = "Sandal"
    @invalid_search = "dsofijsdijfoigjsodijfsodijfgsodijf"
    @message_no_search_found = "Unfortunately there was no match found for « "+@invalid_search+" », Please try again"

    #catalog
    @popularity = "Popularity"
    @filter_icon = "filterIcon"
    @grid_icon = "gridIcon"
    @fav_button = "FavButton"
    @catalog_top_button = "catalogTopButton"
    @message_item_add_favourites = "Item added to My Favourites"
    @message_item_removed_favourites = "Item removed from My Favourites"
    @best_rating = "Best Rating"
    @new_in = "New in"
    @price_up = "Price up"
    @price_down = "Price down"
    @name = "Name"
    @brand = "Brand"
    
    #product details
    @share_button = "btn share"
    @rate_button = "Rate Now"
    @specification = "Specification"
    @add_to_cart = "Add to Cart"
    @related_items = "Related Items"
    @product_features = "Product Features"
    @product_description = "Product Description"
    @rate_message = "You have used this Product? Rate it now!"
    @item_added_to_cart_message = "Item was added to shopping cart"
    
    #review
    @review_name = "Name"
    @review_title = "Title"
    @review_comment = "Comment"
    @send_review = "Send Review"
    @review_sent = "Review sent"
    @mail = "Mail"
    @cancel = "Cancel"
    
    #cart
    @no_items_message = "You have no items in the cart"
    @proceed_to_chechout = "Proceed to Checkout"
    @cart = "Cart"
    @change_quantity_1 = "Quantity: 1"
    @call_to_order = "Call to Order"

    #my favourites
    @no_favourites_message = "You have no favourite items at the moment"
    @favorite_remove_button = "btn removeitem"
    @add_all_items_to_cart = "Add All Items to Cart"
    @size = "Size"
    
    #recent searches
    @clear_recent_searches_button = "Clear Recent Searches"
    @no_recent_searches_message = "No Recent Searches"
    
    #recently viewed
    @clear_recently = "Clear Recently Viewed"
    @no_recent_viewed_message = "No Recently Viewed Products Here"
    
    #track order
    @order_status = "Order Status"
    @order_id = "Order id"
    @track_order = "Track Order"
    @empty_order_id_message = "Please enter the order ID"
    @no_results_track_order_message = "No results found for the searched order id. Please recheck the order id and try again."
    @track_order_id_valid = "300726581"
    @track_order_id_invalid = "000"
    @creation_date = "Creation Date:"
    @keyboard_delete_key = "Apagar"
    
    #filters
    @filters = "Filters"
    
    #native checkout
    @next = "Next"
    @default_shipping_address = "Default Shipping Address"
    @shipping = "Shipping"
    @payment = "Payment"
    @my_order = "My Order"
    @confirm_order = "Confirm Order"
    @thank_you = "Thank You!"

end
