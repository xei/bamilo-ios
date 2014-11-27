//
//  RIGTMTracker.m
//  Jumia
//
//  Created by plopes on 26/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIGTMTracker.h"
#import "TAGContainer.h"
#import "TAGContainerOpener.h"
#import "TAGManager.h"
#import "TAGDataLayer.h"

#define kGTMEventKey                            @"event"
#define kGTMEventSourceKey                      @"source"
#define kGTMEventCampaignKey                    @"campaign"
#define kGTMEventAppVersionKey                  @"appVersion"
#define kGTMEventShopCountryKey                 @"shopCountry"
#define kGTMEventLoginMethodKey                 @"loginMethod"
#define kGTMEventLoginLocationKey               @"loginLocation"
#define kGTMEventCustomerIdKey                  @"customerId"
#define kGTMEventUserAgeKey                     @"userAge"
#define kGTMEventUserGenderKey                  @"userGender"
#define kGTMEventAccountCreationDateKey         @"accountCreationDate"
#define kGTMEventNumberPurchasesKey             @"numberPurchases"
#define kGTMEventRegistrationMethodKey          @"registrationMethod"
#define kGTMEventRegistrationLocationKey        @"registrationLocation"
#define kGTMEventSubscriberIdKey                @"subscriberId"
#define kGTMEventSignUpLocationKey              @"signUpLocation"
#define kGTMEventSearchTermKey                  @"searchTerm"
#define kGTMEventResultsNumberKey               @"resultsNumber"
#define kGTMEventSocialNetworkKey               @"socialNetwork"
#define kGTMEventShareLocationKey               @"shareLocation"
#define kGTMEventProductSKUKey                  @"productSKU"
#define kGTMEventProductCategoryKey             @"productCategory"
#define kGTMEventProductBrandKey                @"productBrand"
#define kGTMEventProductSubCategoryKey          @"productSubcategory"
#define kGTMEventProductPriceKey                @"productPrice"
#define kGTMEventCurrencyKey                    @"currency"
#define kGTMEventDiscountKey                    @"discount"
#define kGTMEventProductRatingKey               @"productRating"
#define kGTMEventProductQuantityKey             @"productQuantity"
#define kGTMEventLocationKey                    @"location"
#define kGTMEventAverageRatingTotalKey          @"averageRatingTotal"
#define kGTMEventQuantityCartKey                @"quantityCart"
#define kGTMEventCartValueKey                   @"cartValue"
#define kGTMEventRatingPriceKey                 @"ratingPrice"
#define kGTMEventRatingAppearanceKey            @"ratingAppearance"
#define kGTMEventRatingQualityKey               @"ratingQuality"
#define kGTMEventAverageRatingPriceKey          @"averageRatingPrice"
#define kGTMEventAverageRatingAppearanceKey     @"averageRatingAppearance"
#define kGTMEventAverageRatingQualityKey        @"averageRatingQuality"
#define kGTMEventAverageRatingTotalKey          @"averageRatingTotal"
#define kGTMEventCategoryKey                    @"category"
#define kGTMEventSubCategoryKey                 @"subcategory"
#define kGTMEventPageNumberKey                  @"pageNumber"
#define kGTMEventFilterTypeKey                  @"filterType"
#define kGTMEventSortTypeKey                    @"sortType"
#define kGTMEventAddressCorrectKey              @"adressCorrect"
#define kGTMEventPaymentMethodKey               @"paymentMethod"
#define kGTMEventPreviousPurchasesKey           @"previousPurchases"
#define kGTMEventTransactionTotalKey            @"transactionTotal"
#define kGTMEventVoucherAmountKey               @"voucherAmount"
#define kGTMEventTransactionIdKey               @"transactionId"
#define kGTMEventTransactionAffiliationKey      @"transactionAffiliation"
#define kGTMEventTransactionShippingKey         @"transactionShipping"
#define kGTMEventTransactionTaxKey              @"transactionTax"
#define kGTMEventTransactionCurrencyKey         @"transactionCurrency"
#define kGTMEventTransactionProductsKey         @"transactionProducts"
#define kGTMEventTransactionProductNameKey      @"name"
#define kGTMEventTransactionProductSkuKey       @"sku"
#define kGTMEventTransactionProductCategoryKey  @"category"
#define kGTMEventTransactionProductPriceKey     @"price"
#define kGTMEventTransactionProductCurrencyKey  @"currency"
#define kGTMEventTransactionProductQuantityKey  @"quantity"
#define kGTMEventScreenNameKey                  @"screenName"
#define kGTMEventLoadTimeKey                    @"loadTime"

