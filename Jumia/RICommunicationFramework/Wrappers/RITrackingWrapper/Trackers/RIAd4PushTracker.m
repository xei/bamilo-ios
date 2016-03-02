//
//  RIAd4PushTracker.m
//  RITracking
//
//  Created by Miguel Chaves on 20/Mar/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

#import "RIAd4PushTracker.h"
#import "BMA4SInAppNotification.h"
#import "BMA4SNotification.h"
#import "BMA4STracker+Analytics.h"
#import "BMA4STracker.h"
#import "GAIFields.h"
#import "RIGoogleAnalyticsTracker.h"
#import "RICategory.h"
#import <AdSupport/AdSupport.h>
#import "RIProduct.h"
#import "RITarget.h"
#import "JACenterNavigationController.h"

#define kAd4PushIDFAIdKey                                   @"idfa"
#define kAd4PushProfileShopCountryKey                       @"shopCountry"
#define kAd4PushProfilelastPushNotificationOpenedKey        @"lastPNOpened"

#define kAd4PushProfileLastViewedCategoryName @"lastViewedCategoryName"
#define kAd4PushProfileLastViewedCategoryKey @"lastViewedCategoryKey"
#define kAd4PushLastProductViewed @"LastProductViewed"
#define kAd4PushLastSKUViewed @"LastSKUViewed"
#define kAd4PushLastBrandViewedKey @"LastBrandViewedKey"
#define kAd4PushLastBrandViewedName @"LastBrandViewedName"

#define kAd4PushLastCategoryAddedToCartName @"lastCategoryAddedToCartName"
#define kAd4PushLastCategoryAddedToCartKey @"lastCategoryAddedToCartKey"
#define kAd4PushLastBrandAddedToCartName @"LastBrandAddedToCartName"
#define kAd4PushLastBrandAddedToCartKey @"LastBrandAddedToCartKey"

#define kAd4PushCartStatus @"cartStatus"
#define kAd4PushCartValue  @"cartValue"
#define kAd4PushDateLastCartUpdated @"DateLastCartUpdated"
#define kAd4PushLastCartProductName @"lastCartProductName"
#define kAd4PushLastCartSKU @"lastCartSKU"

#define kAd4PushWishlistStatus @"wishlistStatus"
#define kAd4PushLastWishlistProductName @"Last_Wishlist_Product_Name"
#define kAd4PushLastBrandAddedToWishlistKey @"LastBrandAddedToWishlistKey"
#define kAd4PushLastBrandAddedToWishlistName @"LastBrandAddedToWishlistName"
#define kAd4PushLastCategoryAddedToWishlistName @"lastCategoryAddedToWishlistName"
#define kAd4PushLastCategoryAddedToWishlistKey @"lastCategoryAddedToWishlistKey"
#define kAd4PushLastWishlistSku @"Last_Wishlist_SKU"

#define kAd4PushProfileUserIdKey @"userID"
#define kAd4PushProfileFirstNameKey @"firstName"
#define kAd4PushProfileBirthDayKey @"userDOB"
#define kAd4PushProfileUserGenderKey @"userGender"
#define kAd4PushProfileLastNameKey @"lastName"

#define kAd4PushLastOrderDate @"lastOrderDate"
#define kAd4PushAggregatedNumberOfPurchase @"aggregatedNumberOfPurchase"
#define kAd4PushOrderNumber @"OrderNumber"
#define kAd4PushLastBrandPurchasedName @"lastBrandPurchasedName"
#define kAd4PushLastBrandPurchasedKey @"lastBrandPurchasedKey"
#define kAd4PushLastCategoryPurchasedName @"lastCategoryPurchasedName"
#define kAd4PushLastCategoryPurchasedKey @"lastCategoryPurchasedKey"
#define kAd4PushLastProductNamePurchased @"lastProductNamePurchased"
#define kAd4PushLastSkuPurchased @"lastSKUPurchased"

#define kAd4PushLastOpenDate @"Last_Open_Date"

#define kAd4PushLanguageSelection @"LanguageSelection"

