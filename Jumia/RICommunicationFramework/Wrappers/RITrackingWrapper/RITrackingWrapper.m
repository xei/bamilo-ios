//
//  RITrackingWrapper.m
//  RITrackingWrapper
//
//  Created by Miguel Chaves on 15/07/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

#import "RITrackingWrapper.h"
#import "RIGoogleAnalyticsTracker.h"
#import "RIBugSenseTracker.h"
#import "RIOpenURLHandler.h"
#import "RIAd4PushTracker.h"
#import "RINewRelicTracker.h"
#import "RIAdjustTracker.h"
#import "RIGTMTracker.h"

@interface RITrackingWrapper ()

@property NSArray *trackers;
@property NSMutableArray *handlers;
@property int productCount;

@end

@implementation RITrackingWrapper

static RITrackingWrapper *sharedInstance;
static dispatch_once_t sharedInstanceToken;

+ (instancetype)sharedInstance
{
    dispatch_once(&sharedInstanceToken, ^{
        sharedInstance = [[RITrackingWrapper alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)initWithTrackers:(NSArray *)trackers
{
    if ((self = [super init])) {
        self.handlers = [NSMutableArray array];
        self.cartState = RICartEmpty;
        self.productCount = 0;
    }
    return self;
}

- (void)setDebug:(BOOL)debug
{
    _debug = debug;
    
    NSLog(@"RITracking: Debug mode %@", debug ? @"ON" : @"OFF");
}

- (void)startWithConfigurationFromPropertyListAtPath:(NSString *)path
                                       launchOptions:(NSDictionary *)launchOptions
{
    RIDebugLog(@"Starting initialisation with launch options '%@' and property list at path '%@'",
               launchOptions, path);
    
    BOOL loaded = [RITrackingConfiguration loadFromPropertyListAtPath:path];
    
    if (!loaded) {
        RIRaiseError(@"Unexpected error occurred when loading tracking configuration from property "
                     @"list file at path '%@'", path);
        return;
    }
    
    RIGoogleAnalyticsTracker *googleAnalyticsTracker = [[RIGoogleAnalyticsTracker alloc] init];
    RIBugSenseTracker *bugsenseTracker = [[RIBugSenseTracker alloc] init];
    RIAd4PushTracker *ad4PushTracker = [[RIAd4PushTracker alloc] init];
    RINewRelicTracker *newRelicTracker = [[RINewRelicTracker alloc] init];
    RIAdjustTracker *adjustTracker = [[RIAdjustTracker alloc] init];
    RIGTMTracker *gtmTracker = [[RIGTMTracker alloc] init];
    
    self.trackers = @[googleAnalyticsTracker, bugsenseTracker, ad4PushTracker, newRelicTracker, adjustTracker, gtmTracker];
    
    if(VALID_NOTEMPTY(launchOptions, NSDictionary))
    {
        [self RI_callTrackersConformToProtocol:@protocol(RITracker)
                                      selector:@selector(applicationDidLaunchWithOptions:)
                                     arguments:@[launchOptions]];
    }
    else
    {
        [self RI_callTrackersConformToProtocol:@protocol(RITracker)
                                      selector:@selector(applicationDidLaunchWithOptions:)
                                     arguments:nil];
    }
}

- (RICartState)getCartState
{
    return self.cartState;
}

#pragma mark - RIEventTracking protocol

- (void)trackEvent:(NSNumber* )eventType
              data:(NSDictionary *)data
{
    RIDebugLog(@"Tracking event: '%@' with data: %@", eventType, data);
    
    [self RI_callTrackersConformToProtocol:@protocol(RIEventTracking)
                                  selector:@selector(trackEvent:data:)
                                 arguments:[NSArray arrayWithObjects:eventType, data, nil]];
}

#pragma mark - RIExceptionTracking protocolx

- (void)trackExceptionWithName:(NSString *)name
{
    RIDebugLog(@"Tracking exception with name '%@'", name);
    
    [self RI_callTrackersConformToProtocol:@protocol(RIExceptionTracking)
                                  selector:@selector(trackExceptionWithName:)
                                 arguments:@[name]];
}

#pragma mark - RIOpenURLTracking protocol

- (void)registerHandler:(void (^)(NSDictionary *))handlerBlock forOpenURLPattern:(NSString *)pattern
{
    RIDebugLog(@"Registering handler for deeplink URL match pattern '%@'", pattern);
    
    NSError *error;
    NSArray *matches;
    NSMutableArray *macros = [NSMutableArray array];
    
    while (YES) {
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"\\{([^\\}]+)\\}"
                                      options:0
                                      error:&error];
        
        if (error) {
            RIRaiseError(@"Unexpected error when registering open URL handler "
                         @"for pattern '%@': %@", pattern, error);
            return;
        }
        
        matches = [regex matchesInString:pattern
                                 options:0
                                   range:NSMakeRange(0, pattern.length)];
        
        if (0 == matches.count) break;
        
        NSRange macroRange = [matches[0] rangeAtIndex:1];
        NSRange range = [matches[0] rangeAtIndex:0];
        NSString *macro = [pattern substringWithRange:macroRange];
        
        [macros addObject:macro];
        pattern = [pattern stringByReplacingCharactersInRange:range withString:@"(.*)"];
    }
    
    RIDebugLog(@"Deeplink handler pattern captures macros '%@'", macros);
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:&error];
    
    if (error) {
        RIRaiseError(@"Unexpected error when creating regular expression with pattern '%@'",
                     pattern);
        return;
    }
    
    RIOpenURLHandler *handler = [[RIOpenURLHandler alloc] initWithHandlerBlock:handlerBlock
                                                                         regex:regex
                                                                        macros:macros];
    
    [self.handlers addObject:handler];
}

- (void)trackOpenURL:(NSURL *)url
{
    RIDebugLog(@"Tracking deepling with URL '%@'", url);
    
    for (RIOpenURLHandler *handler in self.handlers) {
        [handler handleOpenURL:url];
    }
    
    [self RI_callTrackersConformToProtocol:@protocol(RIOpenURLTracking)
                                  selector:@selector(trackOpenURL:)
                                 arguments:@[url]];
}

#pragma mark - RIScreenTracking protocol

- (void)trackScreenWithName:(NSString *)name
{
    RIDebugLog(@"Tracking screen with name: '%@'", name);
    
    [self RI_callTrackersConformToProtocol:@protocol(RIScreenTracking)
                                  selector:@selector(trackScreenWithName:)
                                 arguments:@[name]];
}

#pragma mark - RINotificationTracking protocol

- (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    RIDebugLog(@"Application did register for remote notification");
    
    
    [self RI_callTrackersConformToProtocol:@protocol(RINotificationTracking)
                                  selector:@selector(applicationDidRegisterForRemoteNotificationsWithDeviceToken:) arguments:@[deviceToken]];
}

- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo
{
    RIDebugLog(@"Application did receive an remote notification: %@", userInfo);
    
    [self RI_callTrackersConformToProtocol:@protocol(RINotificationTracking)
                                  selector:@selector(applicationDidReceiveRemoteNotification:)
                                 arguments:@[userInfo]];
}

- (void)applicationDidReceiveLocalNotification:(UILocalNotification *)notification
{
    RIDebugLog(@"Application did receive a local notification: %@", notification);
    
    [self RI_callTrackersConformToProtocol:@protocol(RINotificationTracking)
                                  selector:@selector(applicationDidReceiveLocalNotification:)
                                 arguments:@[notification]];
}

- (void)handlePushNotifcation:(NSDictionary *)info
{
    RIDebugLog(@"Handling push notification with info '%@'", info);
    
    [self RI_callTrackersConformToProtocol:@protocol(RINotificationTracking)
                                  selector:@selector(handlePushNotifcation:)
                                 arguments:@[info]];
}

#pragma mark - RIEcommerceTracking protocol

- (void)trackCheckout:(NSDictionary *)data
{
    RIDebugLog(@"Tracking checkout with data: %@", data);
    
    [self RI_callTrackersConformToProtocol:@protocol(RIEcommerceEventTracking)
                                  selector:@selector(trackCheckout:)
                                 arguments:@[data]];
}

#pragma mark - RITrackingTiming protocol

-(void)trackTimingInMillis:(NSNumber*)millis reference:(NSString *)reference
{
    RIDebugLog(@"Tracking timing: %lu %@", (unsigned long)millis, reference);
    
    [self RI_callTrackersConformToProtocol:@protocol(RITrackingTiming)
                                  selector:@selector(trackTimingInMillis:reference:)
                                 arguments:@[millis,
                                             reference]];
}

#pragma mark - RILaunchEventTracker protocol

- (void)sendLaunchEventWithData:(NSDictionary *)dataDictionary;
{
    RIDebugLog(@"Tracking launch event with data '%@'", dataDictionary);
    
    if (!self.trackers) {
        RIRaiseError(@"Invalid call with non-existent trackers. Initialisation may have failed.");
        return;
    }
    
    [self RI_callTrackersConformToProtocol:@protocol(RILaunchEventTracker)
                                  selector:@selector(sendLaunchEventWithData:)
                                 arguments:@[dataDictionary]];
}

#pragma mark - Campaign protocol

- (void)trackCampaignWithName:(NSString *)campaignName
{
    RIDebugLog(@"Tracking campaign with name '%@'", campaignName);
    
    if (!self.trackers) {
        RIRaiseError(@"Invalid call with non-existent trackers. Initialisation may have failed.");
        return;
    }
    
    [self RI_callTrackersConformToProtocol:@protocol(RICampaignTracker)
                                  selector:@selector(trackCampaignWithName:)
                                 arguments:@[campaignName]];
}

#pragma mark - Private methods

- (void)RI_callTrackersConformToProtocol:(Protocol *)protocol
                                selector:(SEL)selector
                               arguments:(NSArray *)arguments;
{
    if (!self.trackers) {
        RIRaiseError(@"Invalid call with non-existent trackers. Tracking initialisation was either "
                     @"missing or has probably failed.");
        return;
    }
    
    for (id tracker in self.trackers) {
        if ([tracker conformsToProtocol:protocol]) {
            [((id<RITracker>)tracker).queue addOperationWithBlock:^{
                NSMethodSignature *signature = [[tracker class] instanceMethodSignatureForSelector:selector];
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                [invocation setSelector:selector];
                
                for (NSUInteger idx = 0; idx < arguments.count; idx++) {
                    NSObject *argument = [arguments objectAtIndex:idx];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                
                [invocation setTarget:tracker];
                [invocation invoke];
            }];
        }
    }
}

#pragma mark - Hidden test helpers

+ (void)reset
{
    sharedInstance = nil;
    sharedInstanceToken = 0;
}

@end
