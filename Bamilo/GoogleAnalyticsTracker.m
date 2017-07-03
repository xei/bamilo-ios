//
//  GoogleAnalyticsTracker.m
//  Bamilo
//
//  Created by Ali Saeedifar on 5/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "GoogleAnalyticsTracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface GoogleAnalyticsTracker()
@property (nonatomic, strong) NSArray<NSString *>* eligableEventNames;
@property (nonatomic, copy) NSString *campaignDataString;
@end

@implementation GoogleAnalyticsTracker

static GoogleAnalyticsTracker *instance;

+(instancetype)sharedTracker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GoogleAnalyticsTracker new];
        [instance setConfigs];
    });
    return instance;
}

- (NSArray<NSString *> *)eligableEventNames {
    return @[[LoginEvent name],
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

#pragma mark - ScreenTrackingProtocol
- (void)trackScreenName:(NSString *)screenName {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value: screenName];
    [tracker send:[[[GAIDictionaryBuilder createScreenView] setCampaignParametersFromUrl:self.campaignDataString] build]];
}

#pragma mark - EventTrackerProtocol
-(void)postEvent:(NSDictionary *)attributes forName:(NSString *)name {
    GAIDictionaryBuilder* params = [GAIDictionaryBuilder createEventWithCategory:attributes[kGAEventCategory]
                                                                          action:attributes[kGAEventActionName]
                                                                           label:attributes[kGAEventLabel]
                                                                           value:attributes[kGAEventValue]];
    if (self.campaignDataString.length) {
        [params setCampaignParametersFromUrl:self.campaignDataString];
    }
    [[[GAI sharedInstance] defaultTracker] send:[params build]];
}

-(BOOL)isEventEligable:(NSString *)eventName {
    return [self.eligableEventNames indexOfObjectIdenticalTo: eventName] != NSNotFound;;
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


- (void)trackCampaignData:(NSDictionary *)campaignData {
    if(campaignData.count) {
        NSMutableArray* params = [NSMutableArray new];
        
        if ([campaignData objectForKey:kUTMCampaign]) {
            [params addObject:[NSString stringWithFormat:@"%@=%@", kUTMCampaign, [campaignData objectForKey:kUTMCampaign]]];
        }
        
        if ([[campaignData objectForKey:kUTMSource] length] == 0) {
            if ([[campaignData objectForKey:kUTMCampaign] length]) {
                [params addObject: [NSString stringWithFormat:@"%@=push", kUTMSource]];
            }
        } else {
            [params addObject:[NSString stringWithFormat:@"%@=%@",kUTMSource, [campaignData objectForKey:kUTMSource]]];
        }
        
        if ([[campaignData objectForKey:kUTMMedium] length] == 0) {
            if ([[campaignData objectForKey:kUTMCampaign] length]) {
                [params addObject:[NSString stringWithFormat:@"%@=referrer" , kUTMMedium]];
            }
        } else {
            [params addObject:[NSString stringWithFormat:@"%@=%@",kUTMMedium, [campaignData objectForKey:kUTMMedium]]];
        }
        
        if ([campaignData objectForKey:kUTMTerm]) {
            [params addObject:[NSString stringWithFormat:@"%@=%@",kUTMTerm, [campaignData objectForKey:kUTMTerm]]];
        }
        
        if ([campaignData objectForKey:kUTMContent]) {
            [params addObject:[NSString stringWithFormat:@"%@=%@",kUTMContent, [campaignData objectForKey:kUTMContent]]];
        }
        self.campaignDataString = [params componentsJoinedByString:@"&"];
    }
}

@end
