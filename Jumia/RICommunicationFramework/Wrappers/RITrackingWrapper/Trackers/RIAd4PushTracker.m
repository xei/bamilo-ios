//
//  RIAd4PushTracker.m
//  RITracking
//
//  Created by Miguel Chaves on 20/Mar/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

#import "RIAd4PushTracker.h"
#import <libBMA4SSDK/BMA4SInAppNotification.h>
#import <libBMA4SSDK/BMA4SNotification.h>
#import <libBMA4SSDK/BMA4STracker+Analytics.h>
#import <libBMA4SSDK/BMA4STracker.h>
#import "GAIFields.h"
#import "RIGoogleAnalyticsTracker.h"
#import "RICategory.h"
#import <AdSupport/AdSupport.h>
#import "RIProduct.h"

#define kAd4PushIDFAIdKey                                   @"idfa"
#define kAd4PushProfileShopCountryKey                       @"shopCountry"
#define kAd4PushProfileUserIdKey                            @"userID"
#define kAd4PushProfileRegistrationStatusKey                @"registrationStatus"
#define kAd4PushProfileFirstNameKey                         @"firstName"
#define kAd4PushProfileStatusInAppKey                       @"statusInApp"
#define kAd4PushProfileOrderStatusKey                       @"orderStatus"
#define kAd4PushProfileUserGenderKey                        @"userGender"
#define kAd4PushProfileLastOrderDateKey                     @"lastOrderDate"
#define kAd4PushProfileAggregatedNumberOfPurchasesKey       @"aggregatedNumberOfPurchases"
#define kAd4PushProfileAggregatedValueOfPurchasesKey        @"aggregatedValueOfPurchases"
#define kAd4PushProfileCartStatusKey                        @"cartStatus"
#define kAd4PushProfileCartValueKey                         @"cartValue"
#define kAd4PushProfilePurchaseGrandTotalKey                @"purchaseGrandTotal"
#define kAd4PushProfileLastMovedFromFavtoCartKey            @"lastMovedFromFavtoCart"
#define kAd4PushProfileCouponStatusKey                      @"couponStatus"
#define kAd4PushProfileAvgCartValueKey                      @"avgCartValue"
#define kAd4PushProfileLastSearchKey                        @"lastSearch"
#define kAd4PushProfileLastSearchDateKey                    @"lastSearchDate"
#define kAd4PushProfileLastPurchaseCategoryKey              @"lastPurchaseCategory"
#define kAd4PushProfileLastFavouritesProductKey             @"lastFavouritesProduct"
#define kAd4PushProfileWishlistStatusKey                    @"wishlistStatus"
#define kAd4PushProfileFilterBrandKey                       @"filterBrand"
#define kAd4PushProfileFilterColorKey                       @"filterColor"
#define kAd4PushProfileFilterCategoryKey                    @"filterCategory"
#define kAd4PushProfileFilterPriceKey                       @"filterPrice"
#define kAd4PushProfileFilterSpecialPriceKey                @"special_price"
#define kAd4PushProfileMostVisitedCategoryKey               @"mostVisitedCategory"

#define kAd4PushProfileBirthDayKey                          @"userDOB"




#define kAd4PushProfileLastPNOpenedKey                      @"lastPNOpened"

#define kAd4PushProfileLastViewedCategoryKey                @"lastViewedCategory"
#define kAd4PushProfileMostViewedBrandKey                   @"mostViewedBrand"
#define kAd4PushProfileLastSortedByKey                      @"lastSortedBy"

#define kAd4PushProfileLastNameKey                          @"lastName"

#define kAd4PushProfileLastCampaignVisitedKey               @"lastCampaignVisited"

#define kAd4PushProfileLastProductReviewedKey               @"lastProductReviewed"

#define kAd4PushProfileLastProductSharedKey                 @"lastProductShared"

