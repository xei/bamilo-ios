//
//  AccengageTracker.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AccengageTracker.h"
#import <AdSupport/AdSupport.h>
#import <Accengage/Accengage.h>
#import "SettingsManager.h"

#define kACCENGAGE_TRACKER_ALIAS @"Accengage"
#define kACCENGAGE_TRACKER_CONFIG_KEY @"Accengage"

#define kAccengageIDFAIdKey @"IDFA"
#define kAccengageLastOpenDate @"App_Last_Open_Date"
#define kAccengageProfilelastPushNotificationOpenedKey @"App_Last_Push_Notification_Opened"
#define kAccengageHasAppEverOpened @"App_Has_Ever_Opened"

//### TRACKING KEYS ###
#define kAccengageProfileLastViewedCategoryName @"Last_Viewed_Category_Name"
#define kAccengageProfileLastViewedCategoryKey @"Last_Viewed_Category_Key"
#define kAccengageLastProductViewed @"Last_Product_Viewed"
#define kAccengageLastSKUViewed @"Last_SKU_Viewed"
#define kAccengageLastBrandViewedKey @"Last_Brand_Viewed_Key"
#define kAccengageLastBrandViewedName @"Last_Brand_Viewed_Name"

//CART
#define kAccengageCartStatus @"Cart_Status"
#define kAccengageCartValue  @"Cart_Value"
#define kAccengageDateLastCartUpdated @"Date_Last_Cart_Updated"
#define kAccengageLastCartProductName @"Last_Cart_Product_Name"
#define kAccengageLastCartSKU @"Last_Cart_SKU"
#define kAccengageLastCategoryAddedToCartName @"Last_Category_Added_To_Cart_Name"
#define kAccengageLastCategoryAddedToCartKey @"Last_Category_Added_To_Cart_Key"
#define kAccengageLastBrandAddedToCartName @"Last_Brand_Added_To_Cart_Name"
#define kAccengageLastBrandAddedToCartKey @"Last_Brand_Added_To_Cart_Key"
#define kAccengageDateLastCartUpdated @"Date_Last_Cart_Updated"

//WISHLIST
#define kAccengageWishlistStatus @"Wish_List_Status"
#define kAccengageLastWishlistProductName @"Last_Wishlist_Product_Name"
#define kAccengageLastBrandAddedToWishlistKey @"Last_Brand_Added_To_Wish_List_Key"
#define kAccengageLastBrandAddedToWishlistName @"Last_Brand_Added_To_Wish_List_Name"
#define kAccengageLastCategoryAddedToWishlistName @"Last_Category_Added_To_Wish_List_Name"
#define kAccengageLastCategoryAddedToWishlistKey @"Last_Category_Added_To_Wish_List_Key"
#define kAccengageLastWishlistSku @"Last_Wish_List_SKU"

//USER
#define kAccengageProfileUserIdKey @"UserID"
#define kAccengageProfileFirstNameKey @"First_Name"
#define kAccengageProfileLastNameKey @"Last_Name"
#define kAccengageProfileBirthDayKey @"User_DOB"
#define kAccengageProfileUserGenderKey @"User_Gender"

//CHECKOUT
#define kAccengageLastOrderDate @"Last_Order_Date"
#define kAccengageAggregatedNumberOfPurchase @"Aggregated_Number_Of_Purchase"
#define kAccengageOrderNumber @"Order_Number"
#define kAccengageLastBrandPurchasedName @"Last_Brand_Purchased_Name"
#define kAccengageLastBrandPurchasedKey @"Last_Brand_Purchased_Key"
#define kAccengageLastCategoryPurchasedName @"Last_Category_Purchased_Name"
#define kAccengageLastCategoryPurchasedKey @"Last_Category_Purchased_Key"
#define kAccengageLastProductNamePurchased @"Last_Product_Name_Purchased"
#define kAccengageLastSkuPurchased @"Last_SKU_Purchased"
#define kAccengageProfileShopCountryKey @"Shop_Country"
#define kAccengageLanguageSelection @"Language_Selection"

