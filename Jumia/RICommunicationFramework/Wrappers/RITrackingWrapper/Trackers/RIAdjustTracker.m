
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
#define kAdjustEventColorKey            @"colour"
#define kAdjustEventTotalWishlistKey    @"total_wishlist"
#define kAdjustEventQuantityKey         @"quantity"
#define kAdjustEventTotalCartKey        @"total_cart"
#define kAdjustEventTotalTransactionKey @"total_transaction"
#define kAdjustEventCurrencyKey         @"currency"
#define kAdjustEventQuantityKey         @"quantity"

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
        [events addObject:[NSNumber numberWithInt:RIEventOpenApp]];
        
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
    
#if defined(DEBUG) && DEBUG
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:apiKey
                                                environment:ADJEnvironmentSandbox];
    NSLog(@"Adjust setEnvironment as ADJEnvironmentSandbox");
#else
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:apiKey
                                                environment:ADJEnvironmentProduction];
    NSLog(@"Adjust setEnvironment as ADJEnvironmentProduction");
#endif
    
    [adjustConfig setLogLevel:ADJLogLevelDebug];
    [adjustConfig setDelegate:self];
    [Adjust appDidLaunch:adjustConfig];
}

#pragma mark RIEventTracking protocol

- (void)trackEvent:(NSNumber *)eventType data:(NSDictionary *)data
{
    RIDebugLog(@"Adjust - Tracking event = %@, data %@", eventType, data);
    if([self.registeredEvents containsObject:eventType])
    {
        BOOL amountOfTransactions = YES;
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
                break;
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
            case RIEventOpenApp:
                eventKey = @"2x9nt2";
                amountOfTransactions = NO;
                break;
            default:
                break;
        }
        
        //        ADJEvent *event = [ADJEvent eventWithEventToken:eventKey];
        //        [self addCallbackParameters:data toEvent:event withAmountOfTransactions:amountOfTransactions];
        //        [Adjust trackEvent:event];
    }
}

