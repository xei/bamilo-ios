//
//  JAConstants.h
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

// Notifications
#define kCancelLoadingNotificationName @"CANCEL_LOADING_NOTIFICATION"
#define kCancelButtonPressedInMenuSearchBar @"PRESSED_BACK_BUTTON_NOTIFICATION"
#define kMenuDidSelectOptionNotification @"NOTIFICATION_SELECTED_ITEM_MENU"
#define kMenuDidSelectLeafCategoryNotification @"NOTIFICATION_SELECTED_LEAF_CATEGORY"
#define kOpenMenuNotification @"NOTIFICATION_OPEN_MENU"
#define kOpenCenterPanelNotification @"NOTIFICATION_OPEN_CENTER_PANEL"
#define kOpenCartNotification @"NOTIFICATION_OPEN_CART"
#define kUpdateCartNotification @"NOTIFICATION_UPDATE_CART"
#define kUpdateCartNotificationValue @"NOTIFICATION_UPDATE_CART_VALUE"
#define kDidPressApplyNotification @"DID_PRESS_APPLY_NOTIFICATION"
#define kDidPressDoneNotification @"DID_PRESS_DONE_NOTIFICATION"
#define kDidPressEditNotification @"DID_PRESS_EDIT_NOTIFICATION"
#define kEditShouldChangeStateNotification @"EDIT_SHOULD_CHANGE_NOTIFICATION"
#define kTurnOffLeftSwipePanelNotification @"NOTIFICATION_TURN_OFF_LEFT_SWIPE_PANEL"
#define kTurnOnLeftSwipePanelNotification @"NOTIFICATION_TURN_ON_LEFT_SWIPE_PANEL"
#define kShowBackNofication @"NOTIFICATION_SHOW_BACK"
#define kShowBackButtonWithTitleNofication @"NOTIFICATION_SHOW_BACK_BUTTON_WITH_TITLE"
#define kUserLoggedInNotification @"NOTIFICATION_USER_LOGGED_IN"
#define kUserLoggedOutNotification @"NOTIFICATION_USER_LOGGED_OUT"
#define kShowMainFiltersNavNofication @"NOTIFICATION_SHOW_MAIN_FILTERS_NAVIGATION"
#define kShowSpecificFilterNavNofication @"NOTIFICATION_SHOW_SPECIFIC_FILTER_NAVIGATION"
#define kShowHomeScreenNotification @"NOTIFICATION_HOME_SCREEN"

//teasers
#define kDidSelectTeaserWithCatalogUrlNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_CATALOG_URL"
#define kDidSelectTeaserWithPDVUrlNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_PDV_URL"
#define kDidSelectTeaserWithAllCategoriesNofication @"NOTIFICATION_DID_SELECT_TEASER_WITH_ALL_CATEGORIES"
#define kDidSelectCategoryFromCenterPanelNotification @"NOTIFICATION_SELECTED_CATEGORY_FROM_CENTER_PANEL"

// Update alert view
#define kForceUpdateAlertViewTag 0
#define kUpdateAvailableAlertViewTag 1

// App url (this is needed to redirect to itunes connect to update the app)
#define kAppStoreUrl @"https://itunes.apple.com/us/app/the-iconic-app/id686483021?ls=1&mt=8"

// Colors

// Colors - Backgrounds
#define JANavBarBackgroundGrey UIColorFromRGB(0xeaeaea)
#define JABackgroundGrey UIColorFromRGB(0xc8c8c8)

// Colors - Buttons
#define JAButtonOrange UIColorFromRGB(0xfaa41a)
#define JAButtonTextOrange UIColorFromRGB(0x4e4e4e)

// Colors - Text
#define JALabelGrey UIColorFromRGB(0xcccccc)