@implementation AccengageTracker

NSString * const kAccengagePartnerID = @"AccengagePartnerID";
NSString * const kAccengagePrivateKey = @"AccengagePrivateKey";
NSString * const kAccengageDeviceToken = @"AccengageDeviceToken";

static AccengageTracker *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AccengageTracker alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    RIDebugLog(@"Initializing %@ tracker", kACCENGAGE_TRACKER_ALIAS);
    
    if (self = [super init]) {
        NSMutableArray *events = [NSMutableArray new];
        
        [events addObject:[NSNumber numberWithInt:RIEventViewProduct]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToCart]];
        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromCart]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventAutoLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventUserInfoChanged]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutEnd]];
        [events addObject:[NSNumber numberWithInt:RIEventChangeCountry]];
        
        self.registeredEvents = [events copy];
    }
    
    return self;
}

#pragma mark - RITracker
- (void)applicationDidLaunchWithOptions:(NSDictionary *)options {
    RIDebugLog(@"%@ tracker tracks application launch", kACCENGAGE_TRACKER_ALIAS);
    
    NSDictionary *accengageConfigs = [RITrackingConfiguration valueForKey:kACCENGAGE_TRACKER_CONFIG_KEY];
    
    NSString *partnerId = [accengageConfigs valueForKey:kAccengagePartnerID];
    NSString *privateKey = [accengageConfigs valueForKey:kAccengagePrivateKey];
    NSString *deviceToken = [accengageConfigs valueForKey:kAccengageDeviceToken];
    
    if (!partnerId) {
        RIRaiseError(@"%@ - Missing user ID in tracking properties", kACCENGAGE_TRACKER_ALIAS);
        return;
    }
    
    if (!privateKey) {
        RIRaiseError(@"%@ - Missing private key in tracking properties", kACCENGAGE_TRACKER_ALIAS);
        return;
    }
    
    if (!deviceToken) {
        RIRaiseError(@"%@ - Missing device token in tracking properties", kACCENGAGE_TRACKER_ALIAS);
        return;
    }
    
//ACCENGAGE CONFIGURATION
    ACCConfiguration *config = [ACCConfiguration defaultConfig];
    config.appId = partnerId;
    config.appPrivateKey = privateKey;
    config.automaticPushDelegateEnabled = NO;
    
    #ifdef IS_RELEASE
        [Accengage setLoggingEnabled:NO];
    #else
        [Accengage setLoggingEnabled:YES];
    #endif
    
    [Accengage startWithConfig:config];
    
// SETUP DEVICE INFO
    NSMutableDictionary *deviceInfo = [NSMutableDictionary new];
    [deviceInfo setObject:partnerId forKey:kAccengageProfileUserIdKey];
    NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [deviceInfo setObject:idfaString ?: @"" forKey:kAccengageIDFAIdKey];

    [deviceInfo setObject:[self getFormattedDateStringForTracking] forKey:kAccengageLastOpenDate];
    
    [Accengage updateDeviceInfo:deviceInfo];
    
// PUSH NOTIFICATION ACTIVATION
    //NSSet *categories = [[Accengage push] accengageCategories];
    
    // The app custom categories set
    //[[Accengage push] setCustomCategories:customCategories];
    
    // Register for notification
    ACCNotificationOptions notificationOptions = (ACCNotificationOptionSound | ACCNotificationOptionBadge | ACCNotificationOptionAlert | ACCNotificationOptionCarPlay);
    [[Accengage push] registerForUserNotificationsWithOptions:notificationOptions];
}

#pragma mark - RINotificationTracking
- (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    RIDebugLog(@"%@ - Registering for remote notifications.", kACCENGAGE_TRACKER_ALIAS);

    NSMutableDictionary *deviceInfo = [NSMutableDictionary new];
    [deviceInfo setObject:[self getFormattedDateStringForTracking] forKey:kAccengageProfilelastPushNotificationOpenedKey];
    [Accengage updateDeviceInfo:deviceInfo];
    
    [[Accengage push] didRegisterForUserNotificationsWithDeviceToken:deviceToken];
}

- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo {
    RIDebugLog(@"%@ - Received remote notification: %@", kACCENGAGE_TRACKER_ALIAS, userInfo);
    
    [[Accengage push] didReceiveRemoteNotification:userInfo];
}

- (void)applicationDidReceiveLocalNotification:(UILocalNotification *)notification {
    RIDebugLog(@"%@ - Received local notification: %@", kACCENGAGE_TRACKER_ALIAS, notification);
    
    [[Accengage push] didReceiveLocalNotification:notification];
}

- (void)applicationHandleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
    RIDebugLog(@"%@ - Handle action with identifier : %@", kACCENGAGE_TRACKER_ALIAS, identifier);
    
    [[Accengage push] handleActionWithIdentifier:identifier forRemoteNotification:userInfo];
}

#pragma mark - RIOpenURLTracking
-(void)trackOpenURL:(NSURL *)url {
    RIDebugLog(@"%@ - Track open URL : %@", kACCENGAGE_TRACKER_ALIAS, [url absoluteString]);
    
    [Accengage handleOpenURL:url];
}

#pragma mark - RILaunchEventTracker
- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary {
    RIDebugLog(@"%@ - Launch event with data: %@", kACCENGAGE_TRACKER_ALIAS, dataDictionary);
    
    if(![[SettingsManager loadSettingsForKey:kAccengageHasAppEverOpened] boolValue]) {
        NSMutableArray *params = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"firstOpenDate=%@", [self getFormattedDateStringForTracking]], nil];
        [Accengage trackEvent:1003 withParameters:params];
        [SettingsManager saveSettings:@YES forKey:kAccengageHasAppEverOpened];
    }
}

