//
//  TrackerManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventTrackerProtocol.h"
#import "EventFactory.h"
#import "TagTrackerProtocol.h"

@interface TrackerManager : NSObject

+(NSMutableArray *) addTracker:(id)tracker;

//### EventTrackerProtocol
+(void) postEvent:(NSDictionary *)attributes forName:(NSString *)name;

//### TagTrackerProtocol
+(void) sendTags:(NSDictionary *)tags completion:(TagTrackerCompletion)completion;

@end