NSString * const kGTMToken = @"kGTMToken";

@interface RIGTMTracker ()
<TAGContainerOpenerNotifier>

@property (nonatomic, strong) TAGManager *tagManager;
@property (nonatomic, strong) TAGContainer *container;
@property (nonatomic, strong) NSMutableArray *pendingEvents;
@property (nonatomic, assign) BOOL containerIsAvailable;

@end

@implementation RIGTMTracker

@synthesize queue;
@synthesize registeredEvents;

- (id)init
{
    RIDebugLog(@"Initializing Adjust tracker");
    
    if ((self = [super init])) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        
        self.pendingEvents = [[NSMutableArray alloc] init];
        self.containerIsAvailable = NO;
        
        NSMutableArray *events = [[NSMutableArray alloc] init];
        
        [events addObject:[NSNumber numberWithInt:RIEventLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventAutoLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventLoginFail]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookLoginFail]];
        [events addObject:[NSNumber numberWithInt:RIEventAutoLoginFail]];
        [events addObject:[NSNumber numberWithInt:RIEventSignupSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventRegisterSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventSignupFail]];
        [events addObject:[NSNumber numberWithInt:RIEventRegisterFail]];
        [events addObject:[NSNumber numberWithInt:RIEventNewsletter]];
        [events addObject:[NSNumber numberWithInt:RIEventSearch]];
        [events addObject:[NSNumber numberWithInt:RIEventShareEmail]];
        [events addObject:[NSNumber numberWithInt:RIEventShareFacebook]];
        [events addObject:[NSNumber numberWithInt:RIEventShareTwitter]];
        [events addObject:[NSNumber numberWithInt:RIEventShareSMS]];
        [events addObject:[NSNumber numberWithInt:RIEventShareOther]];
        [events addObject:[NSNumber numberWithInt:RIEventChangeCountry]];
        [events addObject:[NSNumber numberWithInt:RIEventViewProduct]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToCart]];
        [events addObject:[NSNumber numberWithInt:RIEventIncreaseQuantity]];
        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromCart]];
        [events addObject:[NSNumber numberWithInt:RIEventDecreaseQuantity]];
        [events addObject:[NSNumber numberWithInt:RIEventRateProductGlobal]];
        [events addObject:[NSNumber numberWithInt:RIEventViewRatings]];
        [events addObject:[NSNumber numberWithInt:RIEventViewGTMListing]];
        [events addObject:[NSNumber numberWithInt:RIEventIndividualFilter]];
        [events addObject:[NSNumber numberWithInt:RIEventSort]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventViewCart]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutStart]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutAddAddressSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutAddAddressFail]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutPaymentSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutPaymentFail]];
        [events addObject:[NSNumber numberWithInt:RIEventCloseApp]];
        
        self.registeredEvents = [events copy];
    }
    
    return self;
}

#pragma mark - RITracker protocol

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options
{
    RIDebugLog(@"GTM tracker tracks application launch");
    
    NSString *containerId = [RITrackingConfiguration valueForKey:kGTMToken];
    
    if (!containerId) {
        RIRaiseError(@"Missing GTM container ID in tracking properties")
        return;
    }
    
    self.tagManager = [TAGManager instance];
    
    // Optional: Change the LogLevel to Verbose to enable logging at VERBOSE and higher levels.
    [self.tagManager.logger setLogLevel:kTAGLoggerLogLevelVerbose];
    
    /*
     * Opens a container and returns a TAGContainerFuture.
     *
     * @param containerId The ID of the container to load.
     * @param tagManager The TAGManager instance for getting the container.
     * @param openType The choice of how to open the container.
     * @param timeout The timeout period (default is 2.0 seconds).
     */
    [TAGContainerOpener openContainerWithId:containerId   // Update with your Container ID.
                                 tagManager:self.tagManager
                                   openType:kTAGOpenTypePreferFresh
                                    timeout:nil
                                   notifier:self];
}

- (void)containerAvailable:(TAGContainer *)container
{
    self.container = container;
    self.containerIsAvailable = YES;
    
    // The container should have already been opened, otherwise events pushed to
    // the data layer will not fire tags in that container.
    TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
    
    for(NSDictionary *event in self.pendingEvents)
    {
        [dataLayer push:event];
    }
    
    self.pendingEvents = [[NSMutableArray alloc] init];
}

