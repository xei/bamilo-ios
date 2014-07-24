//
//  RIBugSenseTracker.m
//  RITracking
//
//  Created by Martin Biermann on 13/03/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

#import "RIBugSenseTracker.h"
#import <BugSense-iOS/BugSenseController.h>

NSString * const kRIBugsenseAPIKey = @"RIBugsenseAPIKey";

@implementation RIBugSenseTracker

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
    
    NSString *apiKey = [RITrackingConfiguration valueForKey:kRIBugsenseAPIKey];
    
    if (!apiKey) {
        RIRaiseError(@"Missing Bugsense API key in tracking properties")
        return;
    }
    
    [BugSenseController sharedControllerWithBugSenseAPIKey:apiKey];
}

#pragma mark - RIExceptionTracking protocol

- (void)trackExceptionWithName:(NSString *)name
{
    RIDebugLog(@"BugSense tracker tracks exception with name '%@'", name);
    
    BOOL result = [BugSenseController logException:nil withExtraData:@{@"name": name}];
    
    if (!result) {
        RIRaiseError(@"Unexpected negative result on logging exception with name: %@", name);
    }
}

@end