@implementation RIAd4PushTracker

NSString * const kRIAdd4PushUserID = @"kRIAdd4PushUserID";
NSString * const kRIAdd4PushPrivateKey = @"kRIAdd4PushPrivateKey";
NSString * const kRIAdd4PushDeviceToken = @"kRIAdd4PushDeviceToken";

@synthesize queue;
@synthesize registeredEvents;

- (id)init
{
    RIDebugLog(@"Initializing Ad4Push tracker");
    
    if ((self = [super init])) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        
        NSMutableArray *events = [[NSMutableArray alloc] init];
        
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

#pragma mark - RITracker protocol

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options
{
    RIDebugLog(@"Add4Push tracker tracks application launch");
    
    NSString *userId = [RITrackingConfiguration valueForKey:kRIAdd4PushUserID];
    NSString *privateKey = [RITrackingConfiguration valueForKey:kRIAdd4PushPrivateKey];
    NSString *deviceToken = [RITrackingConfiguration valueForKey:kRIAdd4PushDeviceToken];
    
    if (!userId) {
        RIRaiseError(@"Missing user ID in tracking properties");
        return;
    }
    
    if (!privateKey) {
        RIRaiseError(@"Missing private key in tracking properties");
        return;
    }
    
    if (!deviceToken) {
        RIRaiseError(@"Missing device token in tracking properties");
        return;
    }
    
    [BMA4STracker setDebugMode:NO];//YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [BMA4STracker trackWithPartnerId:userId
                              privateKey:privateKey
                                 options:options];
        
        NSMutableDictionary *deviceInfo = [[NSMutableDictionary alloc] init];
        [deviceInfo setObject:userId forKey:kAd4PushProfileUserIdKey];
        NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        [deviceInfo setObject:idfaString ? : @"" forKey:kAd4PushIDFAIdKey];
        
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [deviceInfo setObject:[dateFormatter stringFromDate:date] forKey:kAd4PushLastOpenDate];
        
        [BMA4STracker updateDeviceInfo:deviceInfo];
        
        [[BMA4SNotification sharedBMA4S] didFinishLaunchingWithOptions:options];
    });
}

#pragma mark - RINotificationTracking protocol

- (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    RIDebugLog(@"Ad4Push - Registering for remote notifications.");
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSMutableDictionary *deviceInfo = [[NSMutableDictionary alloc] init];
    [deviceInfo setObject:formattedDateString forKey:kAd4PushProfilelastPushNotificationOpenedKey];
    [BMA4STracker updateDeviceInfo:deviceInfo];
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }
    
    [[BMA4SNotification sharedBMA4S] registerDeviceToken:deviceToken];
}

- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo
{
    RIDebugLog(@"Ad4Push - Received remote notification: %@", userInfo);
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[BMA4SNotification sharedBMA4S] didReceiveRemoteNotification:userInfo];
    });
}

- (void)applicationDidReceiveLocalNotification:(UILocalNotification *)notification
{
    RIDebugLog(@"Ad4Push - Received local notification: %@", notification);
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[BMA4SNotification sharedBMA4S] didReceiveLocalNotification:notification];
    });
}

#pragma mark - RIOpenURL protocol

-(void)trackOpenURL:(NSURL *)url
{
    RIDebugLog(@"Ad4Push - Tracking url: %@", url);
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }
    
    [[BMA4SNotification sharedBMA4S] applicationHandleOpenUrl:url];
}

#pragma mark - RIPushNotificaitonTracking

- (void)handlePushNotifcation:(NSDictionary *)info
{
    [self handleNotificationWithDictionary:info];
}

#pragma mark - RILaunchEventTracker implementation

- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary;
{
    RIDebugLog(@"Ad4Push - Launch event with data:%@", dataDictionary);
    
    BOOL hasAppOpended = [[[NSUserDefaults standardUserDefaults] objectForKey:@"has_app_opened"] boolValue];
    if(!hasAppOpended)
    {
        NSDate *date = [NSDate date];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSMutableArray *parameters = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"firstOpenDate=%@", [dateFormatter stringFromDate:date]], nil];
        
        [BMA4STracker trackEventWithType:1003 parameters:parameters];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"has_app_opened"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - RIEventTracking
