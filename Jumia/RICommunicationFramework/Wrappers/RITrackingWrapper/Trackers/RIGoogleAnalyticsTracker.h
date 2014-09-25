//
//  RIGoogleAnalyticsTracker.h
//  RITracking
//
//  Created by Martin Biermann on 13/03/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RITrackingWrapper.h"

extern NSString * const kRIGoogleAnalyticsTrackingID;

/**
 *  Convenience controller to proxy-pass tracking information to Google Analytics
 */
@interface RIGoogleAnalyticsTracker : NSObject
<
    RITracker,
    RIEventTracking,
    RIExceptionTracking,
    RIScreenTracking,
    RIEcommerceEventTracking,
    RITrackingTiming,
//    RILaunchEventTracker,
    RICampaignTracker
>

+ (void)initGATrackerWithId:(NSString *)trackingId;

@end