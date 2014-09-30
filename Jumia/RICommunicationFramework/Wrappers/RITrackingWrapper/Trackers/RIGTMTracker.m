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

#define kGTMEventKey                        @"event"
#define kGTMEventSourceKey                  @"source"
#define kGTMEventCampaignKey                @"campaign"
#define kGTMEventAppVersionKey              @"appVersion"
#define kGTMEventShopCountryKey             @"shopCountry"
#define kGTMEventLoginMethodKey             @"loginMethod"
#define kGTMEventLoginLocationKey           @"loginLocation"
#define kGTMEventCustomerIdKey              @"customerId"
#define kGTMEventUserAgeKey                 @"userAge"
#define kGTMEventUserGenderKey              @"userGender"
#define kGTMEventAccountCreationDateKey     @"accountCreationDate"
#define kGTMEventNumberPurchasesKey         @"numberPurchases"
#define kGTMEventRegistrationMethodKey      @"registrationMethod"
#define kGTMEventRegistrationLocationKey    @"registrationLocation"
#define kGTMEventSubscriberIdKey            @"subscriberId"
#define kGTMEventSignUpLocationKey          @"signUpLocation"
#define kGTMEventSearchTermKey              @"searchTerm"
#define kGTMEventResultsNumberKey           @"resultsNumber"
#define kGTMEventSocialNetworkKey           @"socialNetwork"
#define kGTMEventShareLocationKey           @"shareLocation"
#define kGTMEventProductSKUKey              @"productSKU"
#define kGTMEventProductCategoryKey         @"productCategory"
#define kGTMEventProductBrandKey            @"productBrand"
#define kGTMEventProductSubCategoryKey      @"productSubcategory"
#define kGTMEventProductPriceKey            @"productPrice"
#define kGTMEventCurrencyKey                @"currency"
#define kGTMEventDiscountKey                @"discount"
#define kGTMEventProductRatingKey           @"productRating"
#define kGTMEventProductQuantityKey         @"productQuantity"
#define kGTMEventLocationKey                @"location"
#define kGTMEventAverageRatingTotalKey      @"averageRatingTotal"
#define kGTMEventQuantityCartKey            @"quantityCart"
#define kGTMEventCartValueKey               @"cartValue"
#define kGTMEventRatingPriceKey             @"ratingPrice"
#define kGTMEventRatingAppearanceKey        @"ratingAppearance"
#define kGTMEventRatingQualityKey           @"ratingQuality"

NSString * const kGTMToken = @"kGTMToken";

@interface RIGTMTracker ()

@property (nonatomic, strong) TAGManager *tagManager;
@property (nonatomic, strong) TAGContainer *container;

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
    id future =
    [TAGContainerOpener openContainerWithId:containerId   // Update with your Container ID.
                                 tagManager:self.tagManager
                                   openType:kTAGOpenTypePreferNonDefault
                                    timeout:nil];
    
    // Method calls that don't need the container.
    
    self.container = [future get];
    // Other methods calls that use this container.
}

#pragma mark - RILaunchEventTracker implementation

- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary;
{
    RIDebugLog(@"GTM - Launch event with data:%@", dataDictionary);

    // The container should have already been opened, otherwise events pushed to
    // the data layer will not fire tags in that container.
    TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
    
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
    
    [dataLayer push:pushedData];
}

#pragma mark RIEventTracking protocol