- (void)trackEvent:(NSNumber *)eventType data:(NSDictionary *)data
{
    RIDebugLog(@"Ad4Push - Tracking event = %@, data %@", eventType, data);
    
    if([self.registeredEvents containsObject:eventType])
    {
        NSString *articleId = @"";
        NSString *name = @"";
        NSString *categoryId = @"";
        NSString *price = @"";
        NSString *currency = @"";
        
        NSDate *date = [NSDate date];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSString *currentDate = [dateFormatter stringFromDate:date];
        
        NSMutableDictionary *deviceInfo = [[NSMutableDictionary alloc] init];
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        NSInteger event = [eventType integerValue];
        switch (event) {
            case RIEventViewProduct:
            {
                if (VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kAd4PushProfileLastViewedCategoryName];
                }
                NSString* categoryIdKey = [data objectForKey:kRIEventCategoryIdKey];
                if (VALID_NOTEMPTY(categoryIdKey, NSString)) {
                    [deviceInfo setObject:categoryIdKey forKey:kAd4PushProfileLastViewedCategoryKey];
                }
                NSString* productName = [data objectForKey:kRIEventProductNameKey];
                if (VALID_NOTEMPTY(productName, NSString)) {
                    [deviceInfo setObject:productName forKey:kAd4PushLastProductViewed];
                }
                NSString* productSku = [data objectForKey:kRIEventProductKey];
                if (VALID_NOTEMPTY(productSku, NSString)) {
                    [deviceInfo setObject:productSku forKey:kAd4PushLastSKUViewed];
                }
                NSString* productBrandName = [data objectForKey:kRIEventBrandName];
                if (VALID_NOTEMPTY(productBrandName, NSString)) {
                    [deviceInfo setObject:productBrandName forKey:kAd4PushLastBrandViewedName];
                }
                NSString* productBrandKey = [data objectForKey:kRIEventBrandKey];
                if (VALID_NOTEMPTY(productBrandKey, NSString)) {
                    [deviceInfo setObject:productBrandKey forKey:kAd4PushLastBrandViewedKey];
                }
                [BMA4STracker updateDeviceInfo:deviceInfo];
            }
                break;
            case RIEventAddToCart:
            {
                NSNumber* cartCount = [data objectForKey:kRIEventQuantityKey];
                if (VALID_NOTEMPTY(cartCount, NSNumber))
                {
                    [deviceInfo setObject:cartCount forKey:kAd4PushCartStatus];
                }
                NSNumber* cartTotalNumber = [data objectForKey:kRIEventTotalCartKey];
                NSString* cartTotal = [cartTotalNumber stringValue];
                if (VALID_NOTEMPTY(cartTotal, NSString)) {
                    [deviceInfo setObject:cartTotal forKey:kAd4PushCartValue];
                }
                [deviceInfo setObject:currentDate forKey:kAd4PushDateLastCartUpdated];
                
                if (VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kAd4PushLastCategoryAddedToCartName];
                }
                NSString* categoryIdKey = [data objectForKey:kRIEventCategoryIdKey];
                if (VALID_NOTEMPTY(categoryIdKey, NSString)) {
                    [deviceInfo setObject:categoryIdKey forKey:kAd4PushLastCategoryAddedToCartKey];
                }
                
                NSString* productBrandName = [data objectForKey:kRIEventBrandName];
                if (VALID_NOTEMPTY(productBrandName, NSString)) {
                    [deviceInfo setObject:productBrandName forKey:kAd4PushLastBrandAddedToCartName];
                }
                
                NSString* productBrandKey = [data objectForKey:kRIEventBrandKey];
                if (VALID_NOTEMPTY(productBrandKey, NSString)) {
                    [deviceInfo setObject:productBrandKey forKey:kAd4PushLastBrandAddedToCartKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    articleId = [data objectForKey:kRIEventSkuKey];
                    [deviceInfo setObject:articleId forKey:kAd4PushLastCartSKU];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventProductNameKey], NSString))
                {
                    name = [data objectForKey:kRIEventProductNameKey];
                    [deviceInfo setObject:name forKey:kAd4PushLastCartProductName];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryIdKey], NSString))
                {
                    categoryId = [data objectForKey:kRIEventCategoryIdKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSNumber))
                {
                    price = [[data objectForKey:kRIEventPriceKey] stringValue];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCurrencyCodeKey], NSString))
                {
                    currency = [data objectForKey:kRIEventCurrencyCodeKey];
                }
                
                [BMA4STracker updateDeviceInfo:deviceInfo];
                [BMA4STracker trackCartWithId:@"1" forArticleWithId:articleId andLabel:name category:categoryId price:[price doubleValue] currency:currency quantity:1];
            }
                break;
            case RIEventRemoveFromCart:
            {
                NSString* cartCount = [data objectForKey:kRIEventQuantityKey];
                if (VALID_NOTEMPTY(cartCount, NSString))
                {
                    [deviceInfo setObject:cartCount forKey:kAd4PushCartStatus];
                }
                NSNumber* cartTotalNumber = [data objectForKey:kRIEventTotalCartKey];
                NSString* cartTotal = [cartTotalNumber stringValue];
                if (VALID_NOTEMPTY(cartTotal, NSString)) {
                    [deviceInfo setObject:cartTotal forKey:kAd4PushCartValue];
                }
                [deviceInfo setObject:currentDate forKey:kAd4PushDateLastCartUpdated];
            }
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventAddToWishlist:
            {
                if (VALID_NOTEMPTY([data objectForKey:kRIEventTotalWishlistKey], NSNumber)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventTotalWishlistKey] forKey:kAd4PushWishlistStatus];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventProductNameKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventProductNameKey] forKey:kAd4PushLastWishlistProductName];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventBrandName], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventBrandName] forKey:kAd4PushLastBrandAddedToWishlistName];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventBrandKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventBrandKey] forKey:kAd4PushLastBrandAddedToWishlistKey];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kAd4PushLastCategoryAddedToWishlistName];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventCategoryIdKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventCategoryIdKey] forKey:kAd4PushLastCategoryAddedToWishlistKey];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventSkuKey] forKey:kAd4PushLastWishlistSku];
                }
                [BMA4STracker updateDeviceInfo:deviceInfo];
                [BMA4STracker trackEventWithType:1005 parameters:parameters];
            }
                break;
            case RIEventRemoveFromWishlist:
            {
                if (VALID_NOTEMPTY([data objectForKey:kRIEventTotalWishlistKey], NSNumber)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventTotalWishlistKey] forKey:kAd4PushWishlistStatus];
                }
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            }
            case RIEventLoginSuccess:
            case RIEventAutoLoginSuccess:
            case RIEventFacebookLoginSuccess:
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSNumber))
                {
                    NSNumber* userID = [data objectForKey:kRIEventUserIdKey];
                    [parameters addObject:[NSString stringWithFormat:@"loginUserID=%@", [userID stringValue]]];
                    [deviceInfo setObject:[data objectForKey:kRIEventUserIdKey] forKey:kAd4PushProfileUserIdKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserFirstNameKey], NSString))
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventUserFirstNameKey] forKey:kAd4PushProfileFirstNameKey];
                }
                
                if (VALID_NOTEMPTY([data objectForKey:kRIEventUserLastNameKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventUserLastNameKey] forKey:kAd4PushProfileLastNameKey];
                }
                
                if (VALID_NOTEMPTY([data objectForKey:kRIEventGenderKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventGenderKey] forKey:kAd4PushProfileUserGenderKey];
                }
                
                if (VALID_NOTEMPTY([data objectForKey:kRIEventBirthDayKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventBirthDayKey] forKey:kAd4PushProfileBirthDayKey];
                }
                [BMA4STracker trackEventWithType:1001 parameters:parameters];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventUserInfoChanged:
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSNumber))
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventUserIdKey] forKey:kAd4PushProfileUserIdKey];
                }
                
                if (VALID_NOTEMPTY([data objectForKey:kRIEventBirthDayKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventBirthDayKey] forKey:kAd4PushProfileBirthDayKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserFirstNameKey], NSString))
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventUserFirstNameKey] forKey:kAd4PushProfileFirstNameKey];
                }
                
                if (VALID_NOTEMPTY([data objectForKey:kRIEventUserLastNameKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventUserLastNameKey] forKey:kAd4PushProfileLastNameKey];
                }
                
                if (VALID_NOTEMPTY([data objectForKey:kRIEventGenderKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventGenderKey] forKey:kAd4PushProfileUserGenderKey];
                }
                
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventCheckoutEnd:
            {
                NSString* cartCount = [data objectForKey:kRIEventQuantityKey];
                if (VALID_NOTEMPTY(cartCount, NSString))
                {
                    [deviceInfo setObject:cartCount forKey:kAd4PushCartStatus];
                }
                [deviceInfo setObject:currentDate forKey:kAd4PushLastOrderDate];
                
                if (VALID_NOTEMPTY([data objectForKey:kRIEventAggregateNumberOfOrders], NSNumber)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventAggregateNumberOfOrders] forKey:kAd4PushAggregatedNumberOfPurchase];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventOrderNumber], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventOrderNumber] forKey:kAd4PushOrderNumber];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventBrandName], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventBrandName] forKey:kAd4PushLastBrandPurchasedName];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventBrandKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventBrandKey] forKey:kAd4PushLastBrandPurchasedKey];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kAd4PushLastCategoryPurchasedName];
                }
                NSString* categoryIdKey = [data objectForKey:kRIEventCategoryIdKey];
                if (VALID_NOTEMPTY(categoryIdKey, NSString)) {
                    [deviceInfo setObject:categoryIdKey forKey:kAd4PushLastCategoryPurchasedKey];
                }
                NSString* productName = [data objectForKey:kRIEventProductNameKey];
                if (VALID_NOTEMPTY(productName, NSString)) {
                    [deviceInfo setObject:productName forKey:kAd4PushLastProductNamePurchased];
                }
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    articleId = [data objectForKey:kRIEventSkuKey];
                    [deviceInfo setObject:articleId forKey:kAd4PushLastSkuPurchased];
                }
                
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            }
            case RIEventChangeCountry:
                [deviceInfo setObject:[data objectForKey:kRIEventShopCountryKey] forKey:kAd4PushProfileShopCountryKey];
                if ([data objectForKey:kRIEventLanguageCode]) {
                    [deviceInfo setObject:[data objectForKey:kRIEventLanguageCode] forKey:kAd4PushLanguageSelection];
                }
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            default:
                break;
        }
    }
}

