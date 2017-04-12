//
//  TrackerManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "TrackerManager.h"

@implementation TrackerManager

static NSMutableArray *_trackers;

#pragma mark - Public Methods
+(NSMutableArray *)addTracker:(id)tracker {
    if(_trackers == nil) {
        _trackers = [NSMutableArray new];
    }
    
    [_trackers addObject:tracker];
    
    return _trackers;
}

+(void)postEvent:(NSDictionary *)attributes forName:(NSString *)name {
    for(id tracker in _trackers) {
        if([tracker conformsToProtocol:@protocol(EventTrackerProtocol)]) {
            [tracker postEvent:attributes forName:name];
        }
    }
}

+(void)sendTags:(NSDictionary *)tags completion:(TagTrackerCompletion)completion {
    for(id<TagTrackerProtocol> tracker in _trackers) {
        if([tracker conformsToProtocol:@protocol(TagTrackerProtocol)]) {
            [tracker sendTags:tags completion:completion];   
        }
    }
}

@end
