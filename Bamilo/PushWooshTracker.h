//
//  PushWooshTracker.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTracker.h"
#import "PushNotificationTrackerProtocol.h"
#import "EventTrackerProtocol.h"

@interface PushWooshTracker : BaseTracker <PushNotificationTrackerProtocol, EventTrackerProtocol>

@end
