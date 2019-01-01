//
//  PushWooshTracker.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTracker.h"
#import "PushNotificationTrackerProtocol.h"
#import "TagTrackerProtocol.h"
#import "EmarsysBaseTracker.h"

@interface PushWooshTracker : EmarsysBaseTracker <PushNotificationTrackerProtocol, TagTrackerProtocol>

+(void) setUserID:(NSString *)userId;

@end
