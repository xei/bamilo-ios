//
//  JAConstants.h
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#define RI_IS_RTL [RILocalizationWrapper localizationIsRTL]

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
#define kExternalPaymentValue @"NOTIFICATION_EXTERNAL_PAYMENT_VALUE"
#define kDeactivateExternalPaymentNotification @"NOTIFICATION_DEACTIVATE_EXTERNAL_PAYMENT_VALUE"
#define kAppWillEnterForeground @"NOTIFICATION_APP_WILL_ENTER_FOREGROUND"
#define kAppDidEnterBackground @"NOTIFICATION_APP_DID_ENTER_BACKGROUND"
#define kHomeShouldReload @"NOTIFICATION_HOME_SHOULD_RELOAD"
#define kSideMenuShouldReload @"NOTIFICATION_SIDE_MENU_SHOULD_RELOAD"
//************

//************ root view controller notifications
#define kOpenMenuNotification @"NOTIFICATION_OPEN_MENU"
#define kCloseMenuNotification @"NOTIFICATION_OPEN_COLSE"
#define kOpenCenterPanelNotification @"NOTIFICATION_OPEN_CENTER_PANEL"
#define kTurnOffMenuSwipePanelNotification @"NOTIFICATION_TURN_OFF_MENU_SWIPE_PANEL"
#define kTurnOnMenuSwipePanelNotification @"NOTIFICATION_TURN_ON_MENU_SWIPE_PANEL"
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
#define kShowAuthenticationScreenNotification @"NOTIFICATION_SHOW_AUTHENTICATION_SCREEN"
#define kRunBlockAfterAuthenticationNotification @"NOTIFICATION_RUN_BLOCK_AFTER_AUTHENTICATION"
#define kShowSignInScreenNotification @"NOTIFICATION_SHOW_SIGN_IN_SCREEN"
#define kShowSignUpScreenNotification @"NOTIFICATION_SHOW_SIGN_UP_SCREEN"
#define kShowForgotPasswordScreenNotification @"NOTIFICATION_SHOW_FORGOT_PASSWORD_SCREEN"
#define kShowSavedListScreenNotification @"NOTIFICATION_SHOW_SAVEDLIST_SCREEN"
#define kShowMoreMenuScreenNotification @"NOTIFICATION_MORE_MENU_SCREEN"
#define kShowRecentSearchesScreenNotification @"NOTIFICATION_SHOW_RECENT_SEARCHES_SCREEN"
#define kShowRecentlyViewedScreenNotification @"NOTIFICATION_SHOW_RECENTLY_VIEWED_SCREEN"
#define kShowMyAccountScreenNotification @"NOTIFICATION_SHOW_MY_ACCOUNT_SCREEN"
#define kShowUserDataScreenNotification @"NOTIFICATION_SHOW_USER_DATA_SCREEN"
#define kShowEmailNotificationsScreenNotification @"NOTIFICATION_SHOW_EMAIL_NOTIFICAITONS_SCREEN"
#define kShowNewsletterSubscriptionsScreenNotification @"NOTIFICATION_SHOW_NEWSLETTER_SUBSCRIPTIONS_NOTIFICAITONS_SCREEN"

// Checkout
#define kShowCheckoutForgotPasswordScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_FORGOT_PASSWORD_SCREEN"
#define kShowCheckoutAddressesScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_ADDRESSES_SCREEN"
#define kShowCheckoutAddAddressScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_ADD_ADDRESS_SCREEN"
#define kShowCheckoutEditAddressScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_EDIT_ADDRESS_SCREEN"
#define kShowCheckoutShippingScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_SHIPPING_SCREEN"
#define kShowCheckoutPaymentScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_PAYMENT_SCREEN"
#define kShowCheckoutFinishScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_FINISH_SCREEN"
#define kShowCheckoutExternalPaymentsScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_EXTERNAL_PAYMENTS_SCREEN"
#define kShowCheckoutThanksScreenNotification @"NOTIFICATION_SHOW_CHECKOUT_THANKS_SCREEN"
#define kShowMyOrdersScreenNotification @"NOTIFICATION_SHOW_MY_ORDERS_SCREEN"
#define kShowMyOrderDetailScreenNotification @"NOTIFICATION_SHOW_MY_ORDER_DETAIL_SCREEN"

// Filters
#define kShowFiltersScreenNotification @"NOTIFICATION_SHOW_FILTERS_SCREEN"

