//
//  RIAdjustTracker.m
//  Jumia
//
//  Created by Pedro Lopes on 18/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIAdjustTracker.h"

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
//        [events addObject:[NSNumber numberWithInt:RIEventAutoLogin]];
//        [events addObject:[NSNumber numberWithInt:RIEventLogin]];
//        [events addObject:[NSNumber numberWithInt:RIEventRegister]];
//        [events addObject:[NSNumber numberWithInt:RIEventFacebookLogin]];
//        [events addObject:[NSNumber numberWithInt:RIEventLogout]];
//        [events addObject:[NSNumber numberWithInt:RIEventSideMenu]];
//        [events addObject:[NSNumber numberWithInt:RIEventCategories]];
//        [events addObject:[NSNumber numberWithInt:RIEventCatalog]];
//        [events addObject:[NSNumber numberWithInt:RIEventFilter]];
//        [events addObject:[NSNumber numberWithInt:RIEventSort]];
//        [events addObject:[NSNumber numberWithInt:RIEventViewProductDetails]];
//        [events addObject:[NSNumber numberWithInt:RIEventRelatedItem]];
//        [events addObject:[NSNumber numberWithInt:RIEventAddToCart]];
//        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromCart]];
//        [events addObject:[NSNumber numberWithInt:RIEventAddToWishlist]];
//        [events addObject:[NSNumber numberWithInt:RIEventRemoveFromWishlist]];
//        [events addObject:[NSNumber numberWithInt:RIEventRateProduct]];
//        [events addObject:[NSNumber numberWithInt:RIEventSearch]];
//        [events addObject:[NSNumber numberWithInt:RIEventShare]];
//        [events addObject:[NSNumber numberWithInt:RIEventCheckout]];
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
    }
    else
    {
        NSLog(@"Adjust - Event not registered");
    }
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
