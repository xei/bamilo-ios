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

#define kAd4PushProfileShopCountryKey                       @"shopCountry"
#define kAd4PushProfileUserIdKey                            @"userID"
#define kAd4PushProfileRegistrationStatusKey                @"registrationStatus"
#define kAd4PushProfileFirstNameKey                         @"firstName"
#define kAd4PushProfileStatusInAppKey                       @"statusInApp"
#define kAd4PushProfileOrderStatusKey                       @"orderStatus"
#define kAd4PushProfileUserGenderKey                        @"userGender"
#define kAd4PushProfileLastOrderDateKey                     @"lastOrderDate"
#define kAd4PushProfileAggregatedNumberOfPurchaseKey        @"aggregatedNumberOfPurchase"
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
#define kAd4PushProfileLastFavouritesProductDateKey         @"lastFavouritesProductDate"
#define kAd4PushProfileFilterBrandKey                       @"filterBrand"
#define kAd4PushProfileFilterColorKey                       @"filterColor"
#define kAd4PushProfileFilterCategoryKey                    @"filterCategory"
#define kAd4PushProfileFilterPriceKey                       @"filterPrice"
#define kAd4PushProfileCampaignPageViewCountKey             @"campaignPageViewCount"
#define kAd4PushProfileMostVisitedCategoryKey               @"mostVisitedCategory"

#define kAd4PushProfileStatusProspect   @"Prospect"
#define kAd4PushProfileStatusCustomer   @"Customer"
#define kAd4PushProfileStatusStarted    @"started"
#define kAd4PushProfileStatusDone       @"done"

@implementation RIAd4PushTracker

NSString * const kRIAdd4PushUserID = @"kRIAdd4PushUserID";
NSString * const kRIAdd4PushPrivateKey = @"kRIAdd4PushPrivateKey";
NSString * const kRIAdd4PushDeviceToken = @"kRIAdd4PushDeviceToken";

@synthesize queue;
@synthesize registeredEvents;

- (id)init
{
    NSLog(@"Initializing Ad4Push tracker");
    
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
        [events addObject:[NSNumber numberWithInt:RIEventSearch]];
        [events addObject:[NSNumber numberWithInt:RIEventChangeCountry]];
        [events addObject:[NSNumber numberWithInt:RIEventFilter]];
        [events addObject:[NSNumber numberWithInt:RIEventViewCampaign]];
        [events addObject:[NSNumber numberWithInt:RIEventTopCategory]];
        [events addObject:[NSNumber numberWithInt:RIEventAddFromWishlistToCart]];

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
    
    [BMA4STracker setDebugMode:YES];
    
    [BMA4STracker trackWithPartnerId:userId
                          privateKey:privateKey
                             options:options];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       [[BMA4SNotification sharedBMA4S] didFinishLaunchingWithOptions:options]; 
    });
    
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObject:@"0" forKey:kAd4PushProfileUserIdKey];
    [BMA4STracker updateDeviceInfo:deviceInfo];
}

#pragma mark - RINotificationTracking protocol