#pragma mark - RIEcommerceEventTracking

-(void)trackCheckout:(NSDictionary *)data
{
    RIDebugLog(@"Ad4Push - Tracking checkout with data: %@", data);
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }
    
    NSMutableDictionary *deviceInfo = [[NSMutableDictionary alloc] init];
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [deviceInfo setObject:[dateFormatter stringFromDate:date] forKey:kAd4PushDateLastCartUpdated];
    
    NSNumber *numberOfPurchases = [NSNumber numberWithInt:0];
    if(VALID_NOTEMPTY([data objectForKey:kRIEventAmountTransactions], NSNumber))
    {
        numberOfPurchases = [data objectForKey:kRIEventAmountTransactions];
    }

    if (VALID_NOTEMPTY([data objectForKey:kRIEventAggregateNumberOfOrders], NSNumber)) {
        [deviceInfo setObject:[data objectForKey:kRIEventAggregateNumberOfOrders] forKey:kAd4PushAggregatedNumberOfPurchase];
    }
    [deviceInfo setObject:numberOfPurchases forKey:kAd4PushAggregatedNumberOfPurchase];
    
    NSNumber *total = [data objectForKey:kRIEcommerceTotalValueKey];
    [deviceInfo setObject:total forKey:kAd4PushCartValue];
    
    NSInteger numberOfProducts = 0;
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceSkusKey], NSArray))
    {
        numberOfProducts = [[data objectForKey:kRIEcommerceSkusKey] count];
    }
    [deviceInfo setObject:[NSNumber numberWithInteger:numberOfProducts] forKey:kAd4PushCartStatus];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [BMA4STracker updateDeviceInfo:deviceInfo];
    
    NSString *transactionId = [data objectForKey:kRIEcommerceTransactionIdKey];
    NSString *currency = [data objectForKey:kRIEcommerceCurrencyKey];
    
    [BMA4STracker trackPurchaseWithId:transactionId
                             currency:currency
                           totalPrice:[total doubleValue]];
}