- (void)addCallbackParameters:(NSDictionary*)data toEvent:(ADJEvent*)event withAmountOfTransactions:(BOOL)amountOfTransactions
{
    if(VALID_NOTEMPTY([data objectForKey:kRILaunchEventAppVersionDataKey], NSString))
    {
        [event addCallbackParameter:kAdjustEventAppVersionDataKey value:[data objectForKey:kRILaunchEventAppVersionDataKey]];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRILaunchEventDeviceModelDataKey], NSString))
    {
        [event addCallbackParameter:kRILaunchEventDeviceModelDataKey value:[data objectForKey:kAdjustEventDeviceModelDataKey]];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRILaunchEventDurationDataKey], NSString))
    {
        [event addCallbackParameter:kRILaunchEventDurationDataKey value:[data objectForKey:kAdjustEventDurationDataKey]];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEventShopCountryKey], NSString))
    {
        [event addCallbackParameter:kAdjustEventShopCountryKey value:[data objectForKey:kRIEventShopCountryKey]];
    }
    
    NSString *userId = [data objectForKey:kRIEventUserIdKey];
    if(VALID_NOTEMPTY(userId, NSString) && ![@"0" isEqualToString:userId])
    {
        [event addCallbackParameter:kAdjustEventUserIdKey value:[data objectForKey:kRIEventUserIdKey]];
    }
    
    NSString *sku = [data objectForKey:kRIEventSkuKey];
    if(VALID_NOTEMPTY(sku, NSString))
    {
        [event addCallbackParameter:kAdjustEventSkuKey value:sku];
    }
    
    NSString *currencyCode = [data objectForKey:kRIEventCurrencyCodeKey];
    if(VALID_NOTEMPTY(currencyCode, NSString))
    {
        [event addCallbackParameter:kAdjustEventCurrencyCodeKey value:currencyCode];
    }
    
    NSNumber *price = [data objectForKey:kRIEventPriceKey];
    if(VALID_NOTEMPTY(price, NSNumber))
    {
        [event addCallbackParameter:kAdjustEventPriceKey value:[price stringValue]];
    }
    
    NSString *numberOfSessions = [data objectForKey:kRIEventAmountSessions];
    if(VALID_NOTEMPTY(numberOfSessions, NSString))
    {
        [event addCallbackParameter:kAdjustAmountSessionsKey value:numberOfSessions];
    }
    
    if(amountOfTransactions)
    {
        NSNumber *numberOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountTransactions];
        if(!VALID_NOTEMPTY(numberOfPurchases, NSNumber))
        {
            numberOfPurchases = [NSNumber numberWithInt:0];
        }
        [event addCallbackParameter:kAdjustAmountTransactionsKey value:[numberOfPurchases stringValue]];
    }
    
    NSString *gender = [data objectForKey:kRIEventGenderKey];
    if(VALID_NOTEMPTY(gender, NSString))
    {
        [event addCallbackParameter:kAdjustEventGenderKey value:gender];
    }
    
    NSString *categoryName = [data objectForKey:kRIEventCategoryNameKey];
    if(VALID_NOTEMPTY(categoryName, NSString))
    {
        [event addCallbackParameter:kAdjustEventCategoryNameKey value:categoryName];
    }
    
    NSArray *skus = [data objectForKey:kRIEventSkusKey];
    if(VALID_NOTEMPTY(skus, NSArray))
    {
        [event addCallbackParameter:kAdjustEventSkusKey value:[skus componentsJoinedByString:@","]];
    }
    
    NSString *categoryId = [data objectForKey:kRIEventCategoryIdKey];
    if(VALID_NOTEMPTY(categoryId, NSString))
    {
        [event addCallbackParameter:kAdjustEventCategoryIdKey value:categoryId];
    }
    
    NSString *categoryTree = [data objectForKey:kRIEventTreeKey];
    if(VALID_NOTEMPTY(categoryTree, NSString))
    {
        [event addCallbackParameter:kAdjustEventTreeKey value:categoryTree];
    }
    
    NSString *query = [data objectForKey:kRIEventQueryKey];
    if(VALID_NOTEMPTY(query, NSString))
    {
        [event addCallbackParameter:kAdjustEventQueryKey value:query];
    }
    
    NSString *product = [data objectForKey:kRIEventProductKey];
    if(VALID_NOTEMPTY(product, NSString))
    {
        [event addCallbackParameter:kAdjustEventProductKey value:product];
    }
    
    NSString *keywords = [data objectForKey:kRIEventKeywordsKey];
    if(VALID_NOTEMPTY(keywords, NSString))
    {
        [event addCallbackParameter:kAdjustEventKeywordsKey value:keywords];
    }
    
    NSString *brand = [data objectForKey:kRIEventBrandKey];
    if(VALID_NOTEMPTY(brand, NSString))
    {
        [event addCallbackParameter:kAdjustEventBrandKey value:brand];
    }
    
    NSString *discount = [data objectForKey:kRIEventDiscountKey];
    if(VALID_NOTEMPTY(discount, NSString))
    {
        [event addCallbackParameter:kAdjustEventDiscountKey value:discount];
    }
    
    NSString *size = [data objectForKey:kRIEventSizeKey];
    if(VALID_NOTEMPTY(size, NSString))
    {
        [event addCallbackParameter:kAdjustEventSizeKey value:size];
    }
    
    NSString *color = [data objectForKey:kRIEventColorKey];
    if (VALID_NOTEMPTY(color, NSString))
    {
        [event addCallbackParameter:kAdjustEventColorKey value:color];
    }
    
    NSString *totalWishlistValue = [data objectForKey:kRIEventTotalWishlistKey];
    if(VALID_NOTEMPTY(totalWishlistValue, NSString))
    {
        [event addCallbackParameter:kAdjustEventTotalWishlistKey value:totalWishlistValue];
    }
    
    NSString *quantity = [data objectForKey:kRIEventQuantityKey];
    if(VALID_NOTEMPTY(quantity, NSString))
    {
        [event addCallbackParameter:kAdjustEventQuantityKey value:quantity];
    }
    
    NSString *totalCartValue = [data objectForKey:kRIEventTotalCartKey];
    if(VALID_NOTEMPTY(totalCartValue, NSString))
    {
        [event addCallbackParameter:kAdjustEventTotalCartKey value:totalCartValue];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEventProductsKey], NSArray))
    {
        for(int i = 0; i < [[data objectForKey:kRIEventProductsKey] count]; i++)
        {
            NSDictionary *product = [[data objectForKey:kRIEventProductsKey] objectAtIndex:i];
            if(VALID_NOTEMPTY(product, NSDictionary))
            {
                NSMutableDictionary *productDictionary = [[NSMutableDictionary alloc] init];
                
                if(VALID_NOTEMPTY([product objectForKey:kRIEventSkuKey], NSString))
                {
                    [productDictionary setObject:[product objectForKey:kRIEventSkuKey] forKey:kAdjustEventSkuKey];
                }
                
                if(VALID_NOTEMPTY([product objectForKey:kRIEventPriceKey], NSNumber))
                {
                    [productDictionary setObject:[[product objectForKey:kRIEventPriceKey] stringValue] forKey:kAdjustEventPriceKey];
                }
                
                if(VALID_NOTEMPTY([product objectForKey:kRIEventCurrencyCodeKey], NSString))
                {
                    [productDictionary setObject:[product objectForKey:kRIEventCurrencyCodeKey] forKey:kAdjustEventCurrencyKey];
                }
                
                if(VALID_NOTEMPTY([product objectForKey:kRIEventQuantityKey], NSString))
                {
                    [productDictionary setObject:[product objectForKey:kRIEventQuantityKey] forKey:kAdjustEventQuantityKey];
                }
                
                [event addCallbackParameter:[NSString stringWithFormat:@"%@%d", kAdjustEventProductKey, (i+1)] value:[productDictionary description]];
            }
        }
    }
    
    NSString *newCustomer = [data objectForKey:kRIEventNewCustomerKey];
    if(VALID_NOTEMPTY(newCustomer, NSString))
    {
        [event addCallbackParameter:kAdjustEventNewCustomerKey value:newCustomer];
    }
    
    NSString *transactionId = [data objectForKey:kRIEventTransactionIdKey];
    if(VALID_NOTEMPTY(transactionId, NSString))
    {
        [event addCallbackParameter:kAdjustEventTransactionIdKey value:transactionId];
    }
    
    NSString *totalTransaction = [data objectForKey:kRIEventTotalTransactionKey];
    if(VALID_NOTEMPTY(totalTransaction, NSString))
    {
        [event addCallbackParameter:kAdjustEventTotalTransactionKey value:totalTransaction];
    }
}

