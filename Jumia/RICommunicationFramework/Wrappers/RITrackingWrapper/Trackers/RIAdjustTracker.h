//
//  RIAdjustTracker.h
//  Jumia
//
//  Created by Pedro Lopes on 18/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Adjust.h"

extern NSString * const kRIAdjustToken;

@protocol RIAdjustTrackerDelegate <NSObject>

@optional

- (void)adjustAttributionChanged:(NSString*)network
                        campaign:(NSString*)campaign
                         adGroup:(NSString*)adGroup
                        creative:(NSString*)creative;

@end

@interface RIAdjustTracker : NSObject
<
RITracker,
RIOpenURLTracking,
RIEventTracking,
RILaunchEventTracker,
RIEcommerceEventTracking,
AdjustDelegate
>

@property (nonatomic, assign) id<RIAdjustTrackerDelegate> delegate;

@end
