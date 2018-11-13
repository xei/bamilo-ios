//
//  PushWooshTracker.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PushWooshTracker.h"
#import <Pushwoosh/PWInAppManager.h>
#import "RITrackingWrapper.h"
#import "DeepLinkManager.h"
#import "Bamilo-Swift.h"

@implementation PushWooshTracker

static PushWooshTracker *instance;

+(instancetype)sharedTracker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PushWooshTracker new];
    });
    
    return instance;
}

+ (void)setUserID:(NSString *)userId {
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
        //EVENT: OPEN APP
        [TrackerManager postEventWithSelector:[EventSelectors openAppSelector] attributes:[EventAttributes openAppWithSource:OpenAppEventSourceTypePushNotification]];
    }
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
    if (VALID_NOTEMPTY([jsonData objectForKey:@"change_icon"], NSDictionary)) {
        [self handleChangingIcon:[jsonData objectForKey:@"change_icon"]];
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
        [[GoogleAnalyticsTracker sharedTracker] trackCampaignDataWithCampaignDictionary:utmDictionary];
    }
}

-(void) handleChangingIcon:(NSDictionary *)iconConfig {
    NSString *iconName = [iconConfig objectForKey:@"icon"];
    if(VALID_NOTEMPTY(iconName, NSString)) {
        if([iconName isEqualToString:@"Default"]) {
            [[AppManager sharedInstance] resetAppIconToDefault];
        } else {
            //If there is an expiryDate, consider that. If not, default is 1 week
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:cWebNormalizedDateTimeFormat];
            //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            NSDate *expiryDate = [dateFormatter dateFromString:[iconConfig objectForKey:@"expires"]] ?: [[NSDate date] addWeeks:1];
            [[AppManager sharedInstance] addAltAppIcon:iconName expires:expiryDate];
            [[AppManager sharedInstance] executeScheduledAppIcons];
        }
    }
}

//Override
- (void)postEventByName:(NSString *)eventName attributes:(NSDictionary *)attributes {
    [super postEventByName:eventName attributes:attributes];
    [[PWInAppManager sharedManager] postEvent:eventName withAttributes:attributes];
}

@end
