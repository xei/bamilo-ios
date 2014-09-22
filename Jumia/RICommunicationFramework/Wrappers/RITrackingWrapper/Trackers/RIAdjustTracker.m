
//
//  RIAdjustTracker.m
//  Jumia
//
//  Created by Pedro Lopes on 18/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIAdjustTracker.h"

#define kAdjustEventDurationDataKey     @"duration"
#define kAdjustEventAppVersionDataKey   @"app_version"
#define kAdjustEventDeviceModelDataKey  @"device_type"
#define kAdjustEventShopCountryKey      @"shop_country"
#define kAdjustEventUserIdKey           @"user_id"
#define kAdjustEventSkuKey              @"sku"
#define kAdjustEventCurrencyCodeKey     @"currency_code"
#define kAdjustEventPriceKey            @"price"
#define kAdjustEventSkusKey             @"skus"
#define kAdjustEventTransactionIdKey    @"transaction_id"
#define kAdjustEventGenderKey           @"gender"
#define kAdjustAmountTransactionsKey    @"amount_transactions"
#define kAdjustAmountSessionsKey        @"amount_sessions"
#define kAdjustEventCategoryNameKey     @"category"
#define kAdjustEventCategoryIdKey       @"category_id"
#define kAdjustEventTreeKey             @"tree"
#define kAdjustEventQueryKey            @"query"
#define kAdjustEventProductKey          @"product"
#define kAdjustEventProductsKey         @"products"
#define kAdjustEventKeywordsKey         @"keywords"
#define kAdjustEventNewCustomerKey      @"new_customer"
#define kAdjustEventDiscountKey         @"discount"
#define kAdjustEventBrandKey            @"brand"
#define kAdjustEventSizeKey             @"size"
#define kAdjustEventTotalWishlistKey    @"total_wishlist"
#define kAdjustEventQuantityKey         @"quantity"
#define kAdjustEventTotalCartKey        @"total_cart"

NSString * const kRIAdjustToken = @"kRIAdjustToken";

@implementation RIAdjustTracker

@synthesize queue;
@synthesize registeredEvents;

- (id)init
{
    RIDebugLog(@"Initializing Adjust tracker");
    
    if ((self = [super init])) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        
        NSMutableArray *events = [[NSMutableArray alloc] init];
        [events addObject:[NSNumber numberWithInt:RIEventLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventRegisterSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventLogout]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToCart]];
        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromCart]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventRateProduct]];
        [events addObject:[NSNumber numberWithInt:RIEventShareFacebook]];
        [events addObject:[NSNumber numberWithInt:RIEventShareTwitter]];
        [events addObject:[NSNumber numberWithInt:RIEventShareEmail]];
        [events addObject:[NSNumber numberWithInt:RIEventShareSMS]];
        [events addObject:[NSNumber numberWithInt:RIEventShareOther]];
        [events addObject:[NSNumber numberWithInt:RIEventCallToOrder]];
        [events addObject:[NSNumber numberWithInt:RIEventGuestCustomer]];
        [events addObject:[NSNumber numberWithInt:RIEventSearch]];
        [events addObject:[NSNumber numberWithInt:RIEventViewProduct]];
        [events addObject:[NSNumber numberWithInt:RIEventViewListing]];
        [events addObject:[NSNumber numberWithInt:RIEventViewCart]];
        [events addObject:[NSNumber numberWithInt:RIEventTransactionConfirm]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookHome]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookViewListing]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookViewProduct]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookSearch]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookViewWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookViewCart]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookViewTransaction]];
        
        self.registeredEvents = [events copy];
    }
    return self;
}