#pragma mark - Private methods for deeplinkg

- (void)handleNotificationWithDictionary:(NSDictionary *)notification
{
    if(VALID_NOTEMPTY(notification, NSDictionary))
    {
        if(VALID_NOTEMPTY([notification objectForKey:@"UTM"], NSString))
        {
            [[RITrackingWrapper sharedInstance] trackCampaignWithName:[notification objectForKey:@"UTM"]];
        }
        
        if(VALID_NOTEMPTY([notification objectForKey:@"u"], NSString))
        {
            NSString *urlString = [notification objectForKey:@"u"];
            NSArray *urlComponents = [urlString componentsSeparatedByString:@"/"];
            
            NSString *key = @"";
            NSString *arguments = @"";
            NSString *filter = @"";
            NSString *parameterKey = @"";
            NSString *parameterValue = @"";
            NSArray *argumentsComponents = [NSArray new];
            
            if(VALID_NOTEMPTY(urlComponents, NSArray) && 1 < [urlComponents count])
            {
                key = [urlComponents objectAtIndex:1];
                if(2 < [urlComponents count] && VALID_NOTEMPTY([urlComponents objectAtIndex:2], NSString))
                {
                    arguments = [urlComponents objectAtIndex:2];
                    argumentsComponents = [arguments componentsSeparatedByString:@"&"];
                    if(VALID_NOTEMPTY(argumentsComponents, NSArray) && 1 < [argumentsComponents count])
                    {
                        arguments = [argumentsComponents objectAtIndex:0];
                        filter = [argumentsComponents objectAtIndex:1];
                        filter = [filter stringByReplacingOccurrencesOfString:@"=" withString:@"/"];
                    }
                }
            }
            
            NSMutableDictionary* categoryDictionary = [NSMutableDictionary new];
            if (VALID_NOTEMPTY(arguments, NSString)) {
                [categoryDictionary setObject:arguments forKey:@"category_url_key"];
            }
            if (VALID_NOTEMPTY(filter, NSString)) {
                [categoryDictionary setObject:filter forKey:@"filter"];
            }
            
            if ([key isEqualToString:@""])
            {
                // Home
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
            }
            else if ([key isEqualToString:@"c"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // Catalog view - category url
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:categoryDictionary];
            }
            else if ([key isEqualToString:@"cbr"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // Catalog view sorted by best rating - category name
                [categoryDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"sorting"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:categoryDictionary];
            }
            else if ([key isEqualToString:@"cp"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // Catalog view sorted by popularity - category name
                [categoryDictionary setObject:[NSNumber numberWithInteger:1] forKey:@"sorting"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:categoryDictionary];
            }
            else if ([key isEqualToString:@"cin"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // Catalog view sorted by new in - category name
                [categoryDictionary setObject:[NSNumber numberWithInteger:2] forKey:@"sorting"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:categoryDictionary];
            }
            else if ([key isEqualToString:@"cpu"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // Catalog view sorted by price up - category name
                [categoryDictionary setObject:[NSNumber numberWithInteger:3] forKey:@"sorting"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:categoryDictionary];
            }
            else if ([key isEqualToString:@"cpd"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // Catalog view sorted by price down - category name
                [categoryDictionary setObject:[NSNumber numberWithInteger:4] forKey:@"sorting"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:categoryDictionary];
            }
            else if ([key isEqualToString:@"cb"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // Catalog view sorted by brand - category name
                [categoryDictionary setObject:[NSNumber numberWithInteger:6] forKey:@"sorting"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:categoryDictionary];
            }
            else if ([key isEqualToString:@"cn"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // Catalog view sorted by name - category name
                [categoryDictionary setObject:[NSNumber numberWithInteger:5] forKey:@"sorting"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:categoryDictionary];
            }
            else if ([key isEqualToString:@"b"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // Catalog view - brand id
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:@{@"targetString":[RITarget getTargetString:CATALOG_BRAND node:arguments]}];
            }
            else if ([key isEqualToString:@"n"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // Catalog view - category id
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:@{@"category_id":arguments}];
            }
            else if ([key isEqualToString:@"s"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // Catalog view - search term
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                    object:@{@"index": @(99),
                                                                             @"name": STRING_SEARCH,
                                                                             @"text": arguments }];
            }
            else if ([key isEqualToString:@"d"] && VALID_NOTEMPTY(arguments, NSString))
            {
                // PDV - jumia://ng/d/BL683ELACCDPNGAMZ?size=1
                if (1 < argumentsComponents.count) {
                    NSString *parameter = [argumentsComponents objectAtIndex:1];
                    if(VALID_NOTEMPTY(parameter, NSString))
                    {
                        NSArray *parameterComponents = [parameter componentsSeparatedByString:@"="];
                        if(VALID_NOTEMPTY(parameterComponents, NSArray) && 1 < [parameterComponents count])
                        {
                            parameterKey = [parameterComponents objectAtIndex:0];
                            parameterValue = [parameterComponents objectAtIndex:1];
                        }
                    }    
                }
                // Check if there is field size
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setObject:arguments forKey:@"sku"];
                [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"show_back_button"];
                
                if(VALID_NOTEMPTY(parameterKey, NSString) && [@"size" isEqualToString:[parameterKey lowercaseString]] && VALID_NOTEMPTY(parameterValue, NSString))
                {
                    [userInfo setObject:parameterValue forKey:@"size"];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
            else if ([key isEqualToString:@"cart"])
            {
                // Cart
                [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCartNotification
                                                                    object:nil];
            }
            else if ([key isEqualToString:@"w"])
            {
                // Wishlist
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowSavedListScreenNotification
                                                                    object:nil];
            }
            else if ([key isEqualToString:@"o"])
            {
                // Order overview
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowMyOrdersScreenNotification
                                                                    object:nil];
            }
            else if ([key isEqualToString:@"l"])
            {
                // Login
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification
                                                                    object:nil];
            }
            else if ([key isEqualToString:@"r"])
            {
                // Register
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignUpScreenNotification
                                                                    object:nil];
            }
            else if ([key isEqualToString:@"rv"])
            {
                // Recently viewed
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowRecentlyViewedScreenNotification
                                                                    object:nil];
            }
            else if ([key isEqualToString:@"rc"])
            {
                // Recent Searches
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowRecentSearchesScreenNotification
                                                                    object:nil];
            }
            else if ([key isEqualToString:@"news"])
            {
                // Email notifications
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowEmailNotificationsScreenNotification
                                                                    object:nil];
            }
            else if ([key isEqualToString:@"camp"] && VALID_NOTEMPTY(arguments, NSString))
            {
                [[JACenterNavigationController sharedInstance] openTarget:[RITarget getTargetString:CAMPAIGN node:arguments]];
            }
            else if ([key isEqualToString:@"ss"])
            {
                if(VALID_NOTEMPTY(urlComponents, NSArray) && 3 == urlComponents.count)
                {
                    NSString* shopID = [urlComponents objectAtIndex:2];
                    if (VALID_NOTEMPTY(shopID, NSString)) {
                        [[JACenterNavigationController sharedInstance] openTarget:[RITarget getTargetString:STATIC_PAGE node:shopID]];
                    }
                }
            }
        }
    }
}

@end
