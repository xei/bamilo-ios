//
//  JAConstants.h
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

// Notifications

//************ app action notifications
#define kSelectedCountryNotification @"NOTIFICATION_SELECTED_COUNTRY"
#define kUpdateCountryNotification @"NOTIFICATION_UPDATE_COUNTRY"
#define kUpdateCartNotification @"NOTIFICATION_UPDATE_CART"
#define kUpdateCartNotificationValue @"NOTIFICATION_UPDATE_CART_VALUE"
#define kUserLoggedInNotification @"NOTIFICATION_USER_LOGGED_IN"
#define kUserLoggedOutNotification @"NOTIFICATION_USER_LOGGED_OUT"
#define kCancelLoadingNotificationName @"CANCEL_LOADING_NOTIFICATION"
#define kCancelButtonPressedInMenuSearchBar @"PRESSED_BACK_BUTTON_NOTIFICATION"
#define kUpdateSideMenuCartNotification @"NOTIFICATION_SIDE_MENU_UPDATE_CART"
#define kExternalPaymentValue @"NOTIFICATION_EXTERNAL_PAYMENT_VALUE"
#define kDeactivateExternalPaymentNotification @"NOTIFICATION_DEACTIVATE_EXTERNAL_PAYMENT_VALUE"
//************

//************ root view controller notifications
#define kOpenMenuNotification @"NOTIFICATION_OPEN_MENU"
#define kCloseMenuNotification @"NOTIFICATION_OPEN_COLSE"
#define kOpenCenterPanelNotification @"NOTIFICATION_OPEN_CENTER_PANEL"
#define kTurnOffLeftSwipePanelNotification @"NOTIFICATION_TURN_OFF_LEFT_SWIPE_PANEL"
#define kTurnOnLeftSwipePanelNotification @"NOTIFICATION_TURN_ON_LEFT_SWIPE_PANEL"
//************

//************ center navigation controller notifications
#define kCloseCurrentScreenNotification @"NOTIFICATION_CLOSE_CURRENT_SCREEN"
#define kCloseTopTwoScreensNotification @"NOTIFICATION_CLOSE_TOP_TWO_SCREENS"
#define kMenuDidSelectOptionNotification @"NOTIFICATION_SELECTED_ITEM_MENU"
#define kOpenCatalogFromUndefinedSearch @"NOTIFICATION_OPEN_CATALOG_FROM_UNDEF_SEARCH"
#define kMenuDidSelectLeafCategoryNotification @"NOTIFICATION_SELECTED_LEAF_CATEGORY"
#define kSelectedRecentSearchNotification @"NOTIFICATION_SELECTED_RECENT_SEARCH"
#define kOpenCartNotification @"NOTIFICATION_OPEN_CART"
#define kOpenOtherOffers @"NOTIFICATION_OPEN_OTHER_OFFERS"
#define kOpenSellerReviews @"NOTIFICATION_OPEN_SELLER_REVIEWS"
#define kOpenNewSellerReview @"NOTIFICATION_OPEN_NEW_SELLER_REVIEW"
#define kOpenSellerPage @"NOTIFICATION_OPEN_SELLER_PAGE"

//************ side menu navigation controller notifications
#define kShowChooseCountryScreenNotification @"NOTIFICATION_CHOOSE_COUNTRY_SCREEN"
#define kShowHomeScreenNotification @"NOTIFICATION_HOME_SCREEN"
#define kShowSignInScreenNotification @"NOTIFICATION_SHOW_SIGN_IN_SCREEN"
#define kShowSignUpScreenNotification @"NOTIFICATION_SHOW_SIGN_UP_SCREEN"
#define kShowForgotPasswordScreenNotification @"NOTIFICATION_SHOW_FORGOT_PASSWORD_SCREEN"
#define kShowFavoritesScreenNotification @"NOTIFICATION_SHOW_FAVORITES_SCREEN"
#define kShowRecentSearchesScreenNotification @"NOTIFICATION_SHOW_RECENT_SEARCHES_SCREEN"
#define kShowRecentlyViewedScreenNotification @"NOTIFICATION_SHOW_RECENTLY_VIEWED_SCREEN"
#define kShowMyAccountScreenNotification @"NOTIFICATION_SHOW_MY_ACCOUNT_SCREEN"
#define kShowUserDataScreenNotification @"NOTIFICATION_SHOW_USER_DATA_SCREEN"
#define kShowEmailNotificationsScreenNotification @"NOTIFICATION_SHOW_EMAIL_NOTIFICAITONS_SCREEN"

