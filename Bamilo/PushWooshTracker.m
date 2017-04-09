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

@implementation PushWooshTracker

static PushWooshTracker *instance;

+(instancetype)sharedTracker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PushWooshTracker new];
    });
    
    return instance;
}

#pragma mark - PushNotificationTrackerProtocol
-(void)onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification {
    NSLog(@"PushWooshTracker > onPushAccepted : %@", pushNotification);
    
    NSString *customDataString = [pushManager getCustomPushData:pushNotification];
    
    NSDictionary *jsonData = nil;
    if (customDataString) {
        jsonData = [NSJSONSerialization JSONObjectWithData:[customDataString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    }
    
    if(jsonData) { //HOW TO CHECK IF IT'S EMARSYS DATA???
        [[EmarsysMobileEngage sharedInstance] sendOpen:nil completion:^(BOOL success) {
            NSLog(@"EmarsysMobileEngage > sendOpen > %@", success ? sSUCCESSFUL : sFAILED);
        }];
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        //App already open
    } else {
        //App opened from Notification
        [[AppManager sharedInstance] updateOpenAppEventSource:OPEN_APP_SOURCE_PUSH_NOTIFICATION];
        [TrackerManager postEvent:[EventFactory openApp:[UserDefaultsManager incrementCounter:kUDMAppOpenCount] source:OPEN_APP_SOURCE_PUSH_NOTIFICATION] forName:[OpenAppEvent name]];
    }
}

#pragma mark - EventTrackerProtocol
-(void)postEvent:(NSDictionary *)attributes forName:(NSString *)name {
    [[PWInAppManager sharedManager] postEvent:name withAttributes:attributes];
}

@end