#pragma mark - RIEventTracking
- (void)trackEvent:(NSNumber *)eventType data:(NSDictionary *)data {
    RIDebugLog(@"%@ - Tracking event = %@, data %@", kACCENGAGE_TRACKER_ALIAS, eventType, data);
    
    if([self.registeredEvents containsObject:eventType]) {
        //NSString *itemId = @"";
        //NSString *itemName = @"";
        //NSString *itemCategoryId = @"";
        //NSString *itemPrice = @"";
        //NSString *itemCurrency = @"";
        NSString *eventDate = [self getFormattedDateStringForTracking];
        
        NSMutableDictionary *deviceInfo = [NSMutableDictionary new];
        NSMutableArray *parameters = [NSMutableArray new];
        NSInteger event = [eventType integerValue];
        
        switch (event) {
            case RIEventViewProduct: {
                NSString *productSku = [data objectForKey:kRIEventProductKey];
                if (productSku) {
                    [deviceInfo setObject:productSku forKey:kAccengageLastSKUViewed];
                }
                
                NSString *productName = [data objectForKey:kRIEventProductNameKey];
                if (productName) {
                    [deviceInfo setObject:productName forKey:kAccengageLastProductViewed];
                }

                NSString* productBrandKey = [data objectForKey:kRIEventBrandKey];
                if (productBrandKey) {
                    [deviceInfo setObject:productBrandKey forKey:kAccengageLastBrandViewedKey];
                }
                
                NSString *productBrandName = [data objectForKey:kRIEventBrandName];
                if (productBrandName) {
                    [deviceInfo setObject:productBrandName forKey:kAccengageLastBrandViewedName];
                }
                
                NSString *categoryId = [data objectForKey:kRIEventCategoryIdKey];
                if (categoryId) {
                    [deviceInfo setObject:categoryId forKey:kAccengageProfileLastViewedCategoryKey];
                }
                
                NSString *categoryName = [data objectForKey:kRIEventCategoryNameKey];
                if (categoryName) {
                    [deviceInfo setObject:categoryName forKey:kAccengageProfileLastViewedCategoryName];
                }
                
                [Accengage updateDeviceInfo:deviceInfo];
            }
            break;
            
            case RIEventAddToCart: {
                [deviceInfo setObject:eventDate forKey:kAccengageDateLastCartUpdated];
                
                NSString *productSku = [data objectForKey:kRIEventSkuKey];
                if(productSku) {
                    [deviceInfo setObject:productSku forKey:kAccengageLastCartSKU];
                }
                
                NSString *productName = [data objectForKey:kRIEventProductNameKey];
                if(productName) {
                    [deviceInfo setObject:productName forKey:kAccengageLastCartProductName];
                }
                
                NSString* productBrandKey = [data objectForKey:kRIEventBrandKey];
                if (productBrandKey) {
                    [deviceInfo setObject:productBrandKey forKey:kAccengageLastBrandAddedToCartKey];
                }
                
                NSString* productBrandName = [data objectForKey:kRIEventBrandName];
                if (productBrandName) {
                    [deviceInfo setObject:productBrandName forKey:kAccengageLastBrandAddedToCartName];
                }
                
                NSString *productCategoryId = [data objectForKey:kRIEventCategoryIdKey];
                if (productCategoryId) {
                    [deviceInfo setObject:productCategoryId forKey:kAccengageLastCategoryAddedToCartKey];
                }
                
                NSString *productCategoryName = [data objectForKey:kRIEventCategoryNameKey];
                if (productCategoryName) {
                    [deviceInfo setObject:productCategoryName forKey:kAccengageLastCategoryAddedToCartName];
                }
                
                NSString *price = [[data objectForKey:kRIEventPriceKey] stringValue];
                NSString *currency = [data objectForKey:kRIEventCurrencyCodeKey];
                
                ACCCartItem *item = [ACCCartItem itemWithId:productSku name:productName brand:productBrandName category:productCategoryName price:[price doubleValue] quantity:1];
                [Accengage trackCart:@"1" currency:currency item:item];
                
                NSNumber *cartQuantity = [data objectForKey:kRIEventQuantityKey];
                if (cartQuantity) {
                    [deviceInfo setObject:cartQuantity forKey:kAccengageCartStatus];
                }
                
                NSString *cartTotal = [[data objectForKey:kRIEventTotalCartKey] stringValue];
                if (cartTotal) {
                    [deviceInfo setObject:cartTotal forKey:kAccengageCartValue];
                }
                
                [Accengage updateDeviceInfo:deviceInfo];
            }
            break;
            
            case RIEventRemoveFromCart: {
                [deviceInfo setObject:eventDate forKey:kAccengageDateLastCartUpdated];
                
                NSString *cartQuantity = [data objectForKey:kRIEventQuantityKey];
                if (cartQuantity) {
                    [deviceInfo setObject:cartQuantity forKey:kAccengageCartStatus];
                }
                
                NSString *cartTotal = [[data objectForKey:kRIEventTotalCartKey] stringValue];
                if (cartTotal) {
                    [deviceInfo setObject:cartTotal forKey:kAccengageCartValue];
                }
            
                [Accengage updateDeviceInfo:deviceInfo];
            }
            break;
            
            case RIEventAddToWishlist: {
                NSNumber *totalWishlistKey = [data objectForKey:kRIEventTotalWishlistKey];
                if (totalWishlistKey) {
                    [deviceInfo setObject:totalWishlistKey forKey:kAccengageWishlistStatus];
                }
                
                NSString *productName = [data objectForKey:kRIEventProductNameKey];
                if(productName) {
                    [deviceInfo setObject:productName forKey:kAccengageLastWishlistProductName];
                }

                NSString *productBrandName = [data objectForKey:kRIEventBrandName];
                if (productBrandName) {
                    [deviceInfo setObject:productBrandName forKey:kAccengageLastBrandAddedToWishlistName];
                }
                
                NSString *productBrandKey = [data objectForKey:kRIEventBrandKey];
                if (productBrandKey) {
                    [deviceInfo setObject:productBrandKey forKey:kAccengageLastBrandAddedToWishlistKey];
                }
                
                NSString *productCategoryName = [data objectForKey:kRIEventCategoryNameKey];
                if (productCategoryName) {
                    [deviceInfo setObject:productCategoryName forKey:kAccengageLastCategoryAddedToWishlistName];
                }
                
                NSString *productCategoryId = [data objectForKey:kRIEventCategoryIdKey];
                if (productCategoryId) {
                    [deviceInfo setObject:productCategoryId forKey:kAccengageLastCategoryAddedToWishlistKey];
                }
                
                NSString *skuKey = [data objectForKey:kRIEventSkuKey];
                if (skuKey) {
                    [deviceInfo setObject:skuKey forKey:kAccengageLastWishlistSku];
                }
                
                [Accengage trackEvent:1005 withParameters:parameters];
                [Accengage updateDeviceInfo:deviceInfo];
            }
            break;
            
            case RIEventRemoveFromWishlist: {
                NSNumber *totalWishlistKey = [data objectForKey:kRIEventTotalWishlistKey];
                if (totalWishlistKey) {
                    [deviceInfo setObject:totalWishlistKey forKey:kAccengageWishlistStatus];
                }
                
                [Accengage updateDeviceInfo:deviceInfo];
            }
            break;
            
            case RIEventLoginSuccess:
            case RIEventAutoLoginSuccess:
            case RIEventFacebookLoginSuccess: {
                NSNumber *userID = [data objectForKey:kRIEventUserIdKey];
                if(userID) {
                    [parameters addObject:[NSString stringWithFormat:@"loginUserID=%@", [userID stringValue]]];
                    [deviceInfo setObject:userID forKey:kAccengageProfileUserIdKey];
                }
                
                NSString *userFirstName = [data objectForKey:kRIEventUserFirstNameKey];
                if(userFirstName) {
                    [deviceInfo setObject:userFirstName forKey:kAccengageProfileFirstNameKey];
                }
                
                NSString *userLastName = [data objectForKey:kRIEventUserLastNameKey];
                if(userLastName) {
                    [deviceInfo setObject:userLastName forKey:kAccengageProfileLastNameKey];
                }
                
                NSString *gender = [data objectForKey:kRIEventGenderKey];
                if (gender) {
                    [deviceInfo setObject:gender forKey:kAccengageProfileUserGenderKey];
                }
                
                NSString *birthDay = [data objectForKey:kRIEventBirthDayKey];
                if(birthDay) {
                    [deviceInfo setObject:birthDay forKey:kAccengageProfileBirthDayKey];
                }
                
                [Accengage trackEvent:1001 withParameters:parameters];
                [Accengage updateDeviceInfo:deviceInfo];
            }
            break;
                
            case RIEventUserInfoChanged: {
                NSNumber *userId = [data objectForKey:kRIEventUserIdKey];
                if(userId) {
                    [deviceInfo setObject:userId forKey:kAccengageProfileUserIdKey];
                }
                
                NSString *birthDay = [data objectForKey:kRIEventBirthDayKey];
                if (birthDay) {
                    [deviceInfo setObject:birthDay forKey:kAccengageProfileBirthDayKey];
                }
                
                NSString *userFirstName = [data objectForKey:kRIEventUserFirstNameKey];
                if(userFirstName) {
                    [deviceInfo setObject:userFirstName forKey:kAccengageProfileFirstNameKey];
                }
                
                NSString *uerLastName = [data objectForKey:kRIEventUserLastNameKey];
                if (uerLastName) {
                    [deviceInfo setObject:uerLastName forKey:kAccengageProfileLastNameKey];
                }
                
                NSString *userGender = [data objectForKey:kRIEventGenderKey];
                if (userGender) {
                    [deviceInfo setObject:userGender forKey:kAccengageProfileUserGenderKey];
                }
                
                [Accengage updateDeviceInfo:deviceInfo];
            }
            break;
            
            case RIEventCheckoutEnd: {
                [deviceInfo setObject:eventDate forKey:kAccengageLastOrderDate];
                
                NSString* cartTotal = [data objectForKey:kRIEventTotalCartKey];
                if (cartTotal) {
                    [deviceInfo setObject:cartTotal forKey:kAccengageCartStatus];
                }
                
                NSNumber *amountTransactions = [data objectForKey:kRIEventAmountTransactions];
                if (amountTransactions) {
                    [deviceInfo setObject:amountTransactions forKey:kAccengageAggregatedNumberOfPurchase];
                }
                
                NSString *orderNumber = [data objectForKey:kRIEventOrderNumber];
                if (orderNumber) {
                    [deviceInfo setObject:orderNumber forKey:kAccengageOrderNumber];
                }
                
                NSString *productBrandName = [data objectForKey:kRIEventBrandName];
                if(productBrandName) {
                    [deviceInfo setObject:productBrandName forKey:kAccengageLastBrandPurchasedName];
                }
                
                NSString *productBrandKey = [data objectForKey:kRIEventBrandKey];
                if (productBrandKey) {
                    [deviceInfo setObject:productBrandKey forKey:kAccengageLastBrandPurchasedKey];
                }
                
                NSString *productCategoryName = [data objectForKey:kRIEventCategoryNameKey];
                if (productCategoryName) {
                    [deviceInfo setObject:productCategoryName forKey:kAccengageLastCategoryPurchasedName];
                }
                
                NSString *productCategoryId = [data objectForKey:kRIEventCategoryIdKey];
                if (productCategoryId) {
                    [deviceInfo setObject:productCategoryId forKey:kAccengageLastCategoryPurchasedKey];
                }
                
                NSString *productName = [data objectForKey:kRIEventProductNameKey];
                if (productName) {
                    [deviceInfo setObject:productName forKey:kAccengageLastProductNamePurchased];
                }
                
                NSString *skuKey = [data objectForKey:kRIEventSkuKey];
                if (skuKey) {
                    [deviceInfo setObject:skuKey forKey:kAccengageLastSkuPurchased];
                }
                
                [Accengage updateDeviceInfo:deviceInfo];
            }
            break;
            
            case RIEventChangeCountry: {
                [deviceInfo setObject:[data objectForKey:kRIEventShopCountryKey] forKey:kAccengageProfileShopCountryKey];
                
                NSString *userLanguage = [data objectForKey:kRIEventLanguageCode];
                if (userLanguage) {
                    [deviceInfo setObject:userLanguage forKey:kAccengageLanguageSelection];
                }
                
                [Accengage updateDeviceInfo:deviceInfo];
            }
            break;
        }
    }
}

