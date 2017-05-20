//
//  GoogleAnalyticsTracker.m
//  Bamilo
//
//  Created by Ali Saeedifar on 5/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "GoogleAnalyticsTracker.h"
#import "GAI.h"
#import "GAIFields.h"

@interface GoogleAnalyticsTracker()
@property (nonatomic, strong) NSArray<NSString *>* eligableEvents;
@end

@implementation GoogleAnalyticsTracker

static GoogleAnalyticsTracker *instance;

+(instancetype)sharedTracker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GoogleAnalyticsTracker new];
//        [instance setConfigs];
    });
    
    return instance;
}

- (NSArray *)eligableEvents {
    if (!_eligableEvents) {
        _eligableEvents = @[[LoginEvent name],
                            [LogoutEvent name],
                            [SignUpEvent name],
                            [OpenAppEvent name],
                            [AddToFavoritesEvent name],
                            [AddToCartEvent name],
                            [AbandonCartEvent name],
                            [PurchaseEvent name],
                            [SearchEvent name],
                            [ViewProductEvent name]];
    }
    return _eligableEvents;
}

#pragma mark - ScreenTrackingProtocol
- (void)trackScreenName:(NSString *)screenName {
    return;
}

#pragma mark - EventTrackerProtocol
-(void)postEvent:(NSDictionary *)attributes forName:(NSString *)name {
    return;
}

-(BOOL)isEventEligable:(NSString *)eventName {
    return [self.eligableEvents indexOfObjectIdenticalTo: eventName] != NSNotFound;;
}

#pragma mark - helpers

- (void)setConfigs {
    // Automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Dispatch tracking information every 5 seconds (default: 120)
    [GAI sharedInstance].dispatchInterval = 5;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelNone];// kGAILogLevelVerbose];
    
    NSString *GAId = [[[NSBundle mainBundle] objectForInfoDictionaryKey:kConfigs] objectForKey:@"GoogleAnalyticsID"];
    [[GAI sharedInstance] trackerWithTrackingId: GAId];
    
    // Setup the app version
    [[GAI sharedInstance].defaultTracker set:kGAIAppVersion value: [[AppManager sharedInstance] getAppFullFormattedVersion] ?: @"?"];
    
    [[GAI sharedInstance].defaultTracker setAllowIDFACollection:YES];
}


@end