- (void)pushEvent:(NSDictionary*)event
{
    if(self.containerIsAvailable)
    {
        // The container should have already been opened, otherwise events pushed to
        // the data layer will not fire tags in that container.
        TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
        [dataLayer push:event];
    }
    else
    {
        [self.pendingEvents addObject:event];
    }
}

#pragma mark - RILaunchEventTracker implementation

- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary;
{
    RIDebugLog(@"GTM - Launch event with data:%@", dataDictionary);
    
    NSMutableDictionary *pushedData = [[NSMutableDictionary alloc] init];
    [pushedData setObject:@"openApp" forKey:kGTMEventKey];
    
    if(VALID_NOTEMPTY([dataDictionary objectForKey:kRILaunchEventSourceKey], NSString))
    {
        [pushedData setObject:[dataDictionary objectForKey:kRILaunchEventSourceKey] forKey:kGTMEventSourceKey];
    }
    
    if(VALID_NOTEMPTY([dataDictionary objectForKey:kRILaunchEventCampaignKey], NSString))
    {
        [pushedData setObject:[dataDictionary objectForKey:kRILaunchEventCampaignKey] forKey:kGTMEventCampaignKey];
    }
    
    if(VALID_NOTEMPTY([dataDictionary objectForKey:kRILaunchEventAppVersionDataKey], NSString))
    {
        [pushedData setObject:[dataDictionary objectForKey:kRILaunchEventAppVersionDataKey] forKey:kGTMEventAppVersionKey];
    }
    
    if(VALID_NOTEMPTY([dataDictionary objectForKey:kRIEventShopCountryKey], NSString))
    {
        [pushedData setObject:[dataDictionary objectForKey:kRIEventShopCountryKey] forKey:kGTMEventShopCountryKey];
    }
    
    [self pushEvent:pushedData];
}

#pragma mark RIEventTracking protocol

