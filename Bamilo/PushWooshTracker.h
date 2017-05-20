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
#import "TagTrackerProtocol.h"

@interface PushWooshTracker : BaseTracker <PushNotificationTrackerProtocol, EventTrackerProtocol, TagTrackerProtocol>

-(void) setUserID:(NSString *)userId;

@end
