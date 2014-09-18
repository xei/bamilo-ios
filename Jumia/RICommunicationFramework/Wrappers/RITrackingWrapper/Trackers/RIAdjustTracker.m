//
//  RIAdjustTracker.m
//  Jumia
//
//  Created by Pedro Lopes on 18/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIAdjustTracker.h"
#import "Adjust.h"

NSString * const kRIAdjustToken = @"kRIAdjustToken";

@implementation RIAdjustTracker

@synthesize queue;

- (id)init
{
    NSLog(@"Initializing BugSense tracker");
    
    if ((self = [super init])) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark - RITracker protocol

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options
{
    RIDebugLog(@"BugSense tracker tracks application launch");
    
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
    
}

@end
