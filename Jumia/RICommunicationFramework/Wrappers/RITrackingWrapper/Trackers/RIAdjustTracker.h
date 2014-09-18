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

@interface RIAdjustTracker : NSObject
<
RITracker,
RIEventTracking,
AdjustDelegate
>

@end
