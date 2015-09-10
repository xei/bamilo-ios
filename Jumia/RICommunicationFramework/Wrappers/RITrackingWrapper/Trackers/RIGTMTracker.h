//
//  RIGTMTracker.h
//  Jumia
//
//  Created by plopes on 26/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIGTMTracker : NSObject
<
RITracker,
RILaunchEventTracker,
RIEventTracking,
RIEcommerceEventTracking,
RITrackingTiming,
RIStaticPageTracker
>

+ (instancetype)sharedInstance;

- (void)setGTMTrackerId:(NSString *)trackingId andGaId:(NSString *)gaId;

@end
