//
//  EventConsts.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventConsts : NSObject

//App & Device
FOUNDATION_EXPORT NSString *const kEventAppVersion;
FOUNDATION_EXPORT NSString *const kEventDeviceModel;

//User
FOUNDATION_EXPORT NSString *const kEventUserId;
FOUNDATION_EXPORT NSString *const kEventUserGender;

//Shop
FOUNDATION_EXPORT NSString *const kEventShopCountry;

//Event Details
FOUNDATION_EXPORT NSString *const kEventLabel;
FOUNDATION_EXPORT NSString *const kEventAction;
FOUNDATION_EXPORT NSString *const kEventCategory;
FOUNDATION_EXPORT NSString *const kEventValue;

@end
