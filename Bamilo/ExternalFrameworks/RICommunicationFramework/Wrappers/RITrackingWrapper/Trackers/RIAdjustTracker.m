
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
#define kAdjustEventCityKey             @"city"
#define kAdjustEventRegionKey           @"region"

#define kAdjustEventValueToSum          @"_valueToSum"
#define kAdjustEventFbContentId         @"fb_content_id"
#define kAdjustEventFbContentType       @"fb_content_type"
#define kAdjustEventFbCurrency          @"fb_currency"

#define kAdjustEventContentCategory     @"content_category"


NSString * const kRIAdjustToken = @"kRIAdjustToken";

@implementation RIAdjustTracker

@synthesize queue;
@synthesize registeredEvents;

- (id)init {
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
        [events addObject:[NSNumber numberWithInt:RIEventOpenApp]];
        
        [events addObject:[NSNumber numberWithInt:RIEventFacebookViewProduct]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookViewListing]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookViewTransaction]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookAddToCart]];
        
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
//    NSLog(@"Adjust setEnvironment as ADJEnvironmentSandbox");
#else
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:apiKey
                                                environment:ADJEnvironmentProduction];
//    NSLog(@"Adjust setEnvironment as ADJEnvironmentProduction");
#endif
    
    [adjustConfig setLogLevel:ADJLogLevelAssert];// ADJLogLevelDebug];
    [adjustConfig setDelegate:self];
    [Adjust appDidLaunch:adjustConfig];
}

#pragma mark - RIPushNotificaitonTracking

- (void)handlePushNotifcation:(NSDictionary *)info
{
    NSString* url = [info objectForKey:@"u"];
    if (VALID_NOTEMPTY(url, NSString)) {
//        [Adjust appWillOpenUrl:[NSURL URLWithString:[NSString stringWithFormat:@"jumia://?%@",url]]];
        [Adjust appWillOpenUrl:[NSURL URLWithString:url]];
    }
}


#pragma mark RIOpenURLTracking protocol
- (void)trackOpenURL:(NSURL *)url
{
    [Adjust appWillOpenUrl:url];
}

#pragma mark RIEventTracking protocol