- (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{    
    RIDebugLog(@"Ad4Push - Registering for remote notifications.");
    
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
    
    [[BMA4SNotification sharedBMA4S] didReceiveRemoteNotification:userInfo];
}

- (void)applicationDidReceiveLocalNotification:(UILocalNotification *)notification
{
    RIDebugLog(@"Ad4Push - Received local notification: %@", notification);
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }
    
    [[BMA4SNotification sharedBMA4S] didReceiveLocalNotification:notification];
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
    
    [self handlePushNotificationWithOpenURL:url];
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
        NSNumber *numberOfProductsInWishlist = nil;
        NSInteger numberOfProductsInWishlistValue = 0;
        NSNumber *campaignNumber = nil;
        NSInteger campaignNumberValue = 0;
        NSNumber *colorFilter = nil;
        NSInteger colorFilterValue = 0;
        NSNumber *priceFilter = nil;
        NSInteger priceFilterValue = 0;
        NSNumber *brandFilter = nil;
        NSInteger brandFilterValue = 0;
        NSNumber *categoryFilter = nil;
        NSInteger categoryFilterValue = 0;
        
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
                
                [deviceInfo setObject:userStatus forKey:kAd4PushProfileStatusInAppKey];
                
                [BMA4STracker trackEventWithType:1001 parameters:parameters];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventRegisterStart:
                [deviceInfo setObject:kAd4PushProfileStatusStarted forKey:kAd4PushProfileRegistrationStatusKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventRegisterSuccess:
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [BMA4STracker trackLeadWithLabel:@"customerID" value:[data objectForKey:kRIEventUserIdKey]];
                    [deviceInfo setObject:[data objectForKey:kRIEventUserIdKey] forKey:kAd4PushProfileUserIdKey];
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
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    price = [data objectForKey:kRIEventPriceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCurrencyCodeKey], NSString))
                {
                    currency = [data objectForKey:kRIEventCurrencyCodeKey];
                }
                [BMA4STracker trackCartWithId:@"1" forArticleWithId:articleId andLabel:name category:categoryId price:[price doubleValue] currency:currency quantity:1];
                break;
            case RIEventAddToWishlist:
                numberOfProductsInWishlist = [[NSUserDefaults standardUserDefaults] objectForKey:kAd4PushProfileWishlistStatusKey];
                if(VALID_NOTEMPTY(numberOfProductsInWishlist, NSNumber))
                {
                    numberOfProductsInWishlistValue = [numberOfProductsInWishlist integerValue];
                }
                numberOfProductsInWishlistValue++;
                numberOfProductsInWishlist = [NSNumber numberWithInt:numberOfProductsInWishlistValue];
                [[NSUserDefaults standardUserDefaults] setObject:numberOfProductsInWishlist forKey:kAd4PushProfileWishlistStatusKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [deviceInfo setObject:numberOfProductsInWishlist forKey:kAd4PushProfileWishlistStatusKey];
                [deviceInfo setObject:currentDate forKey:kAd4PushProfileLastFavouritesProductKey];
                [deviceInfo setObject:[data objectForKey:kRIEventSkuKey] forKey:kAd4PushProfileLastFavouritesProductDateKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                
                [BMA4STracker trackEventWithType:1005 parameters:parameters];
                break;
            case RIEventRemoveFromWishlist:
                numberOfProductsInWishlist = [[NSUserDefaults standardUserDefaults] objectForKey:kAd4PushProfileWishlistStatusKey];
                if(VALID_NOTEMPTY(numberOfProductsInWishlist, NSNumber))
                {
                    numberOfProductsInWishlistValue = [numberOfProductsInWishlist integerValue];
                }
                numberOfProductsInWishlistValue--;
                numberOfProductsInWishlist = [NSNumber numberWithInt:numberOfProductsInWishlistValue];
                [[NSUserDefaults standardUserDefaults] setObject:numberOfProductsInWishlist forKey:kAd4PushProfileWishlistStatusKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [deviceInfo setObject:numberOfProductsInWishlist forKey:kAd4PushProfileWishlistStatusKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventCheckoutStart:
                [deviceInfo setObject:kAd4PushProfileStatusStarted forKey:kAd4PushProfileOrderStatusKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventSearch:
                [deviceInfo setObject:currentDate forKey:kAd4PushProfileLastSearchDateKey];
                [deviceInfo setObject:[data objectForKey:kRIEventKeywordsKey] forKey:kAd4PushProfileLastSearchKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventChangeCountry:
                [deviceInfo setObject:[data objectForKey:kRIEventShopCountryKey] forKey:kAd4PushProfileShopCountryKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventFilter:
                if(VALID_NOTEMPTY([data objectForKey:kRIEventBrandFilterKey], NSString))
                {
                    brandFilter = [[NSUserDefaults standardUserDefaults] objectForKey:kAd4PushProfileFilterBrandKey];
                    if(VALID_NOTEMPTY(brandFilter, NSNumber))
                    {
                        brandFilterValue = [brandFilter integerValue];
                    }
                    brandFilterValue++;
                    brandFilter = [NSNumber numberWithInt:brandFilterValue];
                    [[NSUserDefaults standardUserDefaults] setObject:brandFilter forKey:kAd4PushProfileFilterBrandKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [deviceInfo setObject:brandFilter forKey:kAd4PushProfileFilterBrandKey];
                }
                if(VALID_NOTEMPTY([data objectForKey:kRIEventColorFilterKey], NSString))
                {
                    colorFilter = [[NSUserDefaults standardUserDefaults] objectForKey:kAd4PushProfileFilterColorKey];
                    if(VALID_NOTEMPTY(colorFilter, NSNumber))
                    {
                        colorFilterValue = [colorFilter integerValue];
                    }
                    colorFilterValue++;
                    colorFilter = [NSNumber numberWithInt:colorFilterValue];
                    [[NSUserDefaults standardUserDefaults] setObject:colorFilter forKey:kAd4PushProfileFilterColorKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [deviceInfo setObject:colorFilter forKey:kAd4PushProfileFilterColorKey];
                }
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryFilterKey], NSString))
                {
                    categoryFilter = [[NSUserDefaults standardUserDefaults] objectForKey:kAd4PushProfileFilterCategoryKey];
                    if(VALID_NOTEMPTY(categoryFilter, NSNumber))
                    {
                        categoryFilterValue = [categoryFilter integerValue];
                    }
                    categoryFilterValue++;
                    categoryFilter = [NSNumber numberWithInt:categoryFilterValue];
                    [[NSUserDefaults standardUserDefaults] setObject:categoryFilter forKey:kAd4PushProfileFilterCategoryKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [deviceInfo setObject:categoryFilter forKey:kAd4PushProfileFilterCategoryKey];
                }
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceFilterKey], NSString))
                {
                    priceFilter = [[NSUserDefaults standardUserDefaults] objectForKey:kAd4PushProfileFilterPriceKey];
                    if(VALID_NOTEMPTY(priceFilter, NSNumber))
                    {
                        priceFilterValue = [priceFilter integerValue];
                    }
                    priceFilterValue++;
                    priceFilter = [NSNumber numberWithInt:priceFilterValue];
                    [[NSUserDefaults standardUserDefaults] setObject:priceFilter forKey:kAd4PushProfileFilterPriceKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [deviceInfo setObject:priceFilter forKey:kAd4PushProfileFilterPriceKey];
                }
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventTopCategory:
                [deviceInfo setObject:[data objectForKey:kRIEventTopCategoryKey] forKey:kAd4PushProfileMostVisitedCategoryKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventViewCampaign:
                campaignNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kAd4PushProfileCampaignPageViewCountKey];
                if(VALID_NOTEMPTY(campaignNumber, NSNumber))
                {
                    campaignNumberValue = [campaignNumber integerValue];
                }
                campaignNumberValue++;
                campaignNumber = [NSNumber numberWithInt:campaignNumberValue];
                [[NSUserDefaults standardUserDefaults] setObject:campaignNumber forKey:kAd4PushProfileCampaignPageViewCountKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [deviceInfo setObject:campaignNumber forKey:kAd4PushProfileCampaignPageViewCountKey];
                [BMA4STracker updateDeviceInfo:deviceInfo];
                break;
            case RIEventAddFromWishlistToCart:
                [deviceInfo setObject:[data objectForKey:kRIEventNumberOfProductsKey] forKey:kAd4PushProfileLastMovedFromFavtoCartKey];
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
    [deviceInfo setObject:numberOfPurchases forKey:kAd4PushProfileAggregatedNumberOfPurchaseKey];
    
    NSNumber *total = [data objectForKey:kRIEcommerceTotalValueKey];
    [deviceInfo setObject:total forKey:kAd4PushProfileCartValueKey];

    CGFloat grandTotalValue = 0.0f;
    NSNumber *grandTotal = [[NSUserDefaults standardUserDefaults] objectForKey:kAd4PushProfilePurchaseGrandTotalKey];
    if(VALID_NOTEMPTY(grandTotal, NSNumber))
    {
        grandTotalValue = [grandTotal floatValue];
    }
    grandTotalValue += [total floatValue];
    grandTotal = [NSNumber numberWithFloat:grandTotalValue];
    [[NSUserDefaults standardUserDefaults] setObject:grandTotal forKey:kAd4PushProfilePurchaseGrandTotalKey];
    [deviceInfo setObject:grandTotal forKey:kAd4PushProfilePurchaseGrandTotalKey];
    
    NSInteger numberOfProducts = 0;
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceSkusKey], NSArray))
    {
        numberOfProducts = [[data objectForKey:kRIEcommerceSkusKey] count];
    }
    [deviceInfo setObject:[NSNumber numberWithInt:numberOfProducts] forKey:kAd4PushProfileCartStatusKey];
    
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
    NSString *currency = [data objectForKey:kRIEcommerceTransactionIdKey];
    
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
            
            
            NSString *forthLetter = @"";
            NSString *cartPositionString = @"";
            
            if ([urlString length] >= 7)
            {
                cartPositionString = [urlString substringWithRange:NSMakeRange(3, 4)];
            }
            
            if ([cartPositionString isEqualToString:@"cart"])
            {
                [self pushCartViewController];
            }
            else
            {
                if ([urlString length] >= 4)
                {
                    forthLetter = [urlString substringWithRange:NSMakeRange(3, 1)];
                }
                
                if ([forthLetter isEqualToString:@""])
                {
                    // Home
                    [self pushHomeViewController];
                }
                else if ([forthLetter isEqualToString:@"c"])
                {
                    // Catalog view - category name
                    NSString *categoryName = [urlString substringWithRange:NSMakeRange(5, urlString.length - 5)];
                    
                    [self pushCatalogViewControllerWithCategoryId:nil
                                                     categoryName:categoryName
                                                       searchTerm:nil];
                }
                else if ([forthLetter isEqualToString:@"n"])
                {
                    // Catalog view - category id
                    NSString *categoryId = [urlString substringWithRange:NSMakeRange(5, urlString.length - 5)];
                    
                    [self pushCatalogViewControllerWithCategoryId:categoryId
                                                     categoryName:nil
                                                       searchTerm:nil];
                }
                else if ([forthLetter isEqualToString:@"s"])
                {
                    // Catalog view - search term
                    NSString *searchTerm = [urlString substringWithRange:NSMakeRange(5, urlString.length - 5)];
                    
                    [self pushCatalogViewControllerWithCategoryId:nil
                                                     categoryName:nil
                                                       searchTerm:searchTerm];
                }
                else if ([forthLetter isEqualToString:@"d"])
                {
                    // PDV
                    // Example: jumia://ng/d/BL683ELACCDPNGAMZ?size=1
                    
                    // Check if there is field size
                    
                    NSRange range = [[urlString lowercaseString] rangeOfString:@"?size="];
                    if(NSNotFound != range.location)
                    {
                        NSString *size = [urlString substringWithRange:NSMakeRange(range.length + range.location, urlString.length - (range.length + range.location))];
                        
                        NSString *pdvSku = [urlString substringWithRange:NSMakeRange(5, range.location - 5)];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                                            object:nil
                                                                          userInfo:@{ @"sku" : pdvSku,
                                                                                      @"size": size,
                                                                                      @"show_back_button" : [NSNumber numberWithBool:NO]}];
                    }
                    else
                    {
                        NSString *pdvSku = [urlString substringWithRange:NSMakeRange(5, urlString.length - 5)];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                                            object:nil
                                                                          userInfo:@{ @"sku" : pdvSku ,
                                                                                      @"show_back_button" : [NSNumber numberWithBool:NO]}];
                    }
                }
                else if ([forthLetter isEqualToString:@"cart"])
                {
                    // Cart
                    [self pushCartViewController];
                }
                else if ([forthLetter isEqualToString:@"w"])
                {
                    // Wishlist
                    [self pushWishList];
                }
                else if ([forthLetter isEqualToString:@"o"])
                {
                    // Order overview
                    [self pushOrderOverView];
                }
                else if ([forthLetter isEqualToString:@"l"])
                {
                    // Login
                    [self pushLoginViewController];
                }
                else if ([forthLetter isEqualToString:@"r"])
                {
                    // Register
                    [self pushRegisterViewController];
                }
            }
        }
    }
}

