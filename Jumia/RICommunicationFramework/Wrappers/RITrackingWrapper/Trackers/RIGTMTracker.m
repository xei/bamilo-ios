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
                [pushedData setObject:@"Email Auth" forKey:kGTMEventLoginMethodKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLoginLocationKey];
                }
                break;
            case RIEventRegisterFail:
            case RIEventSignupFail:
                [pushedData setObject:@"registerFailed" forKey:kGTMEventKey];
                [pushedData setObject:@"Email Auth" forKey:kGTMEventLoginMethodKey];
                if(VALID_NOTEMPTY([data objectForKey:kRIEventLocationKey], NSString))
                {
                    [pushedData setObject:[data objectForKey:kRIEventLocationKey] forKey:kGTMEventLoginLocationKey];
                }
                break;
        }

        [dataLayer push:pushedData];
    }
}

@end