- (void)trackEvent:(NSNumber *)eventType data:(NSDictionary *)data
{
    RIDebugLog(@"Adjust - Tracking event = %@, data %@", eventType, data);
    if([self.registeredEvents containsObject:eventType]) {
        
        NSString *keyRIEventLoginSuccess;
        NSString *keyRIEventLogout;
        NSString *keyRIEventRegisterSuccess;
        NSString *keyRIEventAddToCart;
        NSString *keyRIEventRemoveFromCart;
        NSString *keyRIEventAddToWishlist;
        NSString *keyRIEventRemoveFromWishlist;
        NSString *keyRIEventFacebookLoginSuccess;
        NSString *keyRIEventShareFacebook;
        NSString *keyRIEventShareTwitter;
        NSString *keyRIEventShareEmail;
        NSString *keyRIEventShareSMS;
        NSString *keyRIEventCallToOrder;
        NSString *keyRIEventRateProduct;
        NSString *keyRIEventGuestCustomer;
        NSString *keyRIEventSearch;
        NSString *keyRIEventViewProduct;
        NSString *keyRIEventViewListing;
        NSString *keyRIEventViewCart;
        NSString *keyRIEventTransactionConfirm;
        NSString *keyRIEventOpenApp;

        NSString *keyRIEventFacebookViewProduct;
        NSString *keyRIEventFacebookViewListing;
        NSString *keyRIEventFacebookViewTransaction;
        NSString *keyRIEventFacebookAddToCart;
        
        
            
        keyRIEventFacebookAddToCart = @"";
        keyRIEventLoginSuccess = @"y3ehk5";
        keyRIEventLogout = @"rev85g";
        keyRIEventRegisterSuccess = @"6hodya";
        keyRIEventAddToCart = @"k53qfh";
        keyRIEventRemoveFromCart = @"5mj3it";
        keyRIEventAddToWishlist = @"ik3rb5";
        keyRIEventRemoveFromWishlist = @"7inzjw";
        keyRIEventFacebookLoginSuccess = @"zckrfc";
        keyRIEventShareFacebook = @"iijbca";
        keyRIEventShareTwitter = @"w4ug0f";
        keyRIEventShareEmail = @"y7ryl9";
        keyRIEventShareSMS = @"a7rn6n";
        keyRIEventCallToOrder = @"x1e24b";
        keyRIEventRateProduct = @"3t4nj8";
        keyRIEventGuestCustomer = @"uwuz8b";
        keyRIEventSearch = @"1vupdt";
        keyRIEventViewProduct = @"nnwjjo";
        keyRIEventViewListing = @"n5hlwu";
        keyRIEventViewCart = @"pexi13";
        keyRIEventTransactionConfirm = @"ca8jou";
        keyRIEventFacebookViewListing = @"dtglhr";
        keyRIEventFacebookViewProduct = @"l2fxva";
        keyRIEventFacebookViewTransaction = @"ys7sle";
        keyRIEventOpenApp = @"3qdwyi";


        
        BOOL amountOfTransactions = YES;
        NSString *eventKey = @"";
        NSInteger eventTypeInt = [eventType integerValue];
        switch (eventTypeInt) {
            case RIEventFacebookAddToCart:
                eventKey = keyRIEventFacebookAddToCart;
                break;
            case RIEventLoginSuccess:
                eventKey = keyRIEventLoginSuccess;
                break;
            case RIEventLogout:
                eventKey = keyRIEventLogout;
                break;
            case RIEventRegisterSuccess:
                eventKey = keyRIEventRegisterSuccess;
                break;
            case RIEventAddToCart:
                eventKey = keyRIEventAddToCart;
                break;
            case RIEventRemoveFromCart:
                eventKey = keyRIEventRemoveFromCart;
                break;
            case RIEventAddToWishlist:
                eventKey = keyRIEventAddToWishlist;
                break;
            case RIEventRemoveFromWishlist:
                eventKey = keyRIEventRemoveFromWishlist;
                break;
            case RIEventFacebookLoginSuccess:
                eventKey = keyRIEventFacebookLoginSuccess;
                break;
            case RIEventShareFacebook:
                eventKey = keyRIEventShareFacebook;
                break;
            case RIEventShareTwitter:
                eventKey = keyRIEventShareTwitter;
                break;
            case RIEventShareEmail:
                eventKey = keyRIEventShareEmail;
                break;
            case RIEventShareSMS:
                eventKey = keyRIEventShareSMS;
                break;
            case RIEventCallToOrder:
                eventKey = keyRIEventCallToOrder;
                break;
            case RIEventRateProduct:
                eventKey = keyRIEventRateProduct;
                break;
            case RIEventGuestCustomer:
                eventKey = keyRIEventGuestCustomer;
                break;
            case RIEventSearch:
                eventKey = keyRIEventSearch;
                break;
            case RIEventViewProduct:
                eventKey = keyRIEventViewProduct;
                break;
            case RIEventViewListing:
                eventKey = keyRIEventViewListing;
                break;
            case RIEventViewCart:
                eventKey = keyRIEventViewCart;
                break;
            case RIEventTransactionConfirm:
                eventKey = keyRIEventTransactionConfirm;
                break;
            case RIEventFacebookViewListing:
                eventKey = keyRIEventFacebookViewListing;
                break;
            case RIEventFacebookViewProduct:
                eventKey = keyRIEventFacebookViewProduct;
                break;
            case RIEventFacebookViewTransaction:
                eventKey = keyRIEventFacebookViewTransaction;
                break;
            case RIEventOpenApp:
                eventKey = keyRIEventOpenApp;
                amountOfTransactions = NO;
                break;
            default:
                break;
        }
        
        ADJEvent *event = [ADJEvent eventWithEventToken:eventKey];
        [self addCallbackParameters:data toEvent:event withAmountOfTransactions:amountOfTransactions];
        [Adjust trackEvent:event];
    }
}

