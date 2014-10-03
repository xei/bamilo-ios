//
//  RITrackingWrapper.h
//  RITrackingWrapper
//
//  Created by Miguel Chaves on 15/07/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

#ifdef DEBUG
#define RIRaiseError(fmt, ...) \
NSAssert(NO, @"%@", [NSString stringWithFormat:(fmt), ##__VA_ARGS__]); \
NSLog((@"Func: %s, Line: %d, %@"), __PRETTY_FUNCTION__, __LINE__, \
[NSString stringWithFormat:(fmt), ##__VA_ARGS__]);
#else
#define RIRaiseError(fmt, ...) \
NSLog((@"Func: %s, Line: %d, %@"), __PRETTY_FUNCTION__, __LINE__, \
[NSString stringWithFormat:(fmt), ##__VA_ARGS__]);
#endif

#ifdef DEBUG
#define RIDebugLog(fmt, ...) \
if ([RITrackingWrapper sharedInstance].debug) NSLog(@"RITrackingWrapper: %@",[NSString stringWithFormat:(fmt), ##__VA_ARGS__]);
#else
#define RIDebugLog(fmt, ...) return;
#endif

#import <Foundation/Foundation.h>
#import "RITrackingConfiguration.h"

/**
 *  Struct to identify the state of the cart
 */
typedef NS_ENUM(NSInteger, RICartState) {
    RICartEmpty         = 0,
    RICartHasItems      = 1,
    RICartDidCheckout   = 2
};

/**
 *  This protocol implements tracking to user timing
 */
@protocol RITrackingTiming <NSObject>

/**
 *  Track the time of one reference
 *
 *  @param millis The time spent
 *  @param reference The reference of the event
 */
- (void)trackTimingInMillis:(NSNumber*)millis reference:(NSString*)reference;

@end

/**
 *  This protocol implements tracking to the notifications
 */
@protocol RINotificationTracking <NSObject>

/**
 *  Register application for receive remote notification
 *
 *  @param deviceToken The token of the device regists
 */
- (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;

/**
 *  Track a received remote notification
 *
 *  @param userInfo The user information of the remote notification
 */
- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 *  Track a received local notification
 *
 *  @param notification The notification received
 */
- (void)applicationDidReceiveLocalNotification:(UILocalNotification *)notification;

/**
 *  Handle a push notification
 *
 *  @param info The push notification info.
 */
- (void)handlePushNotifcation:(NSDictionary *)info;

@end

/**
 *  This protocol implements tracking to a given screen
 */
@protocol RIScreenTracking <NSObject>

/**
 *  Track the display of a presented screen view to the user, given its name
 *
 *  @param name The screen's name.
 */
- (void)trackScreenWithName:(NSString *)name;

@end

/**
 *  API protocol for exception tracking
 */
@protocol RIExceptionTracking <NSObject>

/**
 *  Track an exception occurrence by name
 *
 *  @param name The exception that happed.
 */
- (void)trackExceptionWithName:(NSString *)name;

@end

/**
 *  API protocol for deeplink URL tracking
 */
@protocol RIOpenURLTracking <NSObject>

/**
 *  Track a deeplink URL
 *
 *  @param url The URL opened.
 */
- (void)trackOpenURL:(NSURL *)url;

/**
 *  API protocol for deeplink URL tracking
 */
@optional

/**
 *  Register a handler block to be called when the given pattern matches a deeplink URL.
 *
 *  The deepling URL pattern may contain capture directives of the format `{<name>}` where '<name>'
 *  is replaced with the actual property name to access the captured information.
 *  The handler block receives a dictionary hash containing key-value properties obtained from pattern
 *  capture directives and from the query string of the deeplink URL.
 *
 *  @param handler A handler to be called on matching a deeplink URL.
 *  @param pattern A pattern of regex extended with capture directive syntax.
 */
- (void)registerHandler:(void(^)(NSDictionary *))handler forOpenURLPattern:(NSString *)pattern;

@end

/**
 *  Protocol constants
 */
#define kRIEventTypeKey             @"RIEventTypeKey"
#define kRIEventValueKey            @"RIEventValueKey"
#define kRIEventActionKey           @"RIEventActionKey"
#define kRIEventLabelKey            @"RIEventLabelKey"
#define kRIEventCategoryKey         @"RIEventCategoryKey"
#define kRIEventShopCountryKey      @"RIEventShopCountryKey"
#define kRIEventUserIdKey           @"RIEventUserIdKey"
#define kRIEventSkuKey              @"RIEventSkuKey"
#define kRIEventProductNameKey      @"RIEventProductNameKey"
#define kRIEventCurrencyCodeKey     @"RIEventCurrencyCodeKey"
#define kRIEventPriceKey            @"RIEventPriceKey"
#define kRIEventGenderKey           @"RIEventGenderKey"
#define kRIEventAmountTransactions  @"RIEventAmountTransactions"
#define kRIEventAmountSessions      @"RIEventAmountSessions"
#define kRIEventCategoryIdKey       @"RIEventCategoryIdKey"
#define kRIEventSkusKey             @"RIEventSkusKey"
#define kRIEventCategoryNameKey     @"RIEventCategoryNameKey"
#define kRIEventTreeKey             @"RIEventTreeKey"
#define kRIEventQueryKey            @"RIEventQueryKey"
#define kRIEventProductKey          @"RIEventProductKey"
#define kRIEventProductsKey         @"RIEventProducstKey"
#define kRIEventKeywordsKey         @"RIEventKeywordsKey"
#define kRIEventNewCustomerKey      @"RIEventNewCustomerKey"
#define kRIEventDiscountKey         @"RIEventDiscountKey"
#define kRIEventBrandKey            @"RIEventBrandKey"
#define kRIEventSizeKey             @"RIEventSizeKey"
#define kRIEventTotalWishlistKey    @"RIEventTotalWishlistKey"
#define kRIEventQuantityKey         @"RIEventQuantityKey"
#define kRIEventTotalCartKey        @"RIEventTotalCartKey"
#define kRIEventTransactionIdKey    @"RIEventTransactionIdKey"
#define kRIEventTotalTransactionKey @"RIEventTotalTransactionKey"
#define kRIEventUserFirstNameKey    @"RIEventUserFirstNameKey"
#define kRIEventBrandFilterKey      @"RIEventBrandFilterKey"
#define kRIEventColorFilterKey      @"RIEventColorFilterKey"
#define kRIEventCategoryFilterKey   @"RIEventCategoryFilterKey"
#define kRIEventPriceFilterKey      @"RIEventPriceFilterKey"
#define kRIEventNumberOfProductsKey @"RIEventNumberOfProductsKey"
#define kRIEventTopCategoryKey      @"RIEventTopCategoryKey"
#define kRIEventLocationKey         @"RIEventLocationKey"
#define kRIEventAccountDateKey      @"RIEventAccountDateKey"
#define kRIEventAgeKey              @"RIEventAgeKey"
#define kRIEventRatingKey           @"RIEventRatingKey"
#define kRIEventRatingPriceKey      @"RIEventRatingPriceKey"
#define kRIEventRatingAppearanceKey @"RIEventRatingAppearanceKey"
#define kRIEventRatingQualityKey    @"RIEventRatingQualityKey"
#define kRIEventPageNumberKey       @"RIEventPageNumberKey"
#define kRIEventFilterTypeKey       @"RIEventFilterTypeKey"
#define kRIEventSortTypeKey         @"RIEventSortTypeKey"
#define kRIEventPaymentMethodKey    @"RIEventPaymentMethodKey"
#define kRIEventScreenNameKey       @"RIEventScreenNameKey"
#define kRIEventColorKey            @"RIEventColorKey"

/**
 *  Struct to identify events
 */
typedef NS_ENUM(NSInteger, RIEventType) {
    RIEventAutoLoginSuccess = 0,
    RIEventAutoLoginFail = 1,
    RIEventLoginSuccess = 2,
    RIEventLoginFail = 3,
    RIEventRegisterStart = 4,
    RIEventRegisterSuccess = 5,
    RIEventRegisterFail = 6,
    RIEventFacebookLoginSuccess = 7,
    RIEventFacebookLoginFail = 8,
    RIEventLogout = 9,
    RIEventSideMenu = 10,
    RIEventCategories = 11,
    RIEventCatalog = 12,
    RIEventFilter = 13,
    RIEventSort = 14,
    RIEventRelatedItem = 15,
    RIEventAddToCart = 16,
    RIEventRemoveFromCart = 17,
    RIEventAddToWishlist = 18,
    RIEventRemoveFromWishlist = 19,
    RIEventRateProduct = 20,
    RIEventSearch = 21,
    RIEventShareFacebook = 22,
    RIEventShareTwitter = 23,
    RIEventShareEmail = 24,
    RIEventShareSMS = 25,
    RIEventShareOther = 26,
    RIEventCheckoutStart = 27,
    RIEventCheckoutAboutYou = 28,
    RIEventCheckoutAddresses = 29,
    RIEventCheckoutShipping = 30,
    RIEventCheckoutPayment = 31,
    RIEventCheckoutOrder = 32,
    RIEventCheckoutEnd = 33,
    RIEventCheckoutContinueShopping = 34,
    RIEventCheckoutError = 35,
    RIEventNewsletter = 36,
    RIEventCallToOrder = 37,
    RIEventGuestCustomer = 38,
    RIEventViewProduct = 39,
    RIEventViewListing = 40,
    RIEventViewCart = 41,
    RIEventTransactionConfirm = 42,
    RIEventFacebookHome = 43,
    RIEventFacebookViewListing = 44,
    RIEventFacebookViewProduct = 45,
    RIEventFacebookSearch = 46,
    RIEventFacebookViewWishlist = 47,
    RIEventFacebookViewCart = 48,
    RIEventFacebookViewTransaction = 49,
    RIEventChangeCountry = 50,
    RIEventViewCampaign = 51,
    RIEventTopCategory = 52,
    RIEventAddFromWishlistToCart = 53,
    RIEventSignupSuccess = 54,
    RIEventSignupFail = 55,
    RIEventIncreaseQuantity = 56,
    RIEventDecreaseQuantity = 57,
    RIEventRateProductGlobal = 58,
    RIEventViewRatings = 59,
    RIEventViewGTMListing = 60,
    RIEventIndividualFilter = 61,
    RIEventCheckoutAddAddressSuccess = 62,
    RIEventCheckoutAddAddressFail = 63,
    RIEventCheckoutPaymentSuccess = 64,
    RIEventCheckoutPaymentFail = 65,
    RIEventCloseApp = 66
};

/**
 *  This protocol implements tracking to an event
 */
@protocol RIEventTracking <NSObject>

/**
 * A method to track an event happening inside the application.
 *
 * The event may be triggered by the user and further information, such as category, action and
 * value are available.
 *
 * @param eventType Type of the event
 * @param data (mandatory) Data about the event
 */
- (void)trackEvent:(NSNumber *)eventType
              data:(NSDictionary *)data;

@end

/**
 *  Protocol constants
 */
#define kRIEcommerceTransactionIdKey        @"RIEcommerceTransactionIdKey"
#define kRIEcommerceTaxKey                  @"RIEcommerceTaxKey"
#define kRIEcommerceShippingKey             @"RIEcommerceShippingKey"
#define kRIEcommerceCurrencyKey             @"RIEcommerceCurrencyKey"
#define kRIEcommerceTotalValueKey           @"RIEcommerceTotalValueKey"
#define kRIEcommerceConvertedTotalValueKey  @"RIEcommerceConvertedTotalValueKey"
#define kRIEcommerceSkusKey                 @"RIEcommerceSkusValueKey"
#define kRIEcommerceGuestKey                @"RIEcommerceGuestKey"
#define kRIEcommerceProducts                @"RIEcommerceProducts"
#define kRIEcommerceCouponKey               @"RIEcommerceCouponKey"
#define kRIEcommerceCartAverageValueKey     @"RIEcommerceCartAverageValueKey"
#define kRIEcommerceAffiliationKey          @"RIEcommerceAffiliationKey"
#define kRIEcommercePaymentMethodKey        @"RIEcommercePaymentMethodKey"
#define kRIEcommercePreviousPurchases       @"RIEcommercePreviousPurchases"

/**
 *  This protocol implements tracking to the commerce transactions
 *
 *  The implementation to this protocol should maintain a state machine to collect cart information.
 *  Adding/Removing to/from cart is forwarded to Ad-X and A4S (http://goo.gl/iSjKut) instantly.
 *  A4S (http://goo.gl/iSjKut) and GA (http://goo.gl/k6iRRC) receive information on checkout.
 */
@protocol RIEcommerceEventTracking <NSObject>

/**
 *  This method with include any previous calls to trackAddToCartForProductWithID and
 *  trackRemoveFromCartForProductWithID.
 *
 *  @param data The transaction data
 */
- (void)trackCheckout:(NSDictionary *)data;

@end


/**
 *  This protocol implements tracking of the app launch
 */
@protocol RILaunchEventTracker <NSObject>

/**
 *  Send launch event
 *
 *  @param dataDictionary The data associated with the launch
 */
- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary;

@end

/**
 *  Protocol constants
 */
#define kRILaunchEventInitialViewLoadedNotification @"RILaunchInitialViewLoadedNotification"
#define kRILaunchEventDurationDataKey               @"RILaunchEventDurationDataKey"
#define kRILaunchEventAppVersionDataKey             @"RILaunchEventAppVersionDataKey"
#define kRILaunchEventDeviceModelDataKey            @"RILaunchEventDeviceModelDataKey"
#define kRILaunchEventCampaignKey                   @"RILaunchEventCampaignKey"
#define kRILaunchEventSourceKey                     @"RILaunchEventSourceKey"

/**
 *  RITracker protocol implements the initialization of the trackers
 */
@protocol RITracker <NSObject>

/**
 *  Queue to avoid different trackers to stall each other or the app flow.
 */
@property NSOperationQueue *queue;

/**
 *  Array with the registered events for a tracker
 */
@property NSArray *registeredEvents;

/**
 *  Hook to recognise an app launch, given launch options
 *
 *  @param options The launching options.
 */
- (void)applicationDidLaunchWithOptions:(NSDictionary *)options;

@end

/**
 *  RICampaignTracker protocol implements the campaign tracking
 */
@protocol RICampaignTracker <NSObject>

/**
 *  Track a given campaign
 *
 *  @param options The campaign data
 */
- (void)trackCampaingWithData:(NSDictionary *)data;

@end

/**
 *  Interface of the RITracking
 */
@interface RITrackingWrapper : NSObject
<
    RIEventTracking,
    RIScreenTracking,
    RIExceptionTracking,
    RINotificationTracking,
    RIOpenURLTracking,
    RIEcommerceEventTracking,
    RITrackingTiming,
    RILaunchEventTracker,
    RICampaignTracker
>

/**
 *  A flag to enable debug logging.
 */
@property (nonatomic) BOOL debug;

/**
 *  The current state of the cart
 */
@property (nonatomic, assign) RICartState cartState;

/**
 *  Load the configuration needed from a plist file in the given path and launching options
 *
 *  @param path Path to the configuration file (plist file).
 *  @param launchOptions The launching options.
 */
- (void)startWithConfigurationFromPropertyListAtPath:(NSString *)path
                                       launchOptions:(NSDictionary *)launchOptions;

/**
 *  Creates and initializes an `RITracking`object
 *
 *  @return The newly-initialized object
 */
+ (instancetype)sharedInstance;

/**
 *  Returns the state of the cart
 */
- (RICartState)getCartState;

@end