// Product
#define kShowProductSpecificationScreenNotification @"NOTIFICATION_SHOW_PRODUCT_SPECIFICATION_SCREEN"
#define kShowRatingsScreenNotification @"NOTIFICATION_SHOW_RATINGS_SCREEN"
#define kShowNewRatingScreenNotification @"NOTIFICATION_SHOW_NEW_RATING_SCREEN"
#define kShowSizeGuideNotification @"NOTIFICATION_SHOW_SIZE_GUIDE"
#define kProductChangedNotification @"NOTIFICATION_PRODUCT_CHANGED"
#define kOpenSpecificationsScreen @"NOTIFICATION_SHOW_SPECIFICATIONS_SCREEN"
#define kOpenProductBundlesScreen @"NOTIFICATION_SHOW_BUNDLES_SCREEN"
#define kOpenProductVariationsScreen @"NOTIFICATION_SHOW_VARIATIONS_SCREEN"

//teasers
#define kDidSelectTeaserWithCatalogUrlNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_CATALOG_URL"
#define kDidSelectTeaserWithPDVUrlNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_PDV_URL"
#define kDidSelectTeaserWithShopUrlNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_SHOP_URL"
#define kDidSelectCampaignNofication @"NOTIFICATION_DID_SELECT_CAMPAING"
#define kDidSelectCategoryFromCenterPanelNotification @"NOTIFICATION_SELECTED_CATEGORY_FROM_CENTER_PANEL"

//navbar notification
#define kChangeTabBarVisibility @"NOTIFICATION_CHANGE_TAB_BAR_VISIBILITY"
#define kChangeNavigationBarNotification @"NOTIFICATION_CHANGE_NAVIGATION_BAR"
#define kEditShouldChangeStateNotification @"EDIT_SHOULD_CHANGE_NOTIFICATION"
#define kDoneShouldChangeStateNotification @"DONE_SHOULD_CHANGE_NOTIFICATION"
#define kDidPressBackNotification @"DID_PRESS_BACK_NOTIFICATION"
#define kDidPressDoneNotification @"DID_PRESS_DONE_NOTIFICATION"
#define kDidPressEditNotification @"DID_PRESS_EDIT_NOTIFICATION"
#define kDidPressNavBar @"DID_PRESS_NAV_BAR"
#define kDidPressSearchButtonNotification @"DID_PRESS_SEARCH_BUTTON_NOTIFICATION"

// Ad4Push Notifications
#define A4S_INAPP_NOTIF_VIEW_DID_APPEAR @"A4S_INAPP_NOTIF_VIEW_DID_APPEAR"
#define A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR @"A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR"


#define kRememberedEmail @"REMEMBER_EMAIL"


//tracking keys
#define kSkusFromTeaserInCartKey @"SKUS_FROM_TEASER_IN_CART"


//************
//my account notifications
#define kDidSaveUserDataNotification @"DID_SAVE_USER_DATA_NOTIFICATION"
#define kDidSaveEmailNotificationsNotification @"DID_SAVE_EMAIL_NOTIFICATIONS_NOTIFICATION"

// Update alert view
#define kForceUpdateAlertViewTag 0
#define kUpdateAvailableAlertViewTag 1

// App url (this is needed to redirect to itunes connect to update the app)
#define kAppStoreUrl @"https://itunes.apple.com/us/app/jumia-online-shopping/id925015459?mt=8"
#define kAppStoreUrlDaraz @"https://itunes.apple.com/app/daraz-online-shopping/id978058048"
#define kAppStoreUrlShop @"https://itunes.apple.com/app/shop.com.mm-online-shopping/id979214282"
#define kAppStoreUrlBamilo @"https://itunes.apple.com/app/bamylw/id979950698"

// App Store Id
#define kAppStoreId @"925015459"
#define kAppStoreIdDaraz @"978058048"
#define kAppStoreIdShop @"979214282"
#define kAppStoreIdBamilo @"979950698"

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
#define JAHomePageBackgroundGrey UIColorFromRGB(0xf9f9f9)

// Colors - Buttons
#define JAButtonOrange UIColorFromRGB(0xfaa41a)
#define JAButtonTextOrange UIColorFromRGB(0x4e4e4e)
#define JAFeedbackGrey UIColorFromRGB(0xf0f0f0)

// Colors - Text
#define JALabelGrey UIColorFromRGB(0xcccccc)


#define JABlackColor UIColorFromRGB(0x000000)
#define JABlack900Color UIColorFromRGB(0x202020)
#define JABlack800Color UIColorFromRGB(0x808080)
#define JABlack700Color UIColorFromRGB(0xC5C5C5)
#define JABlack400Color UIColorFromRGB(0xE2E2E2)
#define JABlack300Color UIColorFromRGB(0xF0F0F0)
#define JABlack200Color UIColorFromRGB(0xF5F5F5)
#define JAOrange1Color UIColorFromRGB(0xf68b1e)
#define JAGreen1Color UIColorFromRGB(0xa3cf62)
#define JABlue1Color UIColorFromRGB(0x416998)
#define JASysBlueColor UIColorFromRGB(0x007aff)
