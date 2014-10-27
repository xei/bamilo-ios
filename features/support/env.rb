# Requiring this file will import Calabash and the Calabash predefined Steps.
require 'calabash-cucumber/cucumber'

# To use Calabash without the predefined Calabash Steps, uncomment these
# three lines and delete the require above.
# require 'calabash-cucumber/wait_helpers'
# require 'calabash-cucumber/operations'
# World(Calabash::Cucumber::Operations)

$country = ENV['country']
##FR - EG,CI,MA | EN - CM,GH,KE,NG,UG

def initvars
    puts "initvars EN"
    #init
    @wait_timeout = 5
    @wait_timeout_extra = 20
    @wait_timeout_a_lot = 50
    @country_cm = "Cameroun"
    @country_eg = "Egypt"
    @country_ci = "Côte d'ivoire"
    @country_gh = "Ghana"
    @country_ke = "Kenya"
    @country_ma = "Maroc"
    @country_ng = "Nigeria"
    @country_ug = "Uganda"
    
    #choose country
    @choose_country = "Choose Country"
    @apply = "Apply"
    
    #home
    @fashion = "Fashion"
    @popular_categories = "Popular Categories"
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
    @error = "Error"
    
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
    @default_shipping_address = "2. Address"
    @shipping = "Shipping"
    @payment = "Payment"
    @my_order = "My Order"
    @confirm_order = "Confirm Order"
    @thank_you = "Thank You!"

end