#pragma mark - RITracker protocol

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options
{
    RIDebugLog(@"Adjust tracker tracks application launch");
    
    NSString *apiKey = [RITrackingConfiguration valueForKey:kRIAdjustToken];
    
    if (!apiKey) {
        RIRaiseError(@"Missing Adjust API key in tracking properties")
        return;
    }

    [Adjust appDidLaunch:apiKey];
    [Adjust setLogLevel:AILogLevelInfo];
    
#if defined(DEBUG) && DEBUG
    [Adjust setEnvironment:AIEnvironmentSandbox];
    NSLog(@"Adjust setEnvironment as AIEnvironmentSandbox");
#else
    [Adjust setEnvironment:AIEnvironmentProduction];
    NSLog(@"Adjust setEnvironment as AIEnvironmentProduction");
#endif
    
    [Adjust setDelegate:self];
}

#pragma mark RIEventTracking protocol

- (void)trackEvent:(NSNumber *)eventType data:(NSDictionary *)data
{
    NSLog(@"Adjust - Tracking event = %@, data %@", eventType, data);
    if([self.registeredEvents containsObject:eventType])
    {
        NSDictionary *parameters = [self createParameters:data];
        
        NSString *eventKey = @"";
        NSInteger eventTypeInt = [eventType integerValue];
        switch (eventTypeInt) {
            case RIEventLoginSuccess:
                eventKey = @"1uv3mg";
                break;
            case RIEventLogout:
                eventKey = @"qdcwli";
                break;
            case RIEventRegisterSuccess:
                eventKey = @"mkq863";
                break;
            case RIEventAddToCart:
                eventKey = @"c5vseo";
                break;
            case RIEventRemoveFromCart:
                eventKey = @"ew5nzy";
                break;
            case RIEventAddToWishlist:
                eventKey = @"g6en5v";
                break;
            case RIEventRemoveFromWishlist:
                eventKey = @"v878b6";
                break;
            case RIEventFacebookLoginSuccess:
                eventKey = @"u98xtu";
            case RIEventShareFacebook:
                eventKey = @"kj8g12";
                break;
            case RIEventShareTwitter:
                eventKey = @"pzlwy3";
                break;
            case RIEventShareEmail:
                eventKey = @"i83rho";
                break;
            case RIEventShareSMS:
                eventKey = @"lxq8jt";
                break;
            case RIEventCallToOrder:
                eventKey = @"eaaq0p";
                break;
            case RIEventRateProduct:
                eventKey = @"b0mavy";
                break;
            case RIEventGuestCustomer:
                eventKey = @"z9v5ec";
                break;
            case RIEventSearch:
                eventKey = @"469opz";
                break;
            case RIEventViewProduct:
                eventKey = @"b499d1";
                break;
            case RIEventViewListing:
                eventKey = @"rce3dz";
                break;
                // TODO: Missing implementation - re targting
            case RIEventViewCart:
                eventKey = @"3lv2b5";
                break;
            case RIEventTransactionConfirm:
                eventKey = @"mtzu4i";
                break;
            // TODO: End implementation - re targting
            case RIEventFacebookHome:
                eventKey = @"xgdla8";
                break;
            case RIEventFacebookViewListing:
                eventKey = @"hdcfgj";
                break;
            case RIEventFacebookViewProduct:
                eventKey = @"e91496";
                break;
            case RIEventFacebookSearch:
                eventKey = @"g240ad";
                break;
            case RIEventFacebookViewWishlist:
                eventKey = @"sshinc";
                break;
            case RIEventFacebookViewCart:
                eventKey = @"adojsu";
                break;
                // TODO: Missing implementation - facebook audiences
            case RIEventFacebookViewTransaction:
                eventKey = @"29kvfe";
            // TODO: End implementation - facebook audiences
                break;
            default:
                break;
        }
        
        [Adjust trackEvent:eventKey withParameters:parameters];
    }
}

