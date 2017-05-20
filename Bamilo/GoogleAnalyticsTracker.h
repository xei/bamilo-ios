//
//  GoogleAnalyticsTracker.h
//  Bamilo
//
//  Created by Ali Saeedifar on 5/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTracker.h"
#import "ScreenTrackingProtocol.h"
#import "EventTrackerProtocol.h"

@interface GoogleAnalyticsTracker : BaseTracker <ScreenTrackingProtocol, EventTrackerProtocol>

@end
