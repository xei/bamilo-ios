//
//  RIAd4PushTracker.m
//  RITracking
//
//  Created by Miguel Chaves on 20/Mar/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

#import "RIAd4PushTracker.h"
#import <libBMA4SSDK/BMA4SSDK.h>
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

@implementation RIAd4PushTracker

NSString * const kRIAdd4PushUserID = @"kRIAdd4PushUserID";
NSString * const kRIAdd4PushPrivateKey = @"kRIAdd4PushPrivateKey";
NSString * const kRIAdd4PushDeviceToken = @"kRIAdd4PushDeviceToken";

@synthesize queue;
@synthesize registeredEvents;

static RIAd4PushTracker *sharedInstance;

- (id)init
{
    NSLog(@"Initializing Ad4Push tracker");
    
    if ((self = [super init])) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        
        NSMutableArray *events = [[NSMutableArray alloc] init];
        
        [events addObject:[NSNumber numberWithInt:RIEventLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventRegisterSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToCart]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToWishlist]];
        
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
    
    [self handleNotificationWithDictionary:userInfo];
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

#pragma mark - RILaunchEventTracker implementation

- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary;
{
    RIDebugLog(@"Ad4Push - Launch event with data:%@", dataDictionary);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    //    [BMA4STracker trackEventWithType:1003 parameters:array];
}

#pragma mark - RIEventTracking
- (void)trackEvent:(NSNumber *)eventType data:(NSDictionary *)data
{
    RIDebugLog(@"Ad4Push - Tracking event = %@, data %@", eventType, data);
    if([self.registeredEvents containsObject:eventType])
    {
        NSInteger event = [eventType integerValue];
        switch (event) {
            case RIEventLoginSuccess:
//                [BMA4STracker trackEventWithType:1001 parameters:array];

                break;
            case RIEventRegisterSuccess:
//                [BMA4STracker trackLeadWithLabel:<#(NSString *)#> value:<#(NSString *)#>]
                break;
            case RIEventFacebookLoginSuccess:
//                [BMA4STracker trackEventWithType:1002 parameters:array];
                break;
            case RIEventAddToCart:
//                    [BMA4STracker trackCartWithId:<#(NSString *)#> forArticleWithId:<#(NSString *)#> andLabel:<#(NSString *)#> category:<#(NSString *)#> price:<#(double)#> currency:<#(NSString *)#> quantity:<#(long)#>]
                break;
            case RIEventAddToWishlist:
//                [BMA4STracker trackEventWithType:1005 parameters:array];
                break;
            default:
//                [BMA4STracker trackEventWithType:1001 parameters:array];
                break;
        }
        
//        NSDictionary *parameters = [self createParameters:data];
//        [[BMA4SNotification sharedBMA4S] synchroniseProfile:parameters];
        
//        NSArray* array = [NSArray arrayWithObject:@"ApplicationStart=successful;userId=000"];
//        [BMA4STracker trackEventWithType:1001 parameters:array];
    }
}

- (NSDictionary*)createParameters:(NSDictionary*)data
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    return [parameters copy];
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
    
    NSString *transactionId = [data objectForKey:kRIEcommerceTransactionIdKey];
    NSString *currency = [data objectForKey:kRIEcommerceTransactionIdKey];
    NSNumber *total = [data objectForKey:kRIEcommerceTotalValueKey];
    
    [BMA4STracker trackPurchaseWithId:transactionId
                             currency:currency
                           totalPrice:[total doubleValue]];
}

#pragma mark - Private methods for deeplinkg

- (void)handleNotificationWithDictionary:(NSDictionary *)notification
{
    if (notification != nil && [notification objectForKey:@"UTM"] != nil && [[notification objectForKey:@"UTM"] length] > 0)
    {
        NSString *campaignName = [NSString stringWithFormat:@"%@",[notification objectForKey:@"UTM"]];
        
        NSDictionary *campaignData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"push", kGAICampaignSource,
                                      @"referrer",kGAICampaignMedium,
                                      campaignName, kGAICampaignName,
                                      @"ad_variation1",kGAICampaignContent,
                                      @"keyword",kGAICampaignKeyword,
                                      @"1",kGAICampaignId, nil];
        
        [[RITrackingWrapper sharedInstance] trackCampaingWithData:campaignData];
    }
    
    if (notification != nil && [notification objectForKey:@"u"] != nil)
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
                    NSString *finalUrl = [NSString stringWithFormat:@"%@%@catalog.html?sku=%@", [RIApi getCountryUrlInUse], RI_API_VERSION, pdvSku];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                                        object:nil
                                                                      userInfo:@{ @"url" : finalUrl,
                                                                                  @"size": size,
                                                                                  @"show_back_button" : [NSNumber numberWithBool:NO]}];
                }
                else
                {
                    NSString *pdvSku = [urlString substringWithRange:NSMakeRange(5, urlString.length - 5)];
                    NSString *finalUrl = [NSString stringWithFormat:@"%@%@catalog.html?sku=%@", [RIApi getCountryUrlInUse], RI_API_VERSION, pdvSku];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                                        object:nil
                                                                      userInfo:@{ @"url" : finalUrl ,
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
                [self pushLoginViewController];
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
        
        if (url.query != nil) {
            if ([url.query length] >= 5) {
                if (![[url.query substringToIndex:4] isEqualToString:@"ADXID"]) {
                    NSRange range = [url.query rangeOfString:@"?ADXID"];
                    if (range.location != NSNotFound) {
                        NSString *paramsWithoutAdXData = [url.query substringToIndex:range.location];
                        urlQuery = [NSString stringWithFormat:@"?%@",paramsWithoutAdXData];
                        path = [url.path stringByAppendingString:urlQuery];
                    } else {
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
    if (categoryId.length > 0)
    {
        [RICategory getCategoriesWithSuccessBlock:^(id categories) {
            
            for (RICategory *category in categories)
            {
                if ([category.uid isEqualToString:categoryId])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification
                                                                        object:@{@"category":category}];
                    
                    break;
                }
            }
        } andFailureBlock:^(NSArray *errorMessage) {
            [self pushHomeViewController];
        }];
    }
    else if (categoryName.length > 0)
    {
        [RICategory getCategoriesWithSuccessBlock:^(id categories) {
            
            for (RICategory *category in categories)
            {
                if ([category.urlKey isEqualToString:categoryName])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification
                                                                        object:@{@"category":category}];
                    
                    break;
                }
            }
        } andFailureBlock:^(NSArray *errorMessage) {
            [self pushHomeViewController];
        }];
    }
    else if (searchTerm.length > 0)
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(90),
                                                                 @"name": STRING_TRACK_MY_ORDER }];
}

- (void)pushLoginViewController
{
    // The index 90 is to know it's from deeplink
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(90),
                                                                 @"name": STRING_LOGIN }];
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