- (NSDictionary*)createParameters:(NSDictionary*)data
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[data objectForKey:kRILaunchEventAppVersionDataKey] forKey:kAdjustEventAppVersionDataKey];
    [parameters setObject:[data objectForKey:kRILaunchEventDeviceModelDataKey] forKey:kAdjustEventDeviceModelDataKey];
    [parameters setObject:[data objectForKey:kRIEventShopCountryKey] forKey:kAdjustEventShopCountryKey];
    
    NSString *userId = [data objectForKey:kRIEventUserIdKey];
    if(VALID_NOTEMPTY(userId, NSString) && ![@"0" isEqualToString:userId])
    {
        [parameters setObject:[data objectForKey:kRIEventUserIdKey]  forKey:kAdjustEventUserIdKey];
    }
    
    NSString *sku = [data objectForKey:kRIEventSkuKey];
    if(VALID_NOTEMPTY(sku, NSString))
    {
        [parameters setObject:sku forKey:kAdjustEventSkuKey];
    }
    
    NSString *currencyCode = [data objectForKey:kRIEventCurrencyCodeKey];
    if(VALID_NOTEMPTY(currencyCode, NSString))
    {
        [parameters setObject:currencyCode forKey:kAdjustEventCurrencyCodeKey];
    }
    
    NSString *price = [data objectForKey:kRIEventPriceKey];
    if(VALID_NOTEMPTY(price, NSString))
    {
        [parameters setObject:price forKey:kAdjustEventPriceKey];
    }
    
    NSString *numberOfSessions = [data objectForKey:kRIEventAmountSessions];
    if(VALID_NOTEMPTY(numberOfSessions, NSString))
    {
        [parameters setObject:numberOfSessions forKey:kAdjustAmountSessionsKey];
    }
    
    NSString *gender = [data objectForKey:kRIEventGenderKey];
    if(VALID_NOTEMPTY(gender, NSString))
    {
        [parameters setObject:gender forKey:kAdjustEventGenderKey];
    }
    
    NSString *categoryName = [data objectForKey:kRIEventCategoryNameKey];
    if(VALID_NOTEMPTY(categoryName, NSString))
    {
        [parameters setObject:categoryName forKey:kAdjustEventCategoryNameKey];
    }
    
    NSArray *skus = [data objectForKey:kRIEventSkusKey];
    if(VALID_NOTEMPTY(skus, NSArray))
    {
        [parameters setObject:[skus componentsJoinedByString:@","] forKey:kAdjustEventSkusKey];
    }
    
    NSString *categoryId = [data objectForKey:kRIEventCategoryIdKey];
    if(VALID_NOTEMPTY(categoryId, NSString))
    {
        [parameters setObject:categoryId forKey:kAdjustEventCategoryIdKey];
    }
    
    NSString *categoryTree = [data objectForKey:kRIEventTreeKey];
    if(VALID_NOTEMPTY(categoryTree, NSString))
    {
        [parameters setObject:categoryTree forKey:kAdjustEventTreeKey];
    }
    
    NSString *query = [data objectForKey:kRIEventQueryKey];
    if(VALID_NOTEMPTY(query, NSString))
    {
        [parameters setObject:query forKey:kAdjustEventQueryKey];
    }
    
    NSString *product = [data objectForKey:kRIEventProductKey];
    if(VALID_NOTEMPTY(product, NSString))
    {
        [parameters setObject:product forKey:kAdjustEventProductKey];
    }
    
    NSString *keywords = [data objectForKey:kRIEventKeywordsKey];
    if(VALID_NOTEMPTY(keywords, NSString))
    {
        [parameters setObject:keywords forKey:kAdjustEventKeywordsKey];
    }
    
    NSString *brand = [data objectForKey:kRIEventBrandKey];
    if(VALID_NOTEMPTY(brand, NSString))
    {
        [parameters setObject:brand forKey:kAdjustEventBrandKey];
    }
    
    NSString *discount = [data objectForKey:kRIEventDiscountKey];
    if(VALID_NOTEMPTY(discount, NSString))
    {
        [parameters setObject:discount forKey:kAdjustEventDiscountKey];
    }
    
    NSString *size = [data objectForKey:kRIEventSizeKey];
    if(VALID_NOTEMPTY(size, NSString))
    {
        [parameters setObject:size forKey:kAdjustEventSizeKey];
    }
    
    NSString *totalWishlistValue = [data objectForKey:kRIEventTotalWishlistKey];
    if(VALID_NOTEMPTY(totalWishlistValue, NSString))
    {
        [parameters setObject:totalWishlistValue forKey:kAdjustEventTotalWishlistKey];
    }
    
    NSString *quantity = [data objectForKey:kRIEventQuantityKey];
    if(VALID_NOTEMPTY(quantity, NSString))
    {
        [parameters setObject:quantity forKey:kAdjustEventQuantityKey];
    }
    
    NSString *totalCartValue = [data objectForKey:kRIEventTotalCartKey];
    if(VALID_NOTEMPTY(totalCartValue, NSString))
    {
        [parameters setObject:totalCartValue forKey:kAdjustEventTotalCartKey];
    }
    
    return [parameters copy];
}

