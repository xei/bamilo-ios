//
//  RITrackingProperties.m
//  RITracking
//
//  Created by Martin Biermann on 14/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import "RITrackingConfiguration.h"
#import "RITrackingWrapper.h"

@interface RITrackingConfiguration ()

@property NSDictionary *properties;

@end

@implementation RITrackingConfiguration

static RITrackingConfiguration* sharedInstance;
static dispatch_once_t sharedInstanceToken;

+ (instancetype)sharedInstance
{
    dispatch_once(&sharedInstanceToken, ^{
        sharedInstance = [[RITrackingConfiguration alloc] init];
    });
    return sharedInstance;
}

+ (id)valueForKey:(NSString *)key
{
    return [RITrackingConfiguration sharedInstance].properties[key];
}

+ (BOOL)loadFromPropertyListAtPath:(NSString *)path
{
    // Clear old values to avoid stale information
    [RITrackingConfiguration sharedInstance].properties = nil;
    
    NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if (!properties) {
        RIRaiseError(@"Missing properties when loading property file at path '%@'", path);
        return NO;
    }
    
    [RITrackingConfiguration sharedInstance].properties = properties;
    
    return YES;
}

#pragma mark - Hidden test helpers

+ (void)clear
{
    sharedInstance = nil;
    sharedInstanceToken = 0;
}

@end