- (void)handlePushNotificationWithOpenURL:(NSURL *)url
{
    NSString *urlScheme = [url scheme];
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *faceAppId = [infoDict objectForKey:@"FacebookAppID"];
    NSString *facebookSchema = @"";
    
    if (faceAppId.length > 0)
    {
        facebookSchema = [NSString stringWithFormat:@"fb%@", faceAppId];
    }
    
    if ((urlScheme != nil && [urlScheme isEqualToString:@"jumia"]) || (urlScheme != nil && [facebookSchema isEqualToString:urlScheme]))
    {
        if ([facebookSchema isEqualToString:urlScheme])
        {
            [self pushHomeViewController];
            
            return;
        }
        
        NSString *path = [NSString stringWithString:url.path];
        NSString *urlHost = [NSString stringWithString:url.host];
        NSString *urlQuery = nil;
        
        if (url.query != nil)
        {
            if ([url.query length] >= 5)
            {
                if (![[url.query substringToIndex:4] isEqualToString:@"ADXID"])
                {
                    NSRange range = [url.query rangeOfString:@"?ADXID"];
                    if (range.location != NSNotFound)
                    {
                        NSString *paramsWithoutAdXData = [url.query substringToIndex:range.location];
                        urlQuery = [NSString stringWithFormat:@"?%@",paramsWithoutAdXData];
                        path = [url.path stringByAppendingString:urlQuery];
                    } else
                    {
                        urlQuery = [NSString stringWithFormat:@"?%@",url.query];
                        path = [url.path stringByAppendingString:urlQuery];
                    }
                }
            }
        }
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        if (![urlHost isEqualToString:bundleIdentifier])
        {
            path = [urlHost stringByAppendingString:path];
        }
        else
        {
            path = [path substringFromIndex:1];
        }
        
        NSDictionary *dict = [self parseQueryString:[url query]];
        
        NSMutableDictionary *urlDictionary = [NSMutableDictionary dictionaryWithObject:path forKey:@"u"];
        
        NSString *temp = [dict objectForKey:@"UTM"];
        
        if (temp)
        {
            [urlDictionary addEntriesFromDictionary:dict];
        }
        
        [self handleNotificationWithDictionary:urlDictionary];
    }
}

