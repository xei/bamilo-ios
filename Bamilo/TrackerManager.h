//
//  TrackerManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventTrackerProtocol.h"

@interface TrackerManager : NSObject

//### EventTrackerProtocol
+(NSMutableArray *) addEventTracker:(id<EventTrackerProtocol>)tracker;
+(void) postEvent:(NSDictionary *)attributes forName:(NSString *)name;

@end
