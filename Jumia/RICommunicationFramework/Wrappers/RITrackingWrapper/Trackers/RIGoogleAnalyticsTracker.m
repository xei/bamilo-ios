//
//  RIGoogleAnalyticsTracker.m
//  RITracking
//
//  Created by Martin Biermann on 13/03/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

// Requires Frameworks:
//
// libGoogleAnalyticsServices.a
// AdSupport.framework
// CoreData.framework
// SystemConfiguration.framework
// libz.dylib

#import "RIGoogleAnalyticsTracker.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAILogger.h"
#import "RICountryConfiguration.h"

NSString * const kRIGoogleAnalyticsTrackingID = @"RIGoogleAnalyticsTrackingID";

@interface RIGoogleAnalyticsTracker ()

@property (nonatomic, strong) NSString *campaignData;

// Used for sending Google Analytics traffic in the background.
@property(nonatomic, assign) BOOL okToWait;
@property(nonatomic, copy) void (^dispatchHandler)(GAIDispatchResult result);

@end

@implementation RIGoogleAnalyticsTracker

@synthesize queue;
@synthesize registeredEvents;

static RIGoogleAnalyticsTracker *sharedInstance;

- (id)init
{
    NSLog(@"Initializing Google Analytics tracker");
    
    if ((self = [super init]))
    {
        self.campaignData = @"";
        
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        
        NSMutableArray *events = [[NSMutableArray alloc] init];
        [events addObject:[NSNumber numberWithInt:RIEventAutoLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventAutoLoginFail]];
        [events addObject:[NSNumber numberWithInt:RIEventLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventLoginFail]];
        [events addObject:[NSNumber numberWithInt:RIEventRegisterSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventRegisterFail]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookLoginSuccess]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookLoginFail]];
        [events addObject:[NSNumber numberWithInt:RIEventLogout]];
        [events addObject:[NSNumber numberWithInt:RIEventSideMenu]];
        [events addObject:[NSNumber numberWithInt:RIEventCategories]];
        [events addObject:[NSNumber numberWithInt:RIEventCatalog]];
        [events addObject:[NSNumber numberWithInt:RIEventFilter]];
        [events addObject:[NSNumber numberWithInt:RIEventSort]];
        [events addObject:[NSNumber numberWithInt:RIEventViewProduct]];
        [events addObject:[NSNumber numberWithInt:RIEventRelatedItem]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToCart]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventRateProduct]];
        [events addObject:[NSNumber numberWithInt:RIEventSearch]];
        [events addObject:[NSNumber numberWithInt:RIEventShareFacebook]];
        [events addObject:[NSNumber numberWithInt:RIEventShareTwitter]];
        [events addObject:[NSNumber numberWithInt:RIEventShareEmail]];
        [events addObject:[NSNumber numberWithInt:RIEventShareSMS]];
        [events addObject:[NSNumber numberWithInt:RIEventShareOther]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutStart]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutAboutYou]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutAddresses]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutShipping]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutPayment]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutOrder]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutEnd]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutContinueShopping]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckoutError]];
        [events addObject:[NSNumber numberWithInt:RIEventNewsletter]];
        [events addObject:[NSNumber numberWithInt:RIEventViewCampaign]];

        self.registeredEvents = [events copy];
    }
    return self;
}

+ (void)initGATrackerWithId:(NSString*)trackingId
{
    if (!trackingId) {
        RIRaiseError(@"Missing Google Analytics Tracking ID in tracking properties");
        return;
    }
    
    // Automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Dispatch tracking information every 5 seconds (default: 120)
    [GAI sharedInstance].dispatchInterval = 5;
    
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelNone];// kGAILogLevelVerbose];
    
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:trackingId];
        
    // Setup the app version
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [[GAI sharedInstance].defaultTracker set:kGAIAppVersion value:version];
    
    [[GAI sharedInstance].defaultTracker setAllowIDFACollection:YES];
    
    NSLog(@"Initialized Google Analytics %d", [GAI sharedInstance].trackUncaughtExceptions);
}

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.okToWait = YES;
    __weak RIGoogleAnalyticsTracker *weakSelf = self;
    __block UIBackgroundTaskIdentifier backgroundTaskId =
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        weakSelf.okToWait = NO;
    }];
    
    if (backgroundTaskId == UIBackgroundTaskInvalid) {
        return;
    }
    
    self.dispatchHandler = ^(GAIDispatchResult result) {
        // If the last dispatch succeeded, and we're still OK to stay in the background then kick off
        // again.
        if (result == kGAIDispatchGood && weakSelf.okToWait ) {
            [[GAI sharedInstance] dispatchWithCompletionHandler:weakSelf.dispatchHandler];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    };
    [[GAI sharedInstance] dispatchWithCompletionHandler:self.dispatchHandler];
}

#pragma mark - Track campaign

- (void)trackCampaignWithName:(NSString *)campaignName
{
    RIDebugLog(@"Google Analytics tracker tracks campaign");
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!ISEMPTY(tracker))
    {
        if(VALID_NOTEMPTY(campaignName, NSString))
        {
            self.campaignData = [NSString stringWithFormat:@"http://www.google.com?utm_campaign=%@&utm_source=push&utm_medium=referrer", campaignName];
        }
    }
    else
    {
        RIDebugLog(@"Missing default Google Analytics tracker");
    }
}

#pragma mark - RIExceptionTracking protocol

