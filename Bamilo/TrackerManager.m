//
//  TrackerManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "TrackerManager.h"

@implementation TrackerManager

static NSMutableArray *_eventTrackers, *_tagTrackers;

#pragma mark - Public Methods
+(NSMutableArray *)addEventTracker:(id<EventTrackerProtocol>)tracker {
    return [TrackerManager addTracker:tracker toArrayOfTrackers:_eventTrackers];
}

+(void)postEvent:(NSDictionary *)attributes forName:(NSString *)name {
    for(id<EventTrackerProtocol> tracker in _eventTrackers) {
        [tracker postEvent:attributes forName:name];
    }
}

+(NSMutableArray *)addTagTracker:(id<TagTrackerProtocol>)tracker {
    return [TrackerManager addTracker:tracker toArrayOfTrackers:_tagTrackers];
}

+(void)sendTags:(NSDictionary *)tags completion:(TagTrackerCompletion)completion {
    for(id<TagTrackerProtocol> tracker in _tagTrackers) {
        [tracker sendTags:tags completion:completion];
    }
}

#pragma mark - Private Methods
+(NSMutableArray *) addTracker:(id)tracker toArrayOfTrackers:(NSMutableArray *)trackers {
    if(trackers == nil) {
        trackers = [NSMutableArray new];
    }
    
    [trackers addObject:tracker];
    
    return trackers;
}

@end