- (void)trackEvent:(NSNumber *)eventType data:(NSDictionary *)data
{
    RIDebugLog(@"GTM - Tracking event = %@, data %@", eventType, data);
    if([self.registeredEvents containsObject:eventType])
    {
        NSMutableDictionary *pushedData = [[NSMutableDictionary alloc] init];
        
        NSInteger eventTypeInt = [eventType integerValue];
        switch (eventTypeInt) {
            case RIEventLoginSuccess:
                [pushedData setObject:@"login" forKey:kGTMEventKey];
                [pushedData setObject:@"Email Auth" forKey:kGTMEventLoginMethodKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLoginLocationKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventUserIdKey] forKey:kGTMEventCustomerIdKey];
                }
                break;
            case RIEventFacebookLoginSuccess:
                [pushedData setObject:@"login" forKey:kGTMEventKey];
                [pushedData setObject:@"Facebook" forKey:kGTMEventLoginMethodKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLoginLocationKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventUserIdKey] forKey:kGTMEventCustomerIdKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventAgeKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventAgeKey] forKey:kGTMEventUserAgeKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventGenderKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventGenderKey] forKey:kGTMEventUserGenderKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventAccountDateKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventAccountDateKey] forKey:kGTMEventAccountCreationDateKey];
                }
                break;
            case RIEventAutoLoginSuccess:
                [pushedData setObject:@"autoLogin" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventUserIdKey] forKey:kGTMEventCustomerIdKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventAgeKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventAgeKey] forKey:kGTMEventUserAgeKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventGenderKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventGenderKey] forKey:kGTMEventUserGenderKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventAccountDateKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventAccountDateKey] forKey:kGTMEventAccountCreationDateKey];
                }
                break;
            case RIEventLoginFail:
                [pushedData setObject:@"loginFailed" forKey:kGTMEventKey];
                [pushedData setObject:@"Email Auth" forKey:kGTMEventLoginMethodKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLoginLocationKey];
                }
                break;
            case RIEventFacebookLoginFail:
                [pushedData setObject:@"loginFailed" forKey:kGTMEventKey];
                [pushedData setObject:@"Facebook" forKey:kGTMEventLoginMethodKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLoginLocationKey];
                }
                break;
            case RIEventAutoLoginFail:
                [pushedData setObject:@"autoLoginFailed" forKey:kGTMEventKey];
                break;
            case RIEventLogout:
                [pushedData setObject:@"logout" forKey:kGTMEventKey];
                [pushedData setObject:@"Side menu" forKey:kRIEventLocationKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventUserIdKey] forKey:kGTMEventCustomerIdKey];
                }
                break;
            case RIEventRegisterSuccess:
            case RIEventSignupSuccess:
                [pushedData setObject:@"register" forKey:kGTMEventKey];
                [pushedData setObject:@"Email Auth" forKey:kGTMEventRegistrationMethodKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventRegistrationLocationKey];
                }
                break;
            case RIEventRegisterFail:
            case RIEventSignupFail:
                [pushedData setObject:@"registerFailed" forKey:kGTMEventKey];
                [pushedData setObject:@"Email Auth" forKey:kGTMEventRegistrationMethodKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventRegistrationLocationKey];
                }
                break;
            case RIEventNewsletter:
                [pushedData setObject:@"signUp" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventUserIdKey] forKey:kGTMEventSubscriberIdKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventSignUpLocationKey];
                }
                break;
            case RIEventSearch:
                [pushedData setObject:@"search" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventKeywordsKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventKeywordsKey] forKey:kGTMEventSearchTermKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventNumberOfProductsKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventNumberOfProductsKey] forKey:kGTMEventResultsNumberKey];
                }
                break;
            case RIEventShareEmail:
                [pushedData setObject:@"shareProduct" forKey:kGTMEventKey];
                [pushedData setObject:@"Email" forKey:kGTMEventSocialNetworkKey];
                [pushedData setObject:@"Product Page" forKey:kGTMEventShareLocationKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                break;
            case RIEventShareFacebook:
                [pushedData setObject:@"shareProduct" forKey:kGTMEventKey];
                [pushedData setObject:@"Facebook" forKey:kGTMEventSocialNetworkKey];
                [pushedData setObject:@"Product Page" forKey:kGTMEventShareLocationKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                break;
            case RIEventShareTwitter:
                [pushedData setObject:@"shareProduct" forKey:kGTMEventKey];
                [pushedData setObject:@"Twitter" forKey:kGTMEventSocialNetworkKey];
                [pushedData setObject:@"Product Page" forKey:kGTMEventShareLocationKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                break;
            case RIEventShareSMS:
                [pushedData setObject:@"shareProduct" forKey:kGTMEventKey];
                [pushedData setObject:@"SMS" forKey:kGTMEventSocialNetworkKey];
                [pushedData setObject:@"Product Page" forKey:kGTMEventShareLocationKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                break;
            case RIEventShareOther:
                [pushedData setObject:@"shareProduct" forKey:kGTMEventKey];
                [pushedData setObject:@"Other" forKey:kGTMEventSocialNetworkKey];
                [pushedData setObject:@"Product Page" forKey:kGTMEventShareLocationKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                break;
            case RIEventChangeCountry:
                [pushedData setObject:@"changeCountry" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventShopCountryKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventShopCountryKey] forKey:kGTMEventShopCountryKey];
                }
                break;
            case RIEventViewProduct:
                [pushedData setObject:@"viewProduct" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventProductKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventProductKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventBrandKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventBrandKey] forKey:kGTMEventProductBrandKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPriceKey] forKey:kGTMEventProductPriceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCurrencyCodeKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCurrencyCodeKey] forKey:kGTMEventCurrencyKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventDiscountKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventDiscountKey] forKey:kGTMEventDiscountKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingKey] forKey:kGTMEventProductRatingKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                
                //                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSubCategoryKey];
                break;
            case RIEventAddToCart:
            case RIEventIncreaseQuantity:
                [pushedData setObject:@"addToCart" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventBrandKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventBrandKey] forKey:kGTMEventProductBrandKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPriceKey] forKey:kGTMEventProductPriceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                
                //                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSubCategoryKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCurrencyCodeKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCurrencyCodeKey] forKey:kGTMEventCurrencyKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventDiscountKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventDiscountKey] forKey:kGTMEventDiscountKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventQuantityKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventQuantityKey] forKey:kGTMEventProductQuantityKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLocationKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingKey] forKey:kGTMEventProductRatingKey];
                }
                
                break;
            case RIEventRemoveFromCart:
            case RIEventDecreaseQuantity:
                [pushedData setObject:@"removeFromCart" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPriceKey] forKey:kGTMEventProductPriceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingKey] forKey:kGTMEventProductRatingKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventQuantityKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventQuantityKey] forKey:kGTMEventProductQuantityKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventTotalCartKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventTotalCartKey] forKey:kGTMEventCartValueKey];
                }
                
                break;
            case RIEventRateProductGlobal:
                [pushedData setObject:@"rateProduct" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPriceKey] forKey:kGTMEventProductPriceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventBrandKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventBrandKey] forKey:kGTMEventProductBrandKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingKey] forKey:kGTMEventProductRatingKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingPriceKey] forKey:kGTMEventRatingPriceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingAppearanceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingAppearanceKey] forKey:kGTMEventRatingAppearanceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingQualityKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingQualityKey] forKey:kGTMEventRatingQualityKey];
                }
                break;
            case RIEventViewRatings:
                [pushedData setObject:@"viewRating" forKey:kGTMEventKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventBrandKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventBrandKey] forKey:kGTMEventProductBrandKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPriceKey] forKey:kGTMEventProductPriceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                
                //                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSubCategoryKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingKey] forKey:kGTMEventAverageRatingTotalKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingPriceKey] forKey:kGTMEventAverageRatingPriceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingAppearanceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingAppearanceKey] forKey:kGTMEventAverageRatingAppearanceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingQualityKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingQualityKey] forKey:kGTMEventAverageRatingQualityKey];
                }
                break;
            case RIEventViewGTMListing:
                [pushedData setObject:@"viewCatalog" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventCategoryKey];
                }
                
                //                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventSubCategoryKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPageNumberKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPageNumberKey] forKey:kGTMEventPageNumberKey];
                }
                break;
            case RIEventIndividualFilter:
                [pushedData setObject:@"filterCatalog" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventFilterTypeKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventFilterTypeKey] forKey:kGTMEventFilterTypeKey];
                }
                break;
            case RIEventSort:
                [pushedData setObject:@"sortCatalog" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSortTypeKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSortTypeKey] forKey:kGTMEventFilterTypeKey];
                }
                break;
            case RIEventAddToWishlist:
                [pushedData setObject:@"addToWL" forKey:kGTMEventKey];
                //                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSKUKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventBrandKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventBrandKey] forKey:kGTMEventProductBrandKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPriceKey] forKey:kGTMEventProductPriceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                
                //                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSubCategoryKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCurrencyCodeKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCurrencyCodeKey] forKey:kGTMEventCurrencyKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventDiscountKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventDiscountKey] forKey:kGTMEventDiscountKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLocationKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingKey] forKey:kGTMEventAverageRatingTotalKey];
                }
                break;
            case RIEventRemoveFromWishlist:
                [pushedData setObject:@"removeFromWL" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPriceKey] forKey:kGTMEventProductPriceKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingKey] forKey:kGTMEventProductRatingKey];
                }
                break;
            case RIEventViewCart:
                [pushedData setObject:@"viewCart" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventQuantityKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventQuantityKey] forKey:kGTMEventQuantityCartKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventTotalCartKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventTotalCartKey] forKey:kGTMEventCartValueKey];
                }
                break;
            case RIEventCheckoutStart:
                [pushedData setObject:@"startCheckout" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventQuantityKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventQuantityKey] forKey:kGTMEventQuantityCartKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventTotalCartKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventTotalCartKey] forKey:kGTMEventCartValueKey];
                }
                break;
            case RIEventCheckoutAddAddressSuccess:
                [pushedData setObject:@"enterAddress" forKey:kGTMEventKey];
                [pushedData setObject:[NSNumber numberWithBool:YES] forKey:kGTMEventAddressCorrectKey];
                break;
            case RIEventCheckoutAddAddressFail:
                [pushedData setObject:@"enterAddress" forKey:kGTMEventKey];
                [pushedData setObject:[NSNumber numberWithBool:NO] forKey:kGTMEventAddressCorrectKey];
                break;
            case RIEventCheckoutPaymentSuccess:
                [pushedData setObject:@"choosePayment" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPaymentMethodKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPaymentMethodKey] forKey:kGTMEventPaymentMethodKey];
                }
                break;
            case RIEventCheckoutPaymentFail:
                [pushedData setObject:@"failedPayment" forKey:kGTMEventKey];
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPaymentMethodKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPaymentMethodKey] forKey:kGTMEventPaymentMethodKey];
                }
                
                if(VALID_NOTEMPTY([data objectForKey:kRIEventTotalTransactionKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventTotalTransactionKey] forKey:kGTMEventTransactionTotalKey];
                }
                break;
            case RIEventCloseApp:
                [pushedData setObject:@"openScreen" forKey:kGTMEventKey];
                [pushedData setObject:[data objectForKey:kRIEventScreenNameKey] forKey:kGTMEventScreenNameKey];
                break;
        }
        
        [self pushEvent:pushedData];
    }
}

