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

@implementation RIGoogleAnalyticsTracker

@synthesize queue;
@synthesize registeredEvents;

static RIGoogleAnalyticsTracker *sharedInstance;
static dispatch_once_t sharedInstanceToken;

- (id)init
{
    NSLog(@"Initializing Google Analytics tracker");
    
    if ((self = [super init])) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        
        NSMutableArray *events = [[NSMutableArray alloc] init];
        [events addObject:[NSNumber numberWithInt:RIEventAutoLogin]];
        [events addObject:[NSNumber numberWithInt:RIEventLogin]];
        [events addObject:[NSNumber numberWithInt:RIEventRegister]];
        [events addObject:[NSNumber numberWithInt:RIEventFacebookLogin]];
        [events addObject:[NSNumber numberWithInt:RIEventLogout]];
        [events addObject:[NSNumber numberWithInt:RIEventSideMenu]];
        [events addObject:[NSNumber numberWithInt:RIEventCategories]];
        [events addObject:[NSNumber numberWithInt:RIEventCatalog]];
        [events addObject:[NSNumber numberWithInt:RIEventFilter]];
        [events addObject:[NSNumber numberWithInt:RIEventSort]];
        [events addObject:[NSNumber numberWithInt:RIEventViewProductDetails]];
        [events addObject:[NSNumber numberWithInt:RIEventRelatedItem]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToCart]];
        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromCart]];
        [events addObject:[NSNumber numberWithInt:RIEventAddToWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromWishlist]];
        [events addObject:[NSNumber numberWithInt:RIEventRateProduct]];
        [events addObject:[NSNumber numberWithInt:RIEventSearch]];
        [events addObject:[NSNumber numberWithInt:RIEventShare]];
        [events addObject:[NSNumber numberWithInt:RIEventCheckout]];
        self.registeredEvents = [events copy];
    }
    return self;
}

//+ (instancetype)sharedInstance
//{
//    dispatch_once(&sharedInstanceToken, ^{
//        sharedInstance = [[RIGoogleAnalyticsTracker alloc] init];
//        
//        RIDebugLog(@"Google Analytics tracker tracks application launch");
//    });
//    
//    return sharedInstance;
//}

+ (void)initGATrackerWithCountryConfiguration:(RICountryConfiguration *)config
{
    NSString *trackingId = config.gaId;
    
    if (!trackingId) {
        RIRaiseError(@"Missing Google Analytics Tracking ID in tracking properties");
        return;
    }
    
    // Automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Dispatch tracking information every 5 seconds (default: 120)
    [GAI sharedInstance].dispatchInterval = 5;
    
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:trackingId];
    
    // Setup the app version
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [[GAI sharedInstance].defaultTracker set:kGAIAppVersion value:version];
    
    NSLog(@"Initialized Google Analytics %d", [GAI sharedInstance].trackUncaughtExceptions);
}

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options
{

}

#pragma mark - Track campaign

- (void)trackCampaingWithData:(NSDictionary *)data
{
    RIDebugLog(@"Google Analytics tracker tracks campaign");
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    NSDictionary *dict = [[[GAIDictionaryBuilder createAppView] setAll:data] build];
    
    [tracker send:dict];
}

#pragma mark - RIExceptionTracking protocol

- (void)trackExceptionWithName:(NSString *)name
{
    RIDebugLog(@"Google Analytics tracker tracks exception with name '%@'", name);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    NSDictionary *dict = [[GAIDictionaryBuilder createExceptionWithDescription:name
                                                                     withFatal:NO] build];
    
    [tracker send:dict];
}

#pragma mark - RIScreenTracking

-(void)trackScreenWithName:(NSString *)name
{
    RIDebugLog(@"Google Analytics - Tracking screen with name: %@", name);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    [tracker set:kGAIScreenName value:name];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

#pragma mark - RIEventTracking

-(void)trackEvent:(NSNumber*)eventType data:(NSDictionary *)data
{
    RIDebugLog(@"Google Analytics - Tracking event: %@", eventType);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    if(ISEMPTY(data))
    {
        RIRaiseError(@"Missing event data");
        return;
    }
    
    if([self.registeredEvents containsObject:eventType])
    {
        NSLog(@"Google Analytics - Event registered");
        
        NSString *category = [data objectForKey:kRIEventCategoryKey];
        NSString *action = [data objectForKey:kRIEventActionKey];
        NSString *label = [data objectForKey:kRIEventLabelKey];
        NSNumber *value = [data objectForKey:kRIEventValueKey];
        
        NSDictionary *dict = [[GAIDictionaryBuilder createEventWithCategory:category
                                                                     action:action
                                                                      label:label
                                                                      value:value] build];
        [tracker send:dict];
    }
    else
    {
        NSLog(@"Google Analytics - Event not registered");
    }
}

#pragma mark - RIEcommerceEventTracking

-(void)trackCheckoutWithTransactionId:(NSString *)idTransaction
                                total:(RITrackingTotal *)total
{
    RIDebugLog(@"Google Analytics - Tracking checkout with transaction id: %@", idTransaction);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    NSDictionary *dict = [[GAIDictionaryBuilder createTransactionWithId:idTransaction
                                                            affiliation:nil
                                                                revenue:nil
                                                                    tax:total.tax
                                                               shipping:total.shipping
                                                           currencyCode:total.currency] build];
    
    [tracker send:dict];
}

-(void)trackProductAddToCart:(RITrackingProduct *)product
{
    RIDebugLog(@"Google Analytics - Tracking product added to cart: %@", product.name);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    NSDictionary *dict = [[GAIDictionaryBuilder createItemWithTransactionId:nil
                                                                       name:product.name
                                                                        sku:product.identifier
                                                                   category:product.category
                                                                      price:product.price
                                                                   quantity:product.quantity
                                                               currencyCode:product.currency] build];
    
    [tracker send:dict];
}

-(void)trackRemoveFromCartForProductWithID:(NSString *)idTransaction
                                  quantity:(NSNumber *)quantity
{

}

#pragma mark - RITrackingTiming implementation

-(void)trackTimingInMillis:(NSUInteger)millis reference:(NSString *)reference
{
    RIDebugLog(@"Google Analytics - Tracking timing: %lu %@", (unsigned long)millis, reference);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    NSDictionary *dict = [[GAIDictionaryBuilder createTimingWithCategory:reference
                                                                interval:[NSNumber numberWithInteger:millis]
                                                                    name:nil
                                                                   label:nil] build];
    
    [tracker send:dict];
}

#pragma mark - RILaunchEventTracker implementation

- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary;
{
    RIDebugLog(@"Google Analytics - Launch event with data:%@", dataDictionary);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    if (!tracker) {
        RIRaiseError(@"Missing default Google Analytics tracker");
        return;
    }
    
    //$$$ WHAT TO SEND
    NSDictionary *dict = [[GAIDictionaryBuilder createEventWithCategory:nil
                                                                 action:kRILaunchEventKey
                                                                  label:nil
                                                                  value:nil] build];
    [tracker send:dict];
}

@end
