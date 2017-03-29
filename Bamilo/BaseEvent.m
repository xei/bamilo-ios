//
//  BaseEvent.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseEvent.h"
#import "RIApi.h"
#import "RICustomer.h"
#import "AppManager.h"
#import "DeviceManager.h"

@implementation BaseEvent

+(NSMutableDictionary *)event {
    return [NSMutableDictionary
            dictionaryWithObjects:@[
                        [RICustomer getCustomerId],
                        [[AppManager sharedInstance] getAppFullFormattedVersion],
                        [DeviceManager getDeviceModel],
                        [RIApi getCountryIsoInUse] ]
            
            forKeys:@[  kEventUserId,
                        kEventAppVersion,
                        kEventDeviceModel,
                        kEventShopCountry ]];
}

+(NSString *)name {
    return nil;
}

@end
