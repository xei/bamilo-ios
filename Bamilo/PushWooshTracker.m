//
//  PushWooshTracker.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PushWooshTracker.h"
#import <Pushwoosh/PWInAppManager.h>
#import "EmarsysMobileEngage.h"
#import "RITrackingWrapper.h"
#import "DeepLinkManager.h"

@interface PushWooshTracker()
@property (nonatomic, strong) NSArray<NSString *>*eligableEventsName;
@end

@implementation PushWooshTracker

static PushWooshTracker *instance;

+(instancetype)sharedTracker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PushWooshTracker new];
    });
    
    return instance;
}

- (NSArray <NSString *>*)eligableEventsName {
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

-(void)setUserID:(NSString *)userId {
    [[PWInAppManager sharedManager] setUserId:userId];
}

#pragma mark - PushNotificationTrackerProtocol
-(void)onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification {
    NSLog(@"PushWooshTracker > onPushAccepted : %@", pushNotification);
    
    NSString *customDataString = [pushManager getCustomPushData:pushNotification];
    
    if (customDataString) {
        [self handleCustomData:[NSJSONSerialization JSONObjectWithData:[customDataString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]];
    }

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        //App already open
    } else {
        //App opened from Notification
        
        [[RITrackingWrapper sharedInstance] applicationDidReceiveRemoteNotification:pushNotification];
        //EVENT: OPEN APP
        [TrackerManager postEvent:[EventFactory openApp:[[AppManager sharedInstance] updateOpenAppEventSource:OPEN_APP_SOURCE_PUSH_NOTIFICATION]] forName:[OpenAppEvent name]];
    }
}

#pragma mark - EventTrackerProtocol
-(void)postEvent:(NSDictionary *)attributes forName:(NSString *)name {
    [[PWInAppManager sharedManager] postEvent:name withAttributes:attributes];
}

-(BOOL)isEventEligable:(NSString *)eventName {
    return [self.eligableEventsName indexOfObjectIdenticalTo: eventName] != NSNotFound;;
}

#pragma mark - TagTrackerProtocol
-(void)sendTags:(NSDictionary *)tags completion:(TagTrackerCompletion)completion {
    [[PushNotificationManager pushManager] setTags:tags withCompletion:^(NSError *error) {
        if(completion) {
            completion(error);
        }
    }];
}

#pragma mark - Helpers
-(void) handleCustomData:(NSDictionary *)jsonData {
    [self handleActions:[jsonData objectForKey:@"actions"]];
    
    NSString *emarsysSID = [jsonData objectForKey:@"sid"];
    if(emarsysSID) {
        [[EmarsysMobileEngage sharedInstance] sendOpen:emarsysSID completion:^(BOOL success) {
            NSLog(@"EmarsysMobileEngage > sendOpen > %@", success ? sSUCCESSFUL : sFAILED);
        }];
    }
    
    // -- UTM tracking
    __block NSMutableDictionary *utmDictionary = [NSMutableDictionary new];
    [jsonData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *lowerCaseKey = [key lowercaseString];
        if ([lowerCaseKey isEqualToString:kUTMSource] ||
            [lowerCaseKey isEqualToString:kUTMMedium] ||
            [lowerCaseKey isEqualToString:kUTMCampaign] ||
            [lowerCaseKey isEqualToString:kUTMTerm] ||
            [lowerCaseKey isEqualToString:kUTMContent]) {
            [utmDictionary setObject:obj forKey:lowerCaseKey];
        }
    }];
    
    if (utmDictionary.allKeys.count) {
        [[RITrackingWrapper sharedInstance] trackCampaignData:utmDictionary];
    }
}

-(void) handleActions:(NSArray *)actions {
    if(actions && actions.count) {
        for(NSDictionary *action in actions) {
            NSString *actionKey = [action objectForKey:@"key"];
            NSDictionary *actionData = [action objectForKey:@"data"];
        
            //Handle alternative icon for iOS 10.3+ action
            if ([actionKey isEqualToString:@"change_icon"]) {
                NSString *icon = [actionData objectForKey:@"icon"];
                if(icon) {
                    if([icon isEqualToString:@"Default"]) {
                        [[AppManager sharedInstance] resetAppIconToDefault];
                    } else {
                        //If there is an expiryDate, consider that. If not, default is 1 week
                        NSDateFormatter *dateFormatter = [NSDateFormatter new];
                        [dateFormatter setDateFormat:cWebNormalizedDateTimeFormat];
                        //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
                        //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                        NSDate *expiryDate = [dateFormatter dateFromString:[actionData objectForKey:@"expires"]] ?: [[NSDate date] addWeeks:1];
                        [[AppManager sharedInstance] addAltAppIcon:icon expires:expiryDate];
                        [[AppManager sharedInstance] executeScheduledAppIcons];
                    }
                }
            }
        }
    }
}

@end
