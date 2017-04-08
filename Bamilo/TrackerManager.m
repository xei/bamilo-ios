//
//  TrackerManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "TrackerManager.h"

@implementation TrackerManager

static NSMutableArray *_eventTrackers;

#pragma mark - Public Methods
+(NSMutableArray *)addEventTracker:(id<EventTrackerProtocol>)tracker {
    if(_eventTrackers == nil) {
        _eventTrackers = [NSMutableArray new];
    }
    
    [_eventTrackers addObject:tracker];
    
    return _eventTrackers;
}

+(void)postEvent:(NSDictionary *)attributes forName:(NSString *)name {
    for(id<EventTrackerProtocol> tracker in _eventTrackers) {
        [tracker postEvent:attributes forName:name];
    }
}

@end