#define kAd4PushProfileDateLastAddedToCartKey               @"dateLastAddedToCart"
#define kAd4PushProfileLastCartProductNameKey               @"lastCartProductName"
#define kAd4PushProfileLastCartProductSKUKey                @"lastCartProductSKU"
#define kAd4PushProfileLastCategoryAddedToCartKey           @"lastCategoryAddedToCart"
#define kAd4PushProfileAttributeSetIDCartKey                @"attributeSetID"

#define kAd4PushProfilelastPushNotificationOpenedKey        @"lastPNOpened"

#define kAd4PushProfileStoreGAIdKey                         @"gps_adid"


#define kAd4PushProfileStatusProspect                       @"Prospect"
#define kAd4PushProfileStatusCustomer                       @"Customer"
#define kAd4PushProfileStatusStarted                        @"started"
#define kAd4PushProfileStatusDone                           @"done"

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
        
        [events addObject:[NSNumber numberWithInt:RIEventLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventAutoLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventRegisterStart]];
        [events addObject:[NSNumber numberWithInt:RIEventRegisterSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToCart]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutStart]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutEnd]];
        [events addObject:[NSNumber numberWithInt:RIEventSearch]];
        [events addObject:[NSNumber numberWithInt:RIEventChangeCountry]];
        [events addObject:[NSNumber numberWithInt:RIEventFilter]];
        [events addObject:[NSNumber numberWithInt:RIEventSort]];
        [events addObject:[NSNumber numberWithInt:RIEventViewCampaign]];
        [events addObject:[NSNumber numberWithInt:RIEventTopCategory]];
        [events addObject:[NSNumber numberWithInt:RIEventLastViewedCategory]];
        [events addObject:[NSNumber numberWithInt:RIEventAddFromWishlistToCart]];
        [events addObject:[NSNumber numberWithInt:RIEventCart]];
        [events addObject:[NSNumber numberWithInt:RIEventLastAddedToCart]];
        [events addObject:[NSNumber numberWithInt:RIEventShareEmail]];
        [events addObject:[NSNumber numberWithInt:RIEventShareFacebook]];
        [events addObject:[NSNumber numberWithInt:RIEventShareOther]];
        [events addObject:[NSNumber numberWithInt:RIEventShareSMS]];
        [events addObject:[NSNumber numberWithInt:RIEventShareTwitter]];
        [events addObject:[NSNumber numberWithInt:RIEventRateProduct]];
        [events addObject:[NSNumber numberWithInt:RIEventMostViewedBrand]];
        
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
        [deviceInfo setObject:@"0" forKey:kAd4PushProfileUserIdKey];
        NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        [deviceInfo setObject:idfaString ? : @"" forKey:kAd4PushIDFAIdKey];
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
        
        NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kAd4PushProfileStatusInAppKey];
        if(!VALID_NOTEMPTY(userStatus, NSString))
        {
            userStatus = kAd4PushProfileStatusProspect;
            [[NSUserDefaults standardUserDefaults] setObject:userStatus forKey:kAd4PushProfileStatusInAppKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSMutableDictionary *deviceInfo = [[NSMutableDictionary alloc] init];
        NSMutableArray *parameters = [[NSMutableArray alloc] init];
        NSInteger event = [eventType integerValue];
        switch (event) {
            case RIEventLoginSuccess:
            case RIEventAutoLoginSuccess:
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [parameters addObject:[NSString stringWithFormat:@"loginUserID=%@", [data objectForKey:kRIEventUserIdKey]]];
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
                
                [deviceInfo setObject:userStatus forKey:kAd4PushProfileStatusInAppKey];
                
                [BMA4STracker trackEventWithType:1001 parameters:parameters];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventRegisterStart: // Sign Up Started
                [deviceInfo setObject:kAd4PushProfileStatusStarted forKey:kAd4PushProfileRegistrationStatusKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventRegisterSuccess:
                [deviceInfo setObject:userStatus forKey:kAd4PushProfileStatusInAppKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
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
                if(VALID_NOTEMPTY([data objectForKey:kRIEventGenderKey], NSString))
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventGenderKey] forKey:kAd4PushProfileUserGenderKey];
                }
                [deviceInfo setObject:kAd4PushProfileStatusDone forKey:kAd4PushProfileRegistrationStatusKey];
                
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventFacebookLoginSuccess:
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [parameters addObject:[NSString stringWithFormat:@"loginUserID=%@", [data objectForKey:kRIEventUserIdKey]]];
                }
                [BMA4STracker trackEventWithType:1002 parameters:parameters];
                break;
            case RIEventAddToCart:
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    articleId = [data objectForKey:kRIEventSkuKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventProductNameKey], NSString))
                {
                    name = [data objectForKey:kRIEventProductNameKey];
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
                [BMA4STracker trackCartWithId:@"1" forArticleWithId:articleId andLabel:name category:categoryId price:[price doubleValue] currency:currency quantity:1];
                break;
            case RIEventAddToWishlist:
            {
                [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages) {
                    [deviceInfo setObject:[NSNumber numberWithLong:favoriteProducts.count] forKey:kAd4PushProfileWishlistStatusKey];
                    if (VALID_NOTEMPTY([data objectForKey:kRIEventLabelKey], NSString)) {
                        [deviceInfo setObject:[data objectForKey:kRIEventLabelKey] forKey:kAd4PushProfileLastFavouritesProductKey];
                    }
                    [BMA4STracker updateDeviceInfo:deviceInfo];
                    
                    [BMA4STracker trackEventWithType:1005 parameters:parameters];
                } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                    
                }];
                break;
            }
            case RIEventRemoveFromWishlist:
            {
                [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages) {
                    [deviceInfo setObject:[NSNumber numberWithLong:favoriteProducts.count] forKey:kAd4PushProfileWishlistStatusKey];
                    if (VALID_NOTEMPTY([data objectForKey:kRIEventLabelKey], NSString)) {
                        [deviceInfo setObject:[data objectForKey:kRIEventLabelKey] forKey:kAd4PushProfileLastFavouritesProductKey];
                    }
                    [BMA4STracker updateDeviceInfo:deviceInfo];
                } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                    
                }];
                break;
            }
            case RIEventCheckoutStart:
            {
                [deviceInfo setObject:kAd4PushProfileStatusStarted forKey:kAd4PushProfileOrderStatusKey];
                if (VALID_NOTEMPTY([data objectForKey:kRIEventQuantityKey], NSNumber)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventQuantityKey] forKey:kAd4PushProfileCartStatusKey];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventTotalCartKey], NSNumber)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventTotalCartKey] forKey:kAd4PushProfileCartValueKey];
                }
                if (VALID_NOTEMPTY([data objectForKey:kRIEventAttributeSetIDCartKey], NSArray)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventAttributeSetIDCartKey] forKey:kAd4PushProfileAttributeSetIDCartKey];
                }
                
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            }
            case RIEventCheckoutEnd:
            {
                if (VALID_NOTEMPTY([data objectForKey:kRIEventAttributeSetIDCartKey], NSArray)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventAttributeSetIDCartKey] forKey:kAd4PushProfileAttributeSetIDCartKey];
                }
                
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            }
            case RIEventSearch:
                [deviceInfo setObject:currentDate forKey:kAd4PushProfileLastSearchDateKey];
                [deviceInfo setObject:[data objectForKey:kRIEventKeywordsKey] forKey:kAd4PushProfileLastSearchKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventSort:
                [deviceInfo setObject:[data objectForKey:kRIEventSortTypeKey] forKey:kAd4PushProfileLastSortedByKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventChangeCountry:
                [deviceInfo setObject:[data objectForKey:kRIEventShopCountryKey] forKey:kAd4PushProfileShopCountryKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventFilter:
                
                if (VALID_NOTEMPTY([data objectForKey:kRIEventSpecialPriceFilterKey], NSNumber)) {
                    [deviceInfo setObject:[data objectForKey:kRIEventSpecialPriceFilterKey] forKey:kAd4PushProfileFilterSpecialPriceKey];
                }else{
                    [deviceInfo setObject:@0 forKey:kAd4PushProfileFilterSpecialPriceKey];
                }
                if(VALID_NOTEMPTY([data objectForKey:kRIEventBrandFilterKey], NSString))
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventBrandFilterKey] forKey:kAd4PushProfileFilterBrandKey];
                }else{
                    [deviceInfo setObject:@"" forKey:kAd4PushProfileFilterBrandKey];
                }
                if(VALID_NOTEMPTY([data objectForKey:kRIEventColorFilterKey], NSString))
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventColorFilterKey] forKey:kAd4PushProfileFilterColorKey];
                }else{
                    [deviceInfo setObject:@"" forKey:kAd4PushProfileFilterColorKey];
                }
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryFilterKey], NSString))
                {
                    [deviceInfo setObject:kRIEventCategoryFilterKey forKey:kAd4PushProfileFilterCategoryKey];
                }else{
                    [deviceInfo setObject:@"" forKey:kAd4PushProfileFilterCategoryKey];
                }
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceFilterKey], NSString))
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventPriceFilterKey] forKey:kAd4PushProfileFilterPriceKey];
                }else{
                    [deviceInfo setObject:@"" forKey:kAd4PushProfileFilterPriceKey];
                }
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventTopCategory:
                if ([data objectForKey:kRIEventCategoryNameKey]) {
                    [deviceInfo setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kAd4PushProfileMostVisitedCategoryKey];
                }
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventLastViewedCategory:
                if ([data objectForKey:kRIEventLastViewedCategoryKey]) {
                    [deviceInfo setObject:[data objectForKey:kRIEventLastViewedCategoryKey] forKey:kAd4PushProfileLastViewedCategoryKey];
                }
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventViewCampaign:
                [deviceInfo setObject:[data objectForKey:kRIEventCampaignKey] forKey:kAd4PushProfileLastCampaignVisitedKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventAddFromWishlistToCart:
                [deviceInfo setObject:[data objectForKey:kRIEventProductFavToCartKey] forKey:kAd4PushProfileLastMovedFromFavtoCartKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventCart:
                if([data objectForKey:kRIEventTotalCartKey])
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventTotalCartKey] forKey:kAd4PushProfileCartValueKey];
                }
                if([data objectForKey:kRIEventQuantityKey])
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventQuantityKey] forKey:kAd4PushProfileCartStatusKey];
                }
                
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventLastAddedToCart:
                [deviceInfo setObject:currentDate forKey:kAd4PushProfileDateLastAddedToCartKey];
                if([data objectForKey:kRIEventProductNameKey])
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventProductNameKey] forKey:kAd4PushProfileLastCartProductNameKey];
                }
                if([data objectForKey:kRIEventSkuKey])
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventSkuKey] forKey:kAd4PushProfileLastCartProductSKUKey];
                }
                if([data objectForKey:kRIEventLastCategoryAddedToCartKey])
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventLastCategoryAddedToCartKey] forKey:kAd4PushProfileLastCategoryAddedToCartKey];
                }
                
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventShareEmail:
            case RIEventShareFacebook:
            case RIEventShareOther:
            case RIEventShareSMS:
            case RIEventShareTwitter:
                if ([data objectForKey:kRIEventLabelKey])
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventLabelKey] forKey:kAd4PushProfileLastProductSharedKey];
                }
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventRateProduct:
                if ([data objectForKey:kRIEventSkuKey])
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventSkuKey] forKey:kAd4PushProfileLastProductReviewedKey];
                }
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventMostViewedBrand:
                if ([data objectForKey:kRIEventBrandKey])
                {
                    [deviceInfo setObject:[data objectForKey:kRIEventBrandKey] forKey:kAd4PushProfileMostViewedBrandKey];
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
    [deviceInfo setObject:kAd4PushProfileStatusDone forKey:kAd4PushProfileOrderStatusKey];
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [deviceInfo setObject:[dateFormatter stringFromDate:date] forKey:kAd4PushProfileLastOrderDateKey];
    
    NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kAd4PushProfileStatusInAppKey];
    if(!VALID_NOTEMPTY(userStatus, NSString) || ![userStatus isEqualToString:kAd4PushProfileStatusCustomer])
    {
        userStatus = kAd4PushProfileStatusCustomer;
        [[NSUserDefaults standardUserDefaults] setObject:userStatus forKey:kAd4PushProfileStatusInAppKey];
    }
    [deviceInfo setObject:userStatus forKey:kAd4PushProfileStatusInAppKey];
    
    NSNumber *numberOfPurchases = [NSNumber numberWithInt:0];
    if(VALID_NOTEMPTY([data objectForKey:kRIEventAmountTransactions], NSNumber))
    {
        numberOfPurchases = [data objectForKey:kRIEventAmountTransactions];
    }
    NSNumber *totalValueOfPurchases = [NSNumber numberWithFloat:0.f];
    if (VALID_NOTEMPTY([data objectForKey:kRIEventAmountValueTransactions], NSNumber)) {
        totalValueOfPurchases = [data objectForKey:kRIEventAmountValueTransactions];
    }
    [deviceInfo setObject:totalValueOfPurchases forKey:kAd4PushProfileAggregatedValueOfPurchasesKey];
    
    if (VALID_NOTEMPTY([data objectForKey:kRIEventProductFavToCartKey], NSString)) {
        [deviceInfo setObject:[data objectForKey:kRIEventProductFavToCartKey] forKey:kAd4PushProfileLastMovedFromFavtoCartKey];
    }
    
    [deviceInfo setObject:numberOfPurchases forKey:kAd4PushProfileAggregatedNumberOfPurchasesKey];
    
    NSNumber *total = [data objectForKey:kRIEcommerceTotalValueKey];
    [deviceInfo setObject:total forKey:kAd4PushProfileCartValueKey];

    NSNumber *grandTotal = [data objectForKey:kRIEcommerceGrandTotalValueKey];
    [deviceInfo setObject:grandTotal forKey:kAd4PushProfilePurchaseGrandTotalKey];
    
    NSInteger numberOfProducts = 0;
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceSkusKey], NSArray))
    {
        numberOfProducts = [[data objectForKey:kRIEcommerceSkusKey] count];
    }
    [deviceInfo setObject:[NSNumber numberWithInteger:numberOfProducts] forKey:kAd4PushProfileCartStatusKey];   
    
    NSString *couponCode = @"";
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceCouponKey], NSString))
    {
        couponCode = [data objectForKey:kRIEcommerceCouponKey];
    }
    [deviceInfo setValue:couponCode forKey:kAd4PushProfileCouponStatusKey];
    [deviceInfo setObject:[data objectForKey:kRIEcommerceCartAverageValueKey] forKey:kAd4PushProfileAvgCartValueKey];
    
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
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectCampaignNofication
                                                                    object:nil
                                                                  userInfo:@{@"campaign_id":arguments}];
            }
            else if ([key isEqualToString:@"ss"])
            {
                if(VALID_NOTEMPTY(urlComponents, NSArray) && 3 == urlComponents.count)
                {
                    NSString* shopID = [urlComponents objectAtIndex:2];
                    if (VALID_NOTEMPTY(shopID, NSString)) {
                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                        [userInfo setObject:shopID forKey:@"shop_id"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithShopUrlNofication object:nil userInfo:userInfo];
                    }
                }
            }
        }
    }
}

@end
