//
//  RINewRelicTracker.m
//  Jumia
//
//  Created by Pedro Lopes on 18/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RINewRelicTracker.h"

NSString * const kRINewRelicTokenAPIKey = @"RINewRelicTokenAPIKey";

@implementation RINewRelicTracker

@synthesize queue;

- (id)init
{
    NSLog(@"Initializing NewRelic tracker");
    
    if ((self = [super init])) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark - RITracker protocol

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options
{
    RIDebugLog(@"NewRelic tracker tracks application launch");
    
    NSString *apiKey = [RITrackingConfiguration valueForKey:kRINewRelicTokenAPIKey];
    
    if (!apiKey) {
        RIRaiseError(@"Missing NewRelic API key in tracking properties")
        return;
    }
    
    [NewRelicAgent startWithApplicationToken:apiKey];
}

@end