// Checkout
#define kShowCheckoutForgotPasswordScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_FORGOT_PASSWORD_SCREEN"
#define kShowCheckoutLoginScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_LOGIN_SCREEN"
#define kShowCheckoutAddressesScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_ADDRESSES_SCREEN"
#define kShowCheckoutAddAddressScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_ADD_ADDRESS_SCREEN"
#define kShowCheckoutEditAddressScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_EDIT_ADDRESS_SCREEN"
#define kShowCheckoutShippingScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_SHIPPING_SCREEN"
#define kShowCheckoutPaymentScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_PAYMENT_SCREEN"
#define kShowCheckoutFinishScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_FINISH_SCREEN"
#define kShowCheckoutExternalPaymentsScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_EXTERNAL_PAYMENTS_SCREEN"
#define kShowCheckoutThanksScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_THANKS_SCREEN"
#define kShowMyOrdersScreenNotification @"NOTIFICATION_SHOW_MY_ORDERS_SCREEN"

// Filters
#define kShowFiltersScreenNotification @"NOTIFICATION_SHOW_FILTERS_SCREEN"
#define kShowCategoryFiltersScreenNotification @"NOTIFICATION_SHOW_PRICE_FILTERS_SCREEN"
#define kShowPriceFiltersScreenNotification @"NOTIFICATION_SHOW_CATEGORY_FILTERS_SCREEN"
#define kShowGenericFiltersScreenNotification @"NOTIFICATION_SHOW_GENERIC_FILTERS_SCREEN"

// Product
#define kShowProductSpecificationScreenNotification @"NOTIFICATION_SHOW_PRODUCT_SPECIFICATION_SCREEN"
#define kShowRatingsScreenNotification @"NOTIFICATION_SHOW_RATINGS_SCREEN"
#define kShowNewRatingScreenNotification @"NOTIFICATION_SHOW_NEW_RATING_SCREEN"
#define kShowSizeGuideNotification @"NOTIFICATION_SHOW_SIZE_GUIDE"
#define kProductChangedNotification @"NOTIFICATION_PRODUCT_CHANGED"

//teasers
#define kDidSelectTeaserWithCatalogUrlNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_CATALOG_URL"
#define kDidSelectTeaserWithPDVUrlNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_PDV_URL"
#define kDidSelectTeaserWithShopUrlNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_SHOP_URL"
#define kDidSelectCampaignNofication @"NOTIFICATION_DID_SELECT_CAMPAING"
#define kDidSelectTeaserWithAllCategoriesNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_ALL_CATEGORIES"
#define kDidSelectCategoryFromCenterPanelNotification @"NOTIFICATION_SELECTED_CATEGORY_FROM_CENTER_PANEL"

//navbar notification
#define kChangeNavigationBarNotification @"NOTIFICATION_CHANGE_NAVIGATION_BAR"
#define kEditShouldChangeStateNotification @"EDIT_SHOULD_CHANGE_NOTIFICATION"
#define kDoneShouldChangeStateNotification @"DONE_SHOULD_CHANGE_NOTIFICATION"
#define kDidPressBackNotification @"DID_PRESS_BACK_NOTIFICATION"
#define kDidPressDoneNotification @"DID_PRESS_DONE_NOTIFICATION"
#define kDidPressEditNotification @"DID_PRESS_EDIT_NOTIFICATION"
#define kDidPressSearchButtonNotification @"DID_PRESS_SEARCH_BUTTON_NOTIFICATION"
#define kDidPressNavBar @"DID_PRESS_NAV_BAR"


// Ad4Push Notifications
#define A4S_INAPP_NOTIF_VIEW_DID_APPEAR @"A4S_INAPP_NOTIF_VIEW_DID_APPEAR"
#define A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR @"A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR"


#define kRememberedEmail @"REMEMBER_EMAIL"




//************
//my account notifications
#define kDidSaveUserDataNotification @"DID_SAVE_USER_DATA_NOTIFICATION"
#define kDidSaveEmailNotificationsNotification @"DID_SAVE_EMAIL_NOTIFICATIONS_NOTIFICATION"

// Update alert view
#define kForceUpdateAlertViewTag 0
#define kUpdateAvailableAlertViewTag 1

// App url (this is needed to redirect to itunes connect to update the app)
#define kAppStoreUrl @"https://itunes.apple.com/us/app/jumia-online-shopping/id925015459?mt=8"

// Preferences
#define kDidFirstBuyKey @"did_first_buy"
#define kNumberOfSessions @"amount_sessions"
#define kSessionDate @"session_date"
#define kChangeNotificationsOptions @"change_notifications_option"
#define kChangeSoundOptions @"change_sound_option"

// Colors

// Colors - Backgrounds
#define JANavBarBackgroundGrey UIColorFromRGB(0xeaeaea)
#define JABackgroundGrey UIColorFromRGB(0xc8c8c8)

// Colors - Buttons
#define JAButtonOrange UIColorFromRGB(0xfaa41a)
#define JAButtonTextOrange UIColorFromRGB(0x4e4e4e)
#define JAFeedbackGrey UIColorFromRGB(0xf0f0f0)

// Colors - Text
#define JALabelGrey UIColorFromRGB(0xcccccc)