#pragma mark - Push view controllers

- (void)pushHomeViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(0),
                                                                 @"name": STRING_HOME }];
}

- (void)pushCatalogViewControllerWithCategoryId:(NSString *)categoryId
                                   categoryName:(NSString *)categoryName
                                     searchTerm:(NSString *)searchTerm
{
    if(VALID_NOTEMPTY(categoryId, NSString))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:@{@"category_id":categoryId}];
    }
    else if(VALID_NOTEMPTY(categoryName, NSString))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:@{@"category_name":categoryName}];
    }
    else if(VALID_NOTEMPTY(searchTerm, NSString))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                            object:@{@"index": @(99),
                                                                     @"name": STRING_SEARCH,
                                                                     @"text": searchTerm }];
    }
}

- (void)pushCartViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCartNotification
                                                        object:nil];
}

- (void)pushWishList
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(90),
                                                                 @"name": STRING_MY_FAVOURITES }];
}

- (void)pushOrderOverView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowTrackOrderScreenNotification
                                                        object:nil];
}

- (void)pushLoginViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification
                                                        object:nil];
}

- (void)pushRegisterViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignUpScreenNotification
                                                        object:nil];
}

#pragma mark - Auxiliar methods

- (NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:16];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        
        NSString *key = [elements[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [elements[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    
    return dict;
}

@end
