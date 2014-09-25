//
//  RIAd4PushTracker.h
//  RITracking
//
//  Created by Miguel Chaves on 20/Mar/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RITrackingWrapper.h"

extern NSString * const kRIAdd4PushUserID;
extern NSString * const kRIAdd4PushPrivateKey;
extern NSString * const kRIAdd4PushDeviceToken;

/**
 *  Convenience controller to proxy tracking information to Ad4Push
 */
@interface RIAd4PushTracker : NSObject
<
    RITracker,
    RILaunchEventTracker,
    RIEventTracking,
    RINotificationTracking,
    RIOpenURLTracking,
    RIEcommerceEventTracking
>

- (void)trackOpenURL:(NSURL *)url;

@end
