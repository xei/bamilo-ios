//
//  AppEvent.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AppEvent.h"
#import "RICustomer.h"
#import "AppManager.h"
#import "DeviceManager.h"

@implementation AppEvent

+(NSString *)name {
    return NSStringFromClass(self);
}

+(NSMutableDictionary *)attributes {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:
                                       @{
                                         kEventName: [self name],
                                         kEventAppVersion: [[AppManager sharedInstance] getAppFullFormattedVersion],
                                         kEventPlatform: @"ios",
                                         kEventConnection: [DeviceManager getConnectionType],
                                         kEventDate:  [NSDate date]
                                         }];
    
    NSString *userGender = [RICustomer getCustomerGender];
    if(userGender) {
        [attributes setObject:userGender forKey:kEventUserGender]; //male OR female
    }
    
    return attributes;
}

@end