- (void)trackEvent:(NSNumber *)eventType data:(NSDictionary *)data
{
    RIDebugLog(@"GTM - Tracking event = %@, data %@", eventType, data);
    if([self.registeredEvents containsObject:eventType])
    {
        TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
        
        NSMutableDictionary *pushedData = [[NSMutableDictionary alloc] init];
        
        NSInteger eventTypeInt = [eventType integerValue];
        switch (eventTypeInt) {
            case RIEventLoginSuccess:
                [pushedData setObject:@"login" forKey:kGTMEventKey];
                [pushedData setObject:@"Email Auth" forKey:kGTMEventLoginMethodKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventLoginLocationKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLoginLocationKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventCustomerIdKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventUserIdKey] forKey:kGTMEventCustomerIdKey];
                }
                break;
            case RIEventFacebookLoginSuccess:
                [pushedData setObject:@"login" forKey:kGTMEventKey];
                [pushedData setObject:@"Facebook" forKey:kGTMEventLoginMethodKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventLoginLocationKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLoginLocationKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventCustomerIdKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventUserIdKey] forKey:kGTMEventCustomerIdKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventUserAgeKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventAgeKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventAgeKey] forKey:kGTMEventUserAgeKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventUserGenderKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventGenderKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventGenderKey] forKey:kGTMEventUserGenderKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventAccountCreationDateKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventAccountDateKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventAccountDateKey] forKey:kGTMEventAccountCreationDateKey];
                }
                break;
            case RIEventAutoLoginSuccess:
                [pushedData setObject:@"autoLogin" forKey:kGTMEventKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventCustomerIdKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventUserIdKey] forKey:kGTMEventCustomerIdKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventUserAgeKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventAgeKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventAgeKey] forKey:kGTMEventUserAgeKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventUserGenderKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventGenderKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventGenderKey] forKey:kGTMEventUserGenderKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventAccountCreationDateKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventAccountDateKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventAccountDateKey] forKey:kGTMEventAccountCreationDateKey];
                }
                break;
            case RIEventLoginFail:
                [pushedData setObject:@"loginFailed" forKey:kGTMEventKey];
                [pushedData setObject:@"Email Auth" forKey:kGTMEventLoginMethodKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventLoginLocationKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLoginLocationKey];
                }
                break;
            case RIEventFacebookLoginFail:
                [pushedData setObject:@"loginFailed" forKey:kGTMEventKey];
                [pushedData setObject:@"Facebook" forKey:kGTMEventLoginMethodKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventLoginLocationKey];
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
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventCustomerIdKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventUserIdKey] forKey:kGTMEventCustomerIdKey];
                }
                break;
            case RIEventRegisterSuccess:
            case RIEventSignupSuccess:
                [pushedData setObject:@"register" forKey:kGTMEventKey];
                [pushedData setObject:@"Email Auth" forKey:kGTMEventRegistrationMethodKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventRegistrationLocationKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventRegistrationLocationKey];
                }
                break;
            case RIEventRegisterFail:
            case RIEventSignupFail:
                [pushedData setObject:@"registerFailed" forKey:kGTMEventKey];
                [pushedData setObject:@"Email Auth" forKey:kGTMEventRegistrationMethodKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventRegistrationLocationKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventRegistrationLocationKey];
                }
                break;
            case RIEventNewsletter:
                [pushedData setObject:@"signUp" forKey:kGTMEventKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventSubscriberIdKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventUserIdKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventUserIdKey] forKey:kGTMEventSubscriberIdKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventSignUpLocationKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventSignUpLocationKey];
                }
                break;
            case RIEventSearch:
                [pushedData setObject:@"search" forKey:kGTMEventKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventSearchTermKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventKeywordsKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventKeywordsKey] forKey:kGTMEventSearchTermKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventResultsNumberKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventNumberOfProductsKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventNumberOfProductsKey] forKey:kGTMEventResultsNumberKey];
                }
                break;
            case RIEventShareEmail:
                [pushedData setObject:@"shareProduct" forKey:kGTMEventKey];
                [pushedData setObject:@"Email" forKey:kGTMEventSocialNetworkKey];
                [pushedData setObject:@"Product Page" forKey:kGTMEventShareLocationKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSKUKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductCategoryKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                break;
            case RIEventShareFacebook:
                [pushedData setObject:@"shareProduct" forKey:kGTMEventKey];
                [pushedData setObject:@"Facebook" forKey:kGTMEventSocialNetworkKey];
                [pushedData setObject:@"Product Page" forKey:kGTMEventShareLocationKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSKUKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductCategoryKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                break;
            case RIEventShareTwitter:
                [pushedData setObject:@"shareProduct" forKey:kGTMEventKey];
                [pushedData setObject:@"Twitter" forKey:kGTMEventSocialNetworkKey];
                [pushedData setObject:@"Product Page" forKey:kGTMEventShareLocationKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSKUKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductCategoryKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                break;
            case RIEventShareSMS:
                [pushedData setObject:@"shareProduct" forKey:kGTMEventKey];
                [pushedData setObject:@"SMS" forKey:kGTMEventSocialNetworkKey];
                [pushedData setObject:@"Product Page" forKey:kGTMEventShareLocationKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSKUKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductCategoryKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                break;
            case RIEventShareOther:
                [pushedData setObject:@"shareProduct" forKey:kGTMEventKey];
                [pushedData setObject:@"Other" forKey:kGTMEventSocialNetworkKey];
                [pushedData setObject:@"Product Page" forKey:kGTMEventShareLocationKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSKUKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductCategoryKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                break;
            case RIEventChangeCountry:
                [pushedData setObject:@"changeCountry" forKey:kGTMEventKey];

                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventShopCountryKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventShopCountryKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventShopCountryKey] forKey:kGTMEventShopCountryKey];
                }
                break;
            case RIEventViewProduct:
                [pushedData setObject:@"viewProduct" forKey:kGTMEventKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSKUKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventProductKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventProductKey] forKey:kGTMEventProductSKUKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductBrandKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventBrandKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventBrandKey] forKey:kGTMEventProductBrandKey];
                }

                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductPriceKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPriceKey] forKey:kGTMEventProductPriceKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventCurrencyKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCurrencyCodeKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCurrencyCodeKey] forKey:kGTMEventCurrencyKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventDiscountKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventDiscountKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventDiscountKey] forKey:kGTMEventDiscountKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductRatingKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingKey] forKey:kGTMEventProductRatingKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductCategoryKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }

                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSubCategoryKey];
                break;
            case RIEventAddToCart:
            case RIEventIncreaseQuantity:
                [pushedData setObject:@"addToCart" forKey:kGTMEventKey];
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSKUKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductBrandKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventBrandKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventBrandKey] forKey:kGTMEventProductBrandKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductPriceKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPriceKey] forKey:kGTMEventProductPriceKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductCategoryKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCategoryNameKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCategoryNameKey] forKey:kGTMEventProductCategoryKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSubCategoryKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventCurrencyKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventCurrencyCodeKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventCurrencyCodeKey] forKey:kGTMEventCurrencyKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventDiscountKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventDiscountKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventDiscountKey] forKey:kGTMEventDiscountKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductQuantityKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventQuantityKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventQuantityKey] forKey:kGTMEventProductQuantityKey];
                }

                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventLocationKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLocationKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductRatingKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingKey] forKey:kGTMEventProductRatingKey];
                }
                
                break;
            case RIEventRemoveFromCart:
            case RIEventDecreaseQuantity:
                [pushedData setObject:@"removeFromCart" forKey:kGTMEventKey];
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductSKUKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventSkuKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventSkuKey] forKey:kGTMEventProductSKUKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductPriceKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPriceKey] forKey:kGTMEventProductPriceKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductRatingKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingKey], NSNumber))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingKey] forKey:kGTMEventProductRatingKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductQuantityKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventQuantityKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventQuantityKey] forKey:kGTMEventProductQuantityKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventCartValueKey];
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
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductPriceKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventPriceKey] forKey:kGTMEventProductPriceKey];
                }

                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductBrandKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventBrandKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventBrandKey] forKey:kGTMEventProductBrandKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventProductRatingKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingKey] forKey:kGTMEventProductRatingKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventRatingPriceKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingPriceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingPriceKey] forKey:kGTMEventRatingPriceKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventRatingAppearanceKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingAppearanceKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingAppearanceKey] forKey:kGTMEventRatingAppearanceKey];
                }
                
                [pushedData setObject:kTAGDataLayerObjectNotPresent forKey:kGTMEventRatingQualityKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventRatingQualityKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventRatingQualityKey] forKey:kGTMEventRatingQualityKey];
                }
                
                break;
        }

        [dataLayer push:pushedData];
    }
}

@end
