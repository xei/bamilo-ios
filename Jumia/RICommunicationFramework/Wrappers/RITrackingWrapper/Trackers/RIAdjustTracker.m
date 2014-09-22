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
#define kAdjustEventProductKey          @"product"
#define kAdjustEventProductsKey         @"products"
#define kAdjustEventKeywordsKey         @"keywords"
#define kAdjustEventNewCustomerKey      @"new_customer"

NSString * const kRIAdjustToken = @"kRIAdjustToken";

@implementation RIAdjustTracker

@synthesize queue;
@synthesize registeredEvents;

- (id)init
{
    NSLog(@"Initializing BugSense tracker");
    
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
        NSLog(@"Adjust - Event registered");
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[data objectForKey:kRILaunchEventAppVersionDataKey] forKey:kAdjustEventAppVersionDataKey];
        [parameters setObject:[data objectForKey:kRILaunchEventDeviceModelDataKey] forKey:kAdjustEventDeviceModelDataKey];
        [parameters setObject:[data objectForKey:kRIEventShopCountryKey] forKey:kAdjustEventShopCountryKey];
        
        NSString *userId = [data objectForKey:kRIEventUserIdKey];
        if(VALID_NOTEMPTY(userId, NSString) && ![@"0" isEqualToString:userId])
        {
            [parameters setObject:[data objectForKey:kRIEventUserIdKey]  forKey:kAdjustEventUserIdKey];
        }
        
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
                [parameters setObject:[data objectForKey:kRIEventSkuKey]  forKey:kAdjustEventSkuKey];
                [parameters setObject:[data objectForKey:kRIEventCurrencyCodeKey]  forKey:kAdjustEventCurrencyCodeKey];
                [parameters setObject:[data objectForKey:kRIEventPriceKey]  forKey:kAdjustEventPriceKey];
                break;
            case RIEventRemoveFromCart:
                eventKey = @"ew5nzy";
                [parameters setObject:[data objectForKey:kRIEventSkuKey]  forKey:kAdjustEventSkuKey];
                [parameters setObject:[data objectForKey:kRIEventCurrencyCodeKey]  forKey:kAdjustEventCurrencyCodeKey];
                [parameters setObject:[data objectForKey:kRIEventPriceKey]  forKey:kAdjustEventPriceKey];
                break;
            case RIEventAddToWishlist:
                eventKey = @"g6en5v";
                [parameters setObject:[data objectForKey:kRIEventSkuKey]  forKey:kAdjustEventSkuKey];
                [parameters setObject:[data objectForKey:kRIEventCurrencyCodeKey]  forKey:kAdjustEventCurrencyCodeKey];
                [parameters setObject:[data objectForKey:kRIEventPriceKey]  forKey:kAdjustEventPriceKey];
                break;
            case RIEventRemoveFromWishlist:
                eventKey = @"v878b6";
                [parameters setObject:[data objectForKey:kRIEventSkuKey]  forKey:kAdjustEventSkuKey];
                [parameters setObject:[data objectForKey:kRIEventCurrencyCodeKey]  forKey:kAdjustEventCurrencyCodeKey];
                [parameters setObject:[data objectForKey:kRIEventPriceKey]  forKey:kAdjustEventPriceKey];
                break;
            case RIEventFacebookLoginSuccess:
                eventKey = @"u98xtu";
                [parameters setObject:[data objectForKey:kRIEventSkuKey]  forKey:kAdjustEventSkuKey];
            case RIEventShareFacebook:
                eventKey = @"kj8g12";
                [parameters setObject:[data objectForKey:kRIEventSkuKey]  forKey:kAdjustEventSkuKey];
                break;
            case RIEventShareTwitter:
                eventKey = @"pzlwy3";
                [parameters setObject:[data objectForKey:kRIEventSkuKey]  forKey:kAdjustEventSkuKey];
                break;
            case RIEventShareEmail:
                eventKey = @"i83rho";
                [parameters setObject:[data objectForKey:kRIEventSkuKey]  forKey:kAdjustEventSkuKey];
                break;
            case RIEventShareSMS:
                eventKey = @"lxq8jt";
                [parameters setObject:[data objectForKey:kRIEventSkuKey]  forKey:kAdjustEventSkuKey];
                break;
            case RIEventCallToOrder:
                eventKey = @"eaaq0p";
                break;
            case RIEventRateProduct:
                eventKey = @"b0mavy";
                [parameters setObject:[data objectForKey:kRIEventSkuKey]  forKey:kAdjustEventSkuKey];
                break;
            case RIEventGuestCustomer:
                eventKey = @"z9v5ec";
                break;
                // TODO: Missing implementation
            case RIEventSearch:
                eventKey = @"469opz";
                break;
            case RIEventViewProduct:
                eventKey = @"b499d1";
                break;
            case RIEventViewListing:
                eventKey = @"rce3dz";
                break;
            case RIEventViewCart:
                eventKey = @"3lv2b5";
                break;
            case RIEventTransactionConfirm:
                eventKey = @"mtzu4i";
                break;
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
            case RIEventFacebookViewTransaction:
                eventKey = @"29kvfe";
                break;
            default:
                break;
        }
        
        [Adjust trackEvent:eventKey withParameters:parameters];
    }
    else
    {
        NSLog(@"Adjust - Event not registered");
    }
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
        [parameters setObject:[dataDictionary objectForKey:kRIEventUserIdKey]  forKey:kAdjustEventUserIdKey];
    }
    
    NSString *gender = [dataDictionary objectForKey:kRIEventGenderKey];
    if(VALID_NOTEMPTY(gender, NSString))
    {
        [parameters setObject:[dataDictionary objectForKey:kRIEventGenderKey]  forKey:kAdjustEventGenderKey];
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
