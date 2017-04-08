//
//  AppEvent.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AppEvent.h"
#import "RIApi.h"
#import "RICustomer.h"
#import "AppManager.h"
#import "DeviceManager.h"

@implementation AppEvent

+(NSString *)name {
    return nil;
}

+(NSMutableDictionary *)attributes {
    return [NSMutableDictionary dictionaryWithObjects:@[ [[AppManager sharedInstance] getAppFullFormattedVersion], [DeviceManager getConnectionType], [NSDate date] ] forKeys:@[ kEventAppVersion, kEventConnection, kEventDate ]];
}

@end
