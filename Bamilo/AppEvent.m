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
    return nil;
}

+(NSMutableDictionary *)attributes {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjects:@[ [[AppManager sharedInstance] getAppFullFormattedVersion], [DeviceManager getConnectionType], [NSDate date] ] forKeys:@[ kEventAppVersion, kEventConnection, kEventDate ]];
    
    RICustomer *user = [RICustomer getCurrentCustomer];
    if(user) {
        //Gender
        if(user.gender) {
            [attributes setObject:[user.gender substringToIndex:1] forKey:kEventUserGender]; //m OR f
        }
    }
    
    return attributes;
}

@end