- (void)addCallbackParameters:(NSDictionary*)data toEvent:(ADJEvent*)event withAmountOfTransactions:(BOOL)amountOfTransactions
{
    if(VALID_NOTEMPTY([data objectForKey:kRIEventFBValueToSumKey], NSString))
    {
        [event addCallbackParameter:kAdjustEventValueToSum value:[data objectForKey:kRIEventFBValueToSumKey]];
        [event addPartnerParameter:kAdjustEventValueToSum value:[data objectForKey:kRIEventFBValueToSumKey]];
    }
    if(VALID_NOTEMPTY([data objectForKey:kRIEventFBContentIdKey], NSString))
    {
        [event addCallbackParameter:kAdjustEventFbContentId value:[data objectForKey:kRIEventFBContentIdKey]];
        [event addPartnerParameter:kAdjustEventFbContentId value:[data objectForKey:kRIEventFBContentIdKey]];
    }
    if(VALID_NOTEMPTY([data objectForKey:kRIEventFBContentTypeKey], NSString))
    {
        [event addCallbackParameter:kAdjustEventFbContentType value:[data objectForKey:kRIEventFBContentTypeKey]];
        [event addPartnerParameter:kAdjustEventFbContentType value:[data objectForKey:kRIEventFBContentTypeKey]];
    }
    if(VALID_NOTEMPTY([data objectForKey:kRIEventFBCurrency], NSString))
    {
        [event addCallbackParameter:kAdjustEventFbCurrency value:[data objectForKey:kRIEventFBCurrency]];
        [event addPartnerParameter:kAdjustEventFbCurrency value:[data objectForKey:kRIEventFBCurrency]];
    }
    if(VALID_NOTEMPTY([data objectForKey:kRIEventFBContentCategory], NSString))
    {
        [event addCallbackParameter:kAdjustEventContentCategory value:[data objectForKey:kRIEventFBContentCategory]];
        [event addPartnerParameter:kAdjustEventContentCategory value:[data objectForKey:kRIEventFBContentCategory]];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRILaunchEventAppVersionDataKey], NSString))
    {
        [event addCallbackParameter:kAdjustEventAppVersionDataKey value:[data objectForKey:kRILaunchEventAppVersionDataKey]];
        [event addPartnerParameter:kAdjustEventAppVersionDataKey value:[data objectForKey:kRILaunchEventAppVersionDataKey]];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRILaunchEventDeviceModelDataKey], NSString))
    {
        [event addCallbackParameter:kAdjustEventDeviceModelDataKey value:[data objectForKey:kRILaunchEventDeviceModelDataKey]];
        [event addPartnerParameter:kAdjustEventDeviceModelDataKey value:[data objectForKey:kRILaunchEventDeviceModelDataKey]];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRILaunchEventDurationDataKey], NSString))
    {
        [event addCallbackParameter:kAdjustEventDurationDataKey value:[data objectForKey:kRILaunchEventDurationDataKey]];
        [event addPartnerParameter:kAdjustEventDurationDataKey value:[data objectForKey:kRILaunchEventDurationDataKey]];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEventShopCountryKey], NSString))
    {
        [event addCallbackParameter:kAdjustEventShopCountryKey value:[data objectForKey:kRIEventShopCountryKey]];
        [event addPartnerParameter:kAdjustEventShopCountryKey value:[data objectForKey:kRIEventShopCountryKey]];
    }
    
    NSString *userId = [data objectForKey:kRIEventUserIdKey];
    if(VALID_NOTEMPTY(userId, NSString) && ![@"0" isEqualToString:userId])
    {
        [event addCallbackParameter:kAdjustEventUserIdKey value:[data objectForKey:kRIEventUserIdKey]];
        [event addPartnerParameter:kAdjustEventUserIdKey value:[data objectForKey:kRIEventUserIdKey]];
    }
    
    NSString *region = [data objectForKey:kRIEventRegionKey];
    if(VALID_NOTEMPTY(region, NSString))
    {
        [event addCallbackParameter:kAdjustEventRegionKey value:region];
        [event addPartnerParameter:kAdjustEventRegionKey value:region];
    }
    
    NSString *city = [data objectForKey:kRIEventCityKey];
    if(VALID_NOTEMPTY(city, NSString))
    {
        [event addCallbackParameter:kAdjustEventCityKey value:city];
        [event addPartnerParameter:kAdjustEventCityKey value:city];
    }
    
    NSString *sku = [data objectForKey:kRIEventSkuKey];
    if(VALID_NOTEMPTY(sku, NSString))
    {
        [event addCallbackParameter:kAdjustEventSkuKey value:sku];
        [event addPartnerParameter:kAdjustEventSkuKey value:sku];
    }
    
    NSString *currencyCode = [data objectForKey:kRIEventCurrencyCodeKey];
    if(VALID_NOTEMPTY(currencyCode, NSString))
    {
        [event addCallbackParameter:kAdjustEventCurrencyCodeKey value:currencyCode];
        [event addPartnerParameter:kAdjustEventCurrencyCodeKey value:currencyCode];
    }
    
    NSNumber *price = [data objectForKey:kRIEventPriceKey];
    if(VALID_NOTEMPTY(price, NSNumber))
    {
        [event addCallbackParameter:kAdjustEventPriceKey value:[price stringValue]];
        [event addPartnerParameter:kAdjustEventPriceKey value:[price stringValue]];
    }
    
    NSString *numberOfSessions = [data objectForKey:kRIEventAmountSessions];
    if(VALID_NOTEMPTY(numberOfSessions, NSString))
    {
        [event addCallbackParameter:kAdjustAmountSessionsKey value:numberOfSessions];
        [event addPartnerParameter:kAdjustAmountSessionsKey value:numberOfSessions];
    }
    
    if(amountOfTransactions)
    {
        NSNumber *numberOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountTransactions];
        if(!VALID_NOTEMPTY(numberOfPurchases, NSNumber))
        {
            numberOfPurchases = [NSNumber numberWithInt:0];
        }
        [event addCallbackParameter:kAdjustAmountTransactionsKey value:[numberOfPurchases stringValue]];
        [event addPartnerParameter:kAdjustAmountTransactionsKey value:[numberOfPurchases stringValue]];
    }
    
    NSString *gender = [data objectForKey:kRIEventGenderKey];
    if(VALID_NOTEMPTY(gender, NSString))
    {
        [event addCallbackParameter:kAdjustEventGenderKey value:gender];
        [event addPartnerParameter:kAdjustEventGenderKey value:gender];
    }
    
    NSString *categoryName = [data objectForKey:kRIEventCategoryIdKey];
    if(VALID_NOTEMPTY(categoryName, NSString))
    {
        [event addCallbackParameter:kAdjustEventCategoryNameKey value:categoryName];
        [event addPartnerParameter:kAdjustEventCategoryNameKey value:categoryName];
    }
    
    NSArray *skus = [data objectForKey:kRIEventSkusKey];
    if(VALID_NOTEMPTY(skus, NSArray))
    {
        [event addCallbackParameter:kAdjustEventSkusKey value:[skus componentsJoinedByString:@","]];
        [event addPartnerParameter:kAdjustEventSkusKey value:[skus componentsJoinedByString:@","]];
    }
    
    NSString *categoryId = [data objectForKey:kRIEventCategoryIdKey];
    if(VALID_NOTEMPTY(categoryId, NSString))
    {
        [event addCallbackParameter:kAdjustEventCategoryIdKey value:categoryId];
        [event addPartnerParameter:kAdjustEventCategoryIdKey value:categoryId];
    }
    
    NSString *categoryTree = [data objectForKey:kRIEventTreeKey];
    if(VALID_NOTEMPTY(categoryTree, NSString))
    {
        [event addCallbackParameter:kAdjustEventTreeKey value:categoryTree];
        [event addPartnerParameter:kAdjustEventTreeKey value:categoryTree];
    }
    
    NSString *query = [data objectForKey:kRIEventQueryKey];
    if(VALID_NOTEMPTY(query, NSString))
    {
        [event addCallbackParameter:kAdjustEventQueryKey value:query];
        [event addPartnerParameter:kAdjustEventQueryKey value:query];
    }
    
    NSString *product = [data objectForKey:kRIEventProductKey];
    if(VALID_NOTEMPTY(product, NSString))
    {
        [event addCallbackParameter:kAdjustEventProductKey value:product];
        [event addPartnerParameter:kAdjustEventProductKey value:product];
    }
    
    NSString *keywords = [data objectForKey:kRIEventKeywordsKey];
    if(VALID_NOTEMPTY(keywords, NSString))
    {
        [event addCallbackParameter:kAdjustEventKeywordsKey value:keywords];
        [event addPartnerParameter:kAdjustEventKeywordsKey value:keywords];
    }
    
    NSString *brand = [data objectForKey:kRIEventBrandName];
    if(VALID_NOTEMPTY(brand, NSString))
    {
        [event addCallbackParameter:kAdjustEventBrandKey value:brand];
        [event addPartnerParameter:kAdjustEventBrandKey value:brand];
    }
    
    NSString *discount = [data objectForKey:kRIEventDiscountKey];
    if(VALID_NOTEMPTY(discount, NSString))
    {
        [event addCallbackParameter:kAdjustEventDiscountKey value:discount];
        [event addPartnerParameter:kAdjustEventDiscountKey value:discount];
    }
    
    NSString *size = [data objectForKey:kRIEventSizeKey];
    if(VALID_NOTEMPTY(size, NSString))
    {
        [event addCallbackParameter:kAdjustEventSizeKey value:size];
        [event addPartnerParameter:kAdjustEventSizeKey value:size];
    }
    
    NSString *color = [data objectForKey:kRIEventColorKey];
    if (VALID_NOTEMPTY(color, NSString))
    {
        [event addCallbackParameter:kAdjustEventColorKey value:color];
        [event addPartnerParameter:kAdjustEventColorKey value:color];
    }
    
    NSString *totalWishlistValue = [data objectForKey:kRIEventTotalWishlistKey];
    if(VALID_NOTEMPTY(totalWishlistValue, NSString))
    {
        [event addCallbackParameter:kAdjustEventTotalWishlistKey value:totalWishlistValue];
        [event addPartnerParameter:kAdjustEventTotalWishlistKey value:totalWishlistValue];
    }
    
    NSString *quantity = [data objectForKey:kRIEventQuantityKey];
    if(VALID_NOTEMPTY(quantity, NSString))
    {
        [event addCallbackParameter:kAdjustEventQuantityKey value:quantity];
        [event addPartnerParameter:kAdjustEventQuantityKey value:quantity];
    }
    
    NSNumber *totalCartValueNumber = [data objectForKey:kRIEventTotalCartKey];
    NSString *totalCartValue = [totalCartValueNumber stringValue];
    if(VALID_NOTEMPTY(totalCartValue, NSString))
    {
        [event addCallbackParameter:kAdjustEventTotalCartKey value:totalCartValue];
        [event addPartnerParameter:kAdjustEventTotalCartKey value:totalCartValue];
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
                [event addPartnerParameter:[NSString stringWithFormat:@"%@%d", kAdjustEventProductKey, (i+1)] value:[productDictionary description]];
            }
        }
    }
    
    NSString *newCustomer = [data objectForKey:kRIEventNewCustomerKey];
    if(VALID_NOTEMPTY(newCustomer, NSString))
    {
        [event addCallbackParameter:kAdjustEventNewCustomerKey value:newCustomer];
        [event addPartnerParameter:kAdjustEventNewCustomerKey value:newCustomer];
    }
    
    NSString *transactionId = [data objectForKey:kRIEventTransactionIdKey];
    if(VALID_NOTEMPTY(transactionId, NSString))
    {
        [event addCallbackParameter:kAdjustEventTransactionIdKey value:transactionId];
        [event addPartnerParameter:kAdjustEventTransactionIdKey value:transactionId];
    }
    
    NSString *totalTransaction = [data objectForKey:kRIEventTotalTransactionKey];
    if(VALID_NOTEMPTY(totalTransaction, NSString))
    {
        [event addCallbackParameter:kAdjustEventTotalTransactionKey value:totalTransaction];
        [event addPartnerParameter:kAdjustEventTotalTransactionKey value:totalTransaction];
    }
}