- (void)trackExceptionWithName:(NSString *)name
{
    RIDebugLog(@"Google Analytics tracker tracks exception with name '%@'", name);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!ISEMPTY(tracker))
    {
        NSDictionary *dict = [[GAIDictionaryBuilder createExceptionWithDescription:name
                                                                         withFatal:[NSNumber numberWithBool:NO]] build];
        
        [tracker send:dict];
    }
    else
    {
        RIDebugLog(@"Missing default Google Analytics tracker");
    }
}

#pragma mark - RIScreenTracking

-(void)trackScreenWithName:(NSString *)name
{
    RIDebugLog(@"Google Analytics - Tracking screen with name: %@", name);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!ISEMPTY(tracker))
    {
        [tracker set:kGAIScreenName value:name];
        [tracker send:[[[GAIDictionaryBuilder createAppView] setCampaignParametersFromUrl:self.campaignData] build]];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
    else
    {
        RIDebugLog(@"Missing default Google Analytics tracker");
    }
}

#pragma mark - RIEventTracking

-(void)trackEvent:(NSNumber*)eventType data:(NSDictionary *)data
{
    RIDebugLog(@"Google Analytics - Tracking event: %@", eventType);
    
    if([self.registeredEvents containsObject:eventType])
    {
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        if (!ISEMPTY(tracker))
        {
            if(ISEMPTY(data))
            {
                RIRaiseError(@"Missing event data");
                return;
            }
            
            NSString *category = [data objectForKey:kRIEventCategoryKey];
            NSString *action = [data objectForKey:kRIEventActionKey];
            NSString *label = [data objectForKey:kRIEventLabelKey];
            NSNumber *value = [data objectForKey:kRIEventValueKey];
            
            NSDictionary *dict = [[[GAIDictionaryBuilder createEventWithCategory:category
                                                                          action:action
                                                                           label:label
                                                                           value:value]
                                   setCampaignParametersFromUrl:self.campaignData] build];
            [tracker send:dict];
        }
        else
        {
            RIDebugLog(@"Missing default Google Analytics tracker");
        }
    }
}

#pragma mark - RIEcommerceEventTracking

-(void)trackCheckout:(NSDictionary *)data
{
    RIDebugLog(@"Google Analytics - Tracking checkout with transaction id: %@", data);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!ISEMPTY(tracker))
    {
        NSString *transactionId = [data objectForKey:kRIEcommerceTransactionIdKey];
        NSNumber *tax = [data objectForKey:kRIEcommerceTaxKey];
        NSNumber *shipping = [data objectForKey:kRIEcommerceShippingKey];
        NSString *currency = [data objectForKey:kRIEcommerceCurrencyKey];
        NSNumber *revenue = [data objectForKey:kRIEcommerceTotalValueKey];
        
        GAIDictionaryBuilder *dict = [GAIDictionaryBuilder createTransactionWithId:transactionId
                                                                       affiliation:@"In-App Store"
                                                                           revenue:revenue
                                                                               tax:tax
                                                                          shipping:shipping
                                                                      currencyCode:currency];
        [tracker send:[[dict setCampaignParametersFromUrl:self.campaignData] build]];
        
        if ([data objectForKey:kRIEcommerceProducts])
        {
            NSArray *tempArray = [data objectForKey:kRIEcommerceProducts];
            
            for (NSDictionary *tempProduct in tempArray)
            {
                GAIDictionaryBuilder *productDict = [GAIDictionaryBuilder createItemWithTransactionId:[data objectForKey:kRIEcommerceTransactionIdKey]
                                                                                                 name:[tempProduct objectForKey:kRIEventProductNameKey]
                                                                                                  sku:[tempProduct objectForKey:kRIEventSkuKey]
                                                                                             category:nil
                                                                                                price:[tempProduct objectForKey:kRIEventPriceKey]
                                                                                             quantity:[tempProduct objectForKey:kRIEventQuantityKey]
                                                                                         currencyCode:[tempProduct objectForKey:kRIEventCurrencyCodeKey]];
                [tracker send:[[productDict setCampaignParametersFromUrl:self.campaignData] build]];
            }
        }
    }
    else
    {
        RIDebugLog(@"Missing default Google Analytics tracker");
    }
}

#pragma mark - RITrackingTiming implementation

-(void)trackTimingInMillis:(NSNumber*)millis reference:(NSString *)reference
{
    RIDebugLog(@"Google Analytics - Tracking timing: %lu %@", (unsigned long)millis, reference);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!ISEMPTY(tracker))
    {
        NSDictionary *dict = [[[GAIDictionaryBuilder createTimingWithCategory:reference
                                                                     interval:millis
                                                                         name:nil
                                                                        label:nil]
                               setCampaignParametersFromUrl:self.campaignData] build];
        
        [tracker send:dict];
    }
    else
    {
        RIDebugLog(@"Missing default Google Analytics tracker");
    }
}

//#pragma mark - RILaunchEventTracker implementation
//
//- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary;
//{
//    RIDebugLog(@"Google Analytics - Launch event with data:%@", dataDictionary);
//    
//    id tracker = [[GAI sharedInstance] defaultTracker];
//    if (!tracker) {
//        RIRaiseError(@"Missing default Google Analytics tracker");
//        return;
//    }
//    
//    //$$$ WHAT TO SEND
//    NSDictionary *dict = [[GAIDictionaryBuilder createEventWithCategory:nil
//                                                                 action:kRILaunchEventKey
//                                                                  label:nil
//                                                                  value:nil] build];
//    [tracker send:dict];
//}

@end
