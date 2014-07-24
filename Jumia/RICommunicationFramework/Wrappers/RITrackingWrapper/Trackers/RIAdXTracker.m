//
//  RIAdXTracker.m
//  RITracking
//
//  Created by Miguel Chaves on 20/Mar/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

#import "RIAdXTracker.h"
#import "AdXTracking.h"

NSString * const kRIAdXiPhoneBundleId = @"kRIAdXiPhoneBundleId";
NSString * const kRIAdXiPadBundleId = @"kRIAdXiPadBundleId";
NSString * const kRIAdXURLScheme = @"kRIAdXURLScheme";
NSString * const kRIAdXClientId = @"kRIAdXClientId";
NSString * const kRIAdXAppleId = @"kRIAdXAppleId";

static AdXTracking *adXTracker;
static dispatch_once_t adXTrackerInstanceToken;

@implementation RIAdXTracker

@synthesize queue;

- (id)init
{
    NSLog(@"Initializing AdX tracker");
    
    if ((self = [super init])) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        
        dispatch_once(&adXTrackerInstanceToken, ^{
            adXTracker = [[AdXTracking alloc] init];
        });
    }
    return self;
}

#pragma mark - RITracker protocol

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options
{
    RIDebugLog(@"AdX tracker tracks application launch");
    
    NSString *clientId = [RITrackingConfiguration valueForKey:kRIAdXClientId];
    NSString *iphoneBundleId = [RITrackingConfiguration valueForKey:kRIAdXiPhoneBundleId];
    NSString *ipadBundleId = [RITrackingConfiguration valueForKey:kRIAdXiPadBundleId];
    NSString *urlScheme = [RITrackingConfiguration valueForKey:kRIAdXURLScheme];
    NSString *appleId = [RITrackingConfiguration valueForKey:kRIAdXAppleId];
    
    if (!clientId) {
        RIRaiseError(@"Missing AdX client key in tracking properties")
        return;
    }
    
    if ((!iphoneBundleId) || (!ipadBundleId)) {
        RIRaiseError(@"Missing AdX bundle ID key in tracking properties")
        return;
    }

    if (!urlScheme) {
        RIRaiseError(@"Missing URL Scheme key in tracking properties")
        return;
    }
    
    if (!appleId) {
        RIRaiseError(@"Missing Apple ID key in tracking properties")
        return;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [adXTracker setBundleID:ipadBundleId];
    } else {
        [adXTracker setBundleID:iphoneBundleId];
    }
    
    [adXTracker setURLScheme:urlScheme];
    [adXTracker setClientId:clientId];
    [adXTracker setAppleId:appleId];
}

#pragma mark - RIEventTracking

-(void)trackEvent:(NSString *)event
            value:(NSNumber *)value
           action:(NSString *)action
         category:(NSString *)category
             data:(NSDictionary *)data
{
    RIDebugLog(@"AdXTracker - Tracking event: %@", event);
    
    if (!adXTracker) {
        RIRaiseError(@"Missing default AdX tracker");
        return;
    }

    [adXTracker sendEvent:event
                 withData:action];
}

#pragma mark - RIEcommerceTraking

- (void)trackProductAddToCart:(RITrackingProduct *)product
{
    RIDebugLog(@"AdXTracker - Tracking product added to cart: %@", product.name);
    
    if (!adXTracker) {
        RIRaiseError(@"Missing default AdX tracker");
        return;
    }
    
    [adXTracker sendEvent:@"AddToCart"
                 withData:product.name
              andCurrency:product.currency
            andCustomData:product.category];
}

-(void)trackRemoveFromCartForProductWithID:(NSString *)idTransaction quantity:(NSNumber *)quantity
{
    RIDebugLog(@"AdXTracker - Tracking product removed from cart");
    
    if (!adXTracker) {
        RIRaiseError(@"Missing default AdX tracker");
        return;
    }
    
    [adXTracker sendEvent:@"RemoveFromCart" withData:idTransaction];
}

-(void)trackCheckoutWithTransactionId:(NSString *)idTransaction total:(RITrackingTotal *)total
{
    RIDebugLog(@"AdXTracker - Tracking checkout");
    
    if (!adXTracker) {
        RIRaiseError(@"Missing default AdX tracker");
        return;
    }
    
    [adXTracker sendEvent:@"CheckOut"
                 withData:idTransaction
              andCurrency:total.currency
            andCustomData:[NSString stringWithFormat:@"%@", total.net]];
}

@end