def initvars_fr
    puts "initvars FR"
    
    #init
    @wait_timeout = 5
    @wait_timeout_extra = 20
    @wait_timeout_a_lot = 50
    @country_cm = "Cameroun"
    @country_eg = "Egypt"
    @country_ci = "Côte d'ivoire"
    @country_gh = "Ghana"
    @country_ke = "Kenya"
    @country_ma = "Maroc"
    @country_ng = "Nigeria"
    @country_ug = "Uganda"
    
    #choose country
    @choose_country = "Choisir le pays"
    @apply = "Appliquer"
    
    #home
    @fashion = "Accueil"
    @popular_categories = "Nos Meilleures Catégories"
    @top_brands = "Vos Marques Préférées"
    ##
    @shop_now = "Shop Now"
    @cart_button = "btn cart"
    
    #side bar
    @hamburger_btn = "btn menu"
    @shopping_cart = "Panier d'achat"
    @login = "Connectez-vous"
    @logout = "Se déconnecter"
    @my_account = "Mon compte"
    @categories = "Catégories"
    @my_favorites = "Mes Favoris"
    @recent_searches = "Recherches Récentes"
    @recently_viewed = "Derniers Produits Vus"
    @track_my_order = "Suivi de commande"
    @change_country = "Choisir le pays"
    @home = "Accueil"
    @back_button = "btn back"
    
    #login
    @credentials = "Identifiants"
    @error_form_validation = "Formulaire de validation a échoué."
    @error_check_username = "Vérifiez votre nom d'utilisateur ou mot de passe."
    @e_mail = "E-Mail"
    @password = "Mot de passe"
    @invalid_email = "Email@invalido.com"
    @invalid_password = "umapasswordqualquer"
    @valid_email = "testcalabash@mailinator.com"
    @valid_password = "password1"
    @forgot_password = "Mot de passe oublié?"
    
    #my account
    @account_settings = "Paramètres du compte"
    @notification_settings = "Paramètres de notification"
    @user_data = "Données de l'utilisateur"
    @email_notifications = "Préférence eMails"
    @notifications = "Notifications"
    @sound = "Son"
    @error_empty_fields_cp = "Il y a des erreurs dans les données communiquées, vérifiez les différents champs renseignés"
    
    #user data
    @your_personal_data = "Vous données personnelles"
    @retype_password = "Retaper le mot de passe"
    @save = "Enregistrer"
    @error_empty_fields = "Il y a des erreurs dans les données communiquées, vérifiez les différents champs renseignés"
    @error_min_characters = "Min 6 caractères"
    @error_password_not_match = "Les mots de passe ne correspondent pas"
    @password_min_6 = "12345"
    @password_changed_success = "Changement de mot de passe effectué"
    
    #email notifications
    @newsletters_subscribed = "Inscrit aux Newsletters"
    @newsletter_male = "Newsletter Homme"
    @newsletter_female = "Newsletter Femme"
    @preferences_updated = "Préférences mises à jour"
    
    #forgot password
    @please_type_email = "Veillez entrer votre e-mail."
    @submit = "Soumettre"
    @error_empty_fields_fp = "Il y a des erreurs dans les données communiquées, vérifiez les différents champs renseignés"
    @error_please_check_input = "L'adresse électronique fournie n'est pas correct."
    @email_sent = "Email envoyé"
    
    #create account
    @crate_account = "Créer um compte"
    @account_data = "Donnés du compte"
    @birthday = "Birthday"
    @done = "Valider"
    @gender = "Civilité"
    @receive_newsletter = "Recevoir la newsletter?"
    @first_name = "Prénom"
    @last_name = "Nom"
    @retype_password_2 = "Retaper le mot de passe"
    @newsletter = "Je m'inscris à la newsletter !"
    @register = "Enregistrer"
    @error = "Error"
    
    #new user data
    @first_name_text = "Tester"
    @last_name_text = "Test"
    @random = Time.now.to_i
    @new_email = "testjumia+brunoqa"+@random.to_s+"@gmail.com"
    
    #search
    @search = "Rechercher"
    @valid_search = "Sandal"
    @invalid_search = "dsofijsdijfoigjsodijfsodijfgsodijf"
    @message_no_search_found = "Malheureusement, il n'y a pas de résultat pour « "+@invalid_search+" », essayez s'il vous plaît à nouveau"
    
    #catalog
    @popularity = "Popularité"
    @filter_icon = "filterIcon"
    @grid_icon = "gridIcon"
    @fav_button = "FavButton"
    @catalog_top_button = "catalogTopButton"
    @message_item_add_favourites = "Produit ajouté aux Favoris"
    @message_item_removed_favourites = "Produit supprimé de Mes Favoris"
    @best_rating = "Mieux Notés"
    @new_in = "Nouveautés"
    @price_up = "Prix croissant"
    @price_down = "Prix décroissant"
    @name = "Non"
    @brand = "Marque"
    
    #product details
    @share_button = "btn share"
    @rate_button = "Evaluez Maintenant"
    @specification = "Caractéristiques"
    @add_to_cart = "Ajouter au panier"
    @related_items = "Produits Similaires"
    @product_features = "Spécifités du produit"
    @product_description = "Description du produit"
    @rate_message = "Avez-vous acheté / utilisé ce produit? Notez le!"
    @item_added_to_cart_message = "Le produit a été ajouté au panier"
    
    #review
    @review_name = "Nom"
    @review_title = "Titre"
    @review_comment = "Avis"
    @send_review = "Envoyer votre avis"
    @review_sent = "Avis envoyé"
    @mail = "Mail"
    @cancel = "Cancel"
    
    #cart
    @no_items_message = "Vous n'avez pas d'articles dans le panier"
    @proceed_to_chechout = "Valider la commande"
    @cart = "Panier"
    @change_quantity_1 = "Quantité 1"
    @call_to_order = "Appeler pour commander"
    
    #my favourites
    @no_favourites_message = "Vous n'avez pas de favoris pour le moment"
    @favorite_remove_button = "btn removeitem"
    @add_all_items_to_cart = "Tout ajouter au Panier"
    @size = "Taille"
    
    #recent searches
    @clear_recent_searches_button = "Effacer les Recherches Récentes"
    @no_recent_searches_message = "Aucune Recherche Récente"
    
    #recently viewed
    @clear_recently = "Effacer les Derniers Produits Vus"
    @no_recent_viewed_message = "Aucun Dernier Produit Vu"
    
    #track order
    @order_status = "Statut de la commande"
    @order_id = "Numéro de commande"
    @track_order = "Suivre la commande"
    @empty_order_id_message = "Veuillez entrer le numéro de commande"
    @no_results_track_order_message = "Aucun résultat pour le numéro de commande recherché...."
    @track_order_id_valid = "300799592"
    @track_order_id_invalid = "000"
    @creation_date = "Date de création:"
    @keyboard_delete_key = "Apagar"
    
    #filters
    @filters = "Filtres"
    
    #native checkout
    @next = "Suivant"
    @default_shipping_address = "Adresse de libraison par défaut"
    @shipping = "Livraison Standard"
    @payment = "Paiement"
    @my_order = "Ma commande"
    @confirm_order = "Confirmer la commande"
    @thank_you = "Merci!"
    
end