#pragma mark - RILaunchEventTracker implementation

- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary;
{
    RIDebugLog(@"Adjust - Launch event with data:%@", dataDictionary);
    
    // First Adjust launch event
    ADJEvent *launchEvent;
    
    launchEvent = [ADJEvent eventWithEventToken:@"3qdwyi"];
    
    [launchEvent addCallbackParameter:kAdjustEventAppVersionDataKey value:[dataDictionary objectForKey:kRILaunchEventAppVersionDataKey]];
    [launchEvent addPartnerParameter:kAdjustEventAppVersionDataKey value:[dataDictionary objectForKey:kRILaunchEventAppVersionDataKey]];
    [launchEvent addCallbackParameter:kAdjustEventDeviceModelDataKey value:[dataDictionary objectForKey:kRILaunchEventDeviceModelDataKey]];
    [launchEvent addPartnerParameter:kAdjustEventDeviceModelDataKey value:[dataDictionary objectForKey:kRILaunchEventDeviceModelDataKey]];
    [launchEvent addCallbackParameter:kAdjustEventDurationDataKey value:[dataDictionary objectForKey:kRILaunchEventDurationDataKey]];
    [launchEvent addPartnerParameter:kAdjustEventDurationDataKey value:[dataDictionary objectForKey:kRILaunchEventDurationDataKey]];
    [Adjust trackEvent:launchEvent];
    
    // Second Adjust launch event
    ADJEvent *event;
   
    event = [ADJEvent eventWithEventToken:@"tly4ql"];
   
    
    if ([dataDictionary objectForKey:kRIEventShopCountryKey]) {
        [event addCallbackParameter:kAdjustEventShopCountryKey value:[dataDictionary objectForKey:kRIEventShopCountryKey]];
        [event addPartnerParameter:kAdjustEventShopCountryKey value:[dataDictionary objectForKey:kRIEventShopCountryKey]];
    }
    NSString *userId = [dataDictionary objectForKey:kRIEventUserIdKey];
    if(VALID_NOTEMPTY(userId, NSString) && ![@"0" isEqualToString:userId]) {
        [event addCallbackParameter:kAdjustEventUserIdKey value:userId];
        [event addPartnerParameter:kAdjustEventUserIdKey value:userId];
    }
    NSString *gender = [dataDictionary objectForKey:kRIEventGenderKey];
    if(VALID_NOTEMPTY(gender, NSString)) {
        [event addCallbackParameter:kAdjustEventGenderKey value:gender];
        [event addPartnerParameter:kAdjustEventGenderKey value:gender];
    }
    
    [event addCallbackParameter:kAdjustEventAppVersionDataKey value:[dataDictionary objectForKey:kRILaunchEventAppVersionDataKey]];
    [event addPartnerParameter:kAdjustEventAppVersionDataKey value:[dataDictionary objectForKey:kRILaunchEventAppVersionDataKey]];
    [event addCallbackParameter:kAdjustEventDurationDataKey value:[dataDictionary objectForKey:kRILaunchEventDurationDataKey]];
    [event addPartnerParameter:kAdjustEventDurationDataKey value:[dataDictionary objectForKey:kRILaunchEventDurationDataKey]];
    [event addCallbackParameter:kAdjustEventDeviceModelDataKey value:[dataDictionary objectForKey:kRILaunchEventDeviceModelDataKey]];
    [event addPartnerParameter:kAdjustEventDeviceModelDataKey value:[dataDictionary objectForKey:kRILaunchEventDeviceModelDataKey]];
    [Adjust trackEvent:event];
}

