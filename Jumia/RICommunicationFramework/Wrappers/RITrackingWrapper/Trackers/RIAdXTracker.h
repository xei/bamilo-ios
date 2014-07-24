//
//  RIAdXTracker.h
//  RITracking
//
//  Created by Miguel Chaves on 20/Mar/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RITrackingWrapper.h"

extern NSString * const kRIAdXiPhoneBundleId;
extern NSString * const kRIAdXiPadBundleId;
extern NSString * const kRIAdXURLScheme;
extern NSString * const kRIAdXClientId;
extern NSString * const kRIAdXAppleId;

/**
 *  Convenience controller to proxy tracking information to AdXTracker
 */
@interface RIAdXTracker : NSObject
<
    RITracker,
    RIEventTracking,
    RIEcommerceEventTracking
>

@end
