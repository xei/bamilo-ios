////
////  TrackerManager.m
////  Bamilo
////
////  Created by Narbeh Mirzaei on 4/8/17.
////  Copyright © 2017 Rocket Internet. All rights reserved.
////
//
//#import "TrackerManager.h"
//
//@implementation TrackerManager
//
//static NSMutableArray <BaseTracker *> *_trackers;
//
//#pragma mark - Public Methods
//+ (NSMutableArray *)addTracker:(BaseTracker *)tracker {
//    if(_trackers == nil) {
//        _trackers = [NSMutableArray<BaseTracker *> new];
//    }
//    [_trackers addObject:tracker];
//    return _trackers;
//}
//
//
//+ (void)postEventViaSelector:(SEL)selector attributes:(NSDictionary *)attributes {
//    
//}
////+ (void)postEvent:(NSDictionary *)attributes forName:(NSString *)name {
////    for (id tracker in _trackers) {
////        if([tracker conformsToProtocol:@protocol(EventTrackerProtocol)] && [tracker isEventEligable:name]) {
////            [tracker postEvent:attributes forName:name];
////        }
////    }
////}
//
//+ (void)trackScreenName:(NSString *)screenName {
//    for (id tracker in _trackers) {
//        if([tracker conformsToProtocol:@protocol(ScreenTrackerProtocol)]) {
//            [tracker trackScreenName:screenName];
//        }
//    }
//}
//
//+ (void)sendTags:(NSDictionary *)tags completion:(TagTrackerCompletion)completion {
//    for(id<TagTrackerProtocol> tracker in _trackers) {
//        if([tracker conformsToProtocol:@protocol(TagTrackerProtocol)]) {
//            [tracker sendTags:tags completion:completion];   
//        }
//    }
//}
//
//@end
