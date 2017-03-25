//
//  PushWooshTracker.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PushWooshTracker.h"
#import <Pushwoosh/PWInAppManager.h>

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
    NSString *customDataString = [pushManager getCustomPushData:pushNotification];
    
    NSDictionary *jsonData = nil;
    if (customDataString) {
        jsonData = [NSJSONSerialization JSONObjectWithData:[customDataString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    }
}

#pragma mark - EventTrackerProtocol
-(void)postEvent:(NSDictionary *)attributes forName:(NSString *)name {
    [[PWInAppManager sharedManager] postEvent:name withAttributes:attributes];
}

@end
