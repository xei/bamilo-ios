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

@end