#pragma mark - RILaunchEventTracker implementation

- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary;
{
    RIDebugLog(@"Adjust - Launch event with data:%@", dataDictionary);
    
    // First Adjust launch event
    ADJEvent *launchEvent = [ADJEvent eventWithEventToken:@"2x9nt2"];
    [launchEvent addCallbackParameter:kAdjustEventAppVersionDataKey value:[dataDictionary objectForKey:kRILaunchEventAppVersionDataKey]];
    [launchEvent addCallbackParameter:kAdjustEventDeviceModelDataKey value:[dataDictionary objectForKey:kRILaunchEventDeviceModelDataKey]];
    [launchEvent addCallbackParameter:kAdjustEventDurationDataKey value:[dataDictionary objectForKey:kRILaunchEventDurationDataKey]];
    [Adjust trackEvent:launchEvent];
    
    // Second Adjust launch event
    ADJEvent *event = [ADJEvent eventWithEventToken:@"xnjttw"];
    [event addCallbackParameter:@"country" value:@"b"];
    if ([dataDictionary objectForKey:kRIEventShopCountryKey])
    {
        [event addCallbackParameter:kAdjustEventShopCountryKey value:[dataDictionary objectForKey:kRIEventShopCountryKey]];
    }
    NSString *userId = [dataDictionary objectForKey:kRIEventUserIdKey];
    if(VALID_NOTEMPTY(userId, NSString) && ![@"0" isEqualToString:userId])
    {
        [event addCallbackParameter:kAdjustEventUserIdKey value:userId];
    }
    NSString *gender = [dataDictionary objectForKey:kRIEventGenderKey];
    if(VALID_NOTEMPTY(gender, NSString))
    {
        [event addCallbackParameter:kAdjustEventGenderKey value:gender];
    }
    [Adjust trackEvent:event];
}

#pragma mark - RIEcommerceEventTracking implementation

- (void)trackCheckout:(NSDictionary *)data
{
    RIDebugLog(@"Adjust - Ecommerce event with data:%@", data);
    
    NSString *eventKey = @"jk6lja";
    NSNumber *guest = [data objectForKey:kRIEcommerceGuestKey];
    if(VALID_NOTEMPTY(guest, NSNumber) && [guest boolValue])
    {
        eventKey = @"m1il3s";
    }
    
    ADJEvent *event = [ADJEvent eventWithEventToken:eventKey];
    
    [event addCallbackParameter:kAdjustEventAppVersionDataKey value:[data objectForKey:kRILaunchEventAppVersionDataKey]];
    [event addCallbackParameter:kAdjustEventDeviceModelDataKey value:[data objectForKey:kRILaunchEventDeviceModelDataKey]];
    [event addCallbackParameter:kAdjustEventShopCountryKey value:[data objectForKey:kRIEventShopCountryKey]];
    [event addCallbackParameter:kAdjustEventUserIdKey value:[data objectForKey:kRIEventUserIdKey]];
    [event addCallbackParameter:kAdjustEventSkusKey value:[[data objectForKey:kRIEcommerceSkusKey] componentsJoinedByString:@","]];
    
    NSNumber *numberOfPurchases = [NSNumber numberWithInt:0];
    if(VALID_NOTEMPTY([data objectForKey:kRIEventAmountTransactions], NSNumber))
    {
        numberOfPurchases = [data objectForKey:kRIEventAmountTransactions];
    }
    [event addCallbackParameter:kAdjustAmountTransactionsKey value:[numberOfPurchases stringValue]];
    
    NSNumber *convertedTransactionValue = [data objectForKey:kRIEcommerceConvertedTotalValueKey];
    CGFloat convertedTransactionValueFloat = [convertedTransactionValue floatValue];
    
    [event setRevenue:convertedTransactionValueFloat currency:@"EUR"]; // You have to include the currency
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceTransactionIdKey], NSString))
    {
        [event setTransactionId:[data objectForKey:kRIEcommerceTransactionIdKey]];
        [event addCallbackParameter:kAdjustEventTransactionIdKey value:[data objectForKey:kRIEcommerceTransactionIdKey]];
    }
    [Adjust trackEvent:event];
}

#pragma mark AdjustDelegate
- (void)adjustAttributionChanged:(ADJAttribution *)attribution
{
    if(VALID_NOTEMPTY(attribution.dictionary, NSDictionary) && VALID_NOTEMPTY(attribution.dictionary.description, NSString))
    {
        NSLog(@"adjustAttributionChanged: %@", [attribution.dictionary description]);
    }
}

@end
