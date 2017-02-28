//
//  AccengageTracker.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RITrackingWrapper.h"

extern NSString * const kAccengagePartnerID;
extern NSString * const kAccengagePrivateKey;
extern NSString * const kAccengageDeviceToken;

@interface AccengageTracker : NSObject <RITracker, RILaunchEventTracker, RIEventTracking, RINotificationTracking, RIOpenURLTracking, RIEcommerceEventTracking>

+ (instancetype)sharedInstance;

@end