#pragma mark - RIEcommerceEventTracking implementation

- (void)trackCheckout:(NSDictionary *)data {
    RIDebugLog(@"Adjust - Ecommerce event with data:%@", data);
    
    NSString *eventKey;

    eventKey = @"pakn7o";

    NSNumber *guest = [data objectForKey:kRIEcommerceGuestKey];
    if(VALID_NOTEMPTY(guest, NSNumber) && [guest boolValue]) {
        eventKey =@"cndznn";
    }
    
    ADJEvent *event = [ADJEvent eventWithEventToken:eventKey];
    
    [event addCallbackParameter:kAdjustEventAppVersionDataKey value:[data objectForKey:kRILaunchEventAppVersionDataKey]];
    [event addPartnerParameter:kAdjustEventAppVersionDataKey value:[data objectForKey:kRILaunchEventAppVersionDataKey]];
    [event addCallbackParameter:kAdjustEventDeviceModelDataKey value:[data objectForKey:kRILaunchEventDeviceModelDataKey]];
    [event addPartnerParameter:kAdjustEventDeviceModelDataKey value:[data objectForKey:kRILaunchEventDeviceModelDataKey]];
    [event addCallbackParameter:kAdjustEventShopCountryKey value:[data objectForKey:kRIEventShopCountryKey]];
    [event addPartnerParameter:kAdjustEventShopCountryKey value:[data objectForKey:kRIEventShopCountryKey]];
    [event addCallbackParameter:kAdjustEventUserIdKey value:[data objectForKey:kRIEventUserIdKey]];
    [event addPartnerParameter:kAdjustEventUserIdKey value:[data objectForKey:kRIEventUserIdKey]];
    [event addCallbackParameter:kAdjustEventSkusKey value:[[data objectForKey:kRIEcommerceSkusKey] componentsJoinedByString:@","]];
    [event addPartnerParameter:kAdjustEventSkusKey value:[[data objectForKey:kRIEcommerceSkusKey] componentsJoinedByString:@","]];
    
    NSNumber *numberOfPurchases = [NSNumber numberWithInt:0];
    if(VALID_NOTEMPTY([data objectForKey:kRIEventAmountTransactions], NSNumber))
    {
        numberOfPurchases = [data objectForKey:kRIEventAmountTransactions];
    }
    [event addCallbackParameter:kAdjustAmountTransactionsKey value:[numberOfPurchases stringValue]];
    [event addPartnerParameter:kAdjustAmountTransactionsKey value:[numberOfPurchases stringValue]];
    
    NSNumber *convertedTransactionValue = [data objectForKey:kRIEcommerceConvertedTotalValueKey];
    CGFloat convertedTransactionValueFloat = [convertedTransactionValue floatValue];
    
    [event setRevenue:convertedTransactionValueFloat currency:@"EUR"]; // You have to include the currency
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceTransactionIdKey], NSString))
    {
        [event setTransactionId:[data objectForKey:kRIEcommerceTransactionIdKey]];
        [event addCallbackParameter:kAdjustEventTransactionIdKey value:[data objectForKey:kRIEcommerceTransactionIdKey]];
        [event addPartnerParameter:kAdjustEventTransactionIdKey value:[data objectForKey:kRIEcommerceTransactionIdKey]];
    }
    [Adjust trackEvent:event];
}

#pragma mark AdjustDelegate
- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    if(VALID_NOTEMPTY(attribution, ADJAttribution)) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(adjustAttributionChanged:campaign:adGroup:creative:)]) {
            [self.delegate adjustAttributionChanged:attribution.network campaign:attribution.campaign adGroup:attribution.adgroup creative:attribution.creative];
        }
    }
}

@end
