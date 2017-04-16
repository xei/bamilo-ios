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

@implementation PushWooshTracker

static PushWooshTracker *instance;

+(instancetype)sharedTracker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PushWooshTracker new];
    });
    
    return instance;
}

-(void)setUserID:(NSString *)userId {
    [[PWInAppManager sharedManager] setUserId:userId];
}

#pragma mark - PushNotificationTrackerProtocol
-(void)onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification {
    NSLog(@"PushWooshTracker > onPushAccepted : %@", pushNotification);
    
    NSString *customDataString = [pushManager getCustomPushData:pushNotification];
    
    NSDictionary *jsonData = nil;
    if (customDataString) {
        jsonData = [NSJSONSerialization JSONObjectWithData:[customDataString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    }
    
    NSString *emarsysSID = [jsonData objectForKey:@"sid"];
    if(emarsysSID) {
        [[EmarsysMobileEngage sharedInstance] sendOpen:emarsysSID completion:^(BOOL success) {
            NSLog(@"EmarsysMobileEngage > sendOpen > %@", success ? sSUCCESSFUL : sFAILED);
        }];
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

#pragma mark - TagTrackerProtocol
-(void)sendTags:(NSDictionary *)tags completion:(TagTrackerCompletion)completion {
    [[PushNotificationManager pushManager] setTags:tags withCompletion:^(NSError *error) {
        if(completion) {
            completion(error);
        }
    }];
}

@end