#pragma mark - RILaunchEventTracker implementation

- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary;
{
    RIDebugLog(@"Adjust - Launch event with data:%@", dataDictionary);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[dataDictionary objectForKey:kRILaunchEventAppVersionDataKey] forKey:kAdjustEventAppVersionDataKey];
    [parameters setObject:[dataDictionary objectForKey:kRILaunchEventDeviceModelDataKey] forKey:kAdjustEventDeviceModelDataKey];
    [parameters setObject:[dataDictionary objectForKey:kRILaunchEventDurationDataKey] forKey:kAdjustEventDurationDataKey];
    
    [Adjust trackEvent:@"2x9nt2" withParameters:parameters];
    
    [parameters setObject:[dataDictionary objectForKey:kRIEventShopCountryKey] forKey:kAdjustEventShopCountryKey];
    
    NSString *userId = [dataDictionary objectForKey:kRIEventUserIdKey];
    if(VALID_NOTEMPTY(userId, NSString) && ![@"0" isEqualToString:userId])
    {
        [parameters setObject:userId  forKey:kAdjustEventUserIdKey];
    }
    
    NSString *gender = [dataDictionary objectForKey:kRIEventGenderKey];
    if(VALID_NOTEMPTY(gender, NSString))
    {
        [parameters setObject:gender  forKey:kAdjustEventGenderKey];
    }

    [Adjust trackEvent:@"xnjttw" withParameters:parameters];
}

#pragma mark - RIEcommerceEventTracking implementation

- (void)trackCheckout:(NSDictionary *)data
{
    RIDebugLog(@"Adjust - Ecommerce event with data:%@", data);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[data objectForKey:kRILaunchEventAppVersionDataKey] forKey:kAdjustEventAppVersionDataKey];
    [parameters setObject:[data objectForKey:kRILaunchEventDeviceModelDataKey] forKey:kAdjustEventDeviceModelDataKey];
    [parameters setObject:[data objectForKey:kRIEventShopCountryKey] forKey:kAdjustEventShopCountryKey];
    [parameters setObject:[data objectForKey:kRIEventUserIdKey]  forKey:kAdjustEventUserIdKey];
    [parameters setObject:[[data objectForKey:kRIEcommerceSkusKey] componentsJoinedByString:@","]  forKey:kAdjustEventSkusKey];
    [parameters setObject:[data objectForKey:kRIEcommerceTransactionIdKey]  forKey:kAdjustEventTransactionIdKey];

    NSNumber *transactionValue = [data objectForKey:kRIEcommerceTotalValueKey];

    NSString *eventKey = @"jk6lja";
    NSNumber *guest = [data objectForKey:kRIEcommerceGuestKey];
    if(VALID_NOTEMPTY(guest, NSNumber) && [guest boolValue])
    {
        eventKey = @"m1il3s";
    }

    [Adjust trackRevenue:[transactionValue floatValue] forEvent:eventKey withParameters:parameters];
}

#pragma mark AdjustDelegate

- (void)adjustFinishedTrackingWithResponse:(AIResponseData *)responseData
{
    if(responseData.success)
    {
        NSLog(@"adjustFinishedTrackingWithResponse success: %@", responseData.activityKindString);
    }
    else
    {
        NSLog(@"adjustFinishedTrackingWithResponse error: %@ - %@", responseData.activityKindString, responseData.error);
    }
}

@end
