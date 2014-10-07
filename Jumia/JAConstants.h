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
#define kOpenCenterPanelNotification @"NOTIFICATION_OPEN_CENTER_PANEL"
#define kTurnOffLeftSwipePanelNotification @"NOTIFICATION_TURN_OFF_LEFT_SWIPE_PANEL"
#define kTurnOnLeftSwipePanelNotification @"NOTIFICATION_TURN_ON_LEFT_SWIPE_PANEL"
//************

//************ center navigation controller notifications
#define kCloseCurrentScreenNotification @"NOTIFICATION_CLOSE_CURRENT_SCREEN"
#define kMenuDidSelectOptionNotification @"NOTIFICATION_SELECTED_ITEM_MENU"
#define kOpenCatalogFromUndefinedSearch @"NOTIFICATION_OPEN_CATALOG_FROM_UNDEF_SEARCH"
#define kMenuDidSelectLeafCategoryNotification @"NOTIFICATION_SELECTED_LEAF_CATEGORY"
#define kShowHomeScreenNotification @"NOTIFICATION_HOME_SCREEN"
#define kSelectedRecentSearchNotification @"NOTIFICATION_SELECTED_RECENT_SEARCH"
#define kOpenCartNotification @"NOTIFICATION_OPEN_CART"
#define kShowSignUpScreenNotification @"NOTIFICATION_SHOW_SIGN_UP_SCREEN"
#define kShowSignInScreenNotification @"NOTIFICATION_SHOW_SIGN_IN_SCREEN"
#define kShowForgotPasswordScreenNotification @"NOTIFICATION_SHOW_FORGOT_PASSWORD_SCREEN"
#define kShowFavoritesScreenNotification @"NOTIFICATION_SHOW_SIGN_IN_SCREEN"

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
#define kShowTrackOrderScreenNotification @"NOTIFICATION_SHOW_TRACK_ORDER_SCREEN"

//teasers
#define kDidSelectTeaserWithCatalogUrlNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_CATALOG_URL"
#define kDidSelectTeaserWithPDVUrlNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_PDV_URL"
#define kDidSelectCampaignNofication @"NOTIFICATION_DID_SELECT_CAMPAING"
#define kDidSelectTeaserWithAllCategoriesNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_ALL_CATEGORIES"
#define kDidSelectCategoryFromCenterPanelNotification @"NOTIFICATION_SELECTED_CATEGORY_FROM_CENTER_PANEL"

//navbar notification
#define kChangeNavigationBarNotification @"NOTIFICATION_CHANGE_NAVIGATION_BAR"
#define kEditShouldChangeStateNotification @"EDIT_SHOULD_CHANGE_NOTIFICATION"
#define kDoneShouldChangeStateNotification @"DONE_SHOULD_CHANGE_NOTIFICATION"
#define kDidPressDoneNotification @"DID_PRESS_DONE_NOTIFICATION"
#define kDidPressEditNotification @"DID_PRESS_EDIT_NOTIFICATION"

// Ad4Push Notifications
#define A4S_INAPP_NOTIF_VIEW_DID_APPEAR @"A4S_INAPP_NOTIF_VIEW_DID_APPEAR"
#define A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR @"A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR"

//************

//my account notifications
#define kDidSaveUserDataNotification @"DID_SAVE_USER_DATA_NOTIFICATION"
#define kDidSaveEmailNotificationsNotification @"DID_SAVE_EMAIL_NOTIFICATIONS_NOTIFICATION"

// Update alert view
#define kForceUpdateAlertViewTag 0
#define kUpdateAvailableAlertViewTag 1

// App url (this is needed to redirect to itunes connect to update the app)
#define kAppStoreUrl @"https://itunes.apple.com/us/app/jumia-online-shopping/id925015459?ls=1&mt=8"

// Preferences
#define kDidFirstBuyKey @"did_first_buy"
#define kNumberOfSessions @"amount_sessions"
#define kSessionDate @"session_date"

// Colors

// Colors - Backgrounds
#define JANavBarBackgroundGrey UIColorFromRGB(0xeaeaea)
#define JABackgroundGrey UIColorFromRGB(0xc8c8c8)

// Colors - Buttons
#define JAButtonOrange UIColorFromRGB(0xfaa41a)
#define JAButtonTextOrange UIColorFromRGB(0x4e4e4e)

// Colors - Text
#define JALabelGrey UIColorFromRGB(0xcccccc)