#pragma mark - RIEcommerceEventTracking
-(void)trackCheckout:(NSDictionary *)data {
    RIDebugLog(@"%@ - Tracking checkout with data: %@", kACCENGAGE_TRACKER_ALIAS, data);
    
    NSMutableDictionary *deviceInfo = [NSMutableDictionary new];
    [deviceInfo setObject:[self getFormattedDateStringForTracking] forKey:kAccengageDateLastCartUpdated];
    
    NSNumber *numberOfPurchases = numberOfPurchases = [data objectForKey:kRIEventAmountTransactions] ?: [NSNumber numberWithInt:0];
    [deviceInfo setObject:numberOfPurchases forKey:kAccengageAggregatedNumberOfPurchase];
    
    NSNumber *total = [data objectForKey:kRIEcommerceTotalValueKey];
    [deviceInfo setObject:total forKey:kAccengageCartValue];
    
    [deviceInfo setObject:[NSNumber numberWithInteger:0] forKey:kAccengageCartStatus];

    [Accengage updateDeviceInfo:deviceInfo];
    
    NSString *transactionId = [data objectForKey:kRIEcommerceTransactionIdKey];
    NSString *currency = [data objectForKey:kRIEcommerceCurrencyKey];
    
    [Accengage trackPurchase:transactionId currency:currency items:@[] amount:total];
}

#pragma mark - Helpers
-(NSString *) getFormattedDateStringForTracking {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:date];
}

@end