#pragma mark - RIEcommerceEventTracking implementation

- (void)trackCheckout:(NSDictionary *)data
{
    RIDebugLog(@"GTM - Ecommerce event with data:%@", data);
    
    NSMutableDictionary *pushedData = [NSMutableDictionary dictionary];
    [pushedData setObject:@"transaction" forKey:kGTMEventKey];
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommercePaymentMethodKey], NSString))
    {
        [pushedData setObject:[data objectForKey:kRIEcommercePaymentMethodKey] forKey:kGTMEventPaymentMethodKey];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceCouponKey], NSString))
    {
        [pushedData setObject:[data objectForKey:kRIEcommerceCouponKey] forKey:kGTMEventVoucherAmountKey];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommercePreviousPurchases], NSNumber))
    {
        [pushedData setObject:[data objectForKey:kRIEcommercePreviousPurchases] forKey:kGTMEventPreviousPurchasesKey];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceTransactionIdKey], NSString))
    {
        [pushedData setObject:[data objectForKey:kRIEcommerceTransactionIdKey] forKey:kGTMEventTransactionIdKey];
    }
    
    [pushedData setObject:@"In-App Store" forKey:kGTMEventTransactionAffiliationKey];
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceTotalValueKey], NSNumber))
    {
        [pushedData setObject:[data objectForKey:kRIEcommerceTotalValueKey] forKey:kGTMEventTransactionTotalKey];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceShippingKey], NSNumber))
    {
        [pushedData setObject:[data objectForKey:kRIEcommerceShippingKey] forKey:kGTMEventTransactionShippingKey];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceTaxKey], NSNumber))
    {
        [pushedData setObject:[data objectForKey:kRIEcommerceTaxKey] forKey:kGTMEventTransactionTaxKey];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceCurrencyKey], NSNumber))
    {
        [pushedData setObject:[data objectForKey:kRIEcommerceCurrencyKey] forKey:kGTMEventTransactionCurrencyKey];
    }
    
    if(VALID_NOTEMPTY([data objectForKey:kRIEcommerceProducts], NSArray))
    {
        NSMutableArray *productsArray = [[NSMutableArray alloc] init];
        for(NSDictionary *product in  [data objectForKey:kRIEcommerceProducts])
        {
            if(VALID_NOTEMPTY(product, NSDictionary))
            {
                NSMutableDictionary *productDictionary = [[NSMutableDictionary alloc] init];
                
                if(VALID_NOTEMPTY([product objectForKey:kRIEventProductNameKey], NSString))
                {
                    [productDictionary setObject:[product objectForKey:kRIEventProductNameKey] forKey:kGTMEventTransactionProductNameKey];
                }
                
                if(VALID_NOTEMPTY([product objectForKey:kRIEventSkuKey], NSString))
                {
                    [productDictionary setObject:[product objectForKey:kRIEventSkuKey] forKey:kGTMEventTransactionProductSkuKey];
                }
                
                //                [productDictionary setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventTransactionProductCategoryKey];
                
                if(VALID_NOTEMPTY([product objectForKey:kRIEventPriceKey], NSString))
                {
                    [productDictionary setObject:[product objectForKey:kRIEventPriceKey] forKey:kGTMEventTransactionProductPriceKey];
                }
                
                if(VALID_NOTEMPTY([product objectForKey:kRIEventCurrencyCodeKey], NSNumber))
                {
                    [productDictionary setObject:[product objectForKey:kRIEventCurrencyCodeKey] forKey:kGTMEventTransactionProductCurrencyKey];
                }
                
                if(VALID_NOTEMPTY([product objectForKey:kRIEventQuantityKey], NSNumber))
                {
                    [productDictionary setObject:[product objectForKey:kRIEventQuantityKey] forKey:kGTMEventTransactionProductQuantityKey];
                }
                
                [productsArray addObject:productDictionary];
            }
        }
        
        if(VALID_NOTEMPTY(productsArray, NSMutableArray))
        {
            [pushedData setObject:productsArray forKey:kGTMEventTransactionProductsKey];
        }
    }
    
    [self pushEvent:pushedData];
}


#pragma mark - RITrackingTiming implementation

-(void)trackTimingInMillis:(NSNumber*)millis reference:(NSString *)reference
{
    RIDebugLog(@"GTM - Tracking timing: %lu %@", (unsigned long)millis, reference);
    
    NSMutableDictionary *pushedData = [[NSMutableDictionary alloc] init];
    [pushedData setObject:reference forKey:kGTMEventScreenNameKey];
    [pushedData setObject:millis forKey:kGTMEventLoadTimeKey];
    
    [self pushEvent:pushedData];
}

@end
