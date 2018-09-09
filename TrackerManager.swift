//
//  TrackerManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

@objcMembers class TrackerManager: NSObject {
    
    static var trackers = [BaseTracker]()
    
    class func addTracker(tracker: BaseTracker) {
        self.trackers.append(tracker)
    }
    
    class func postEvent(selector: Selector, attributes: EventAttributeType) {
        trackers.forEach { (tracker) in
            if tracker.conforms(to: EventTrackerProtocol.self) && tracker.responds(to: selector){
                tracker.perform(selector, with: attributes)
            }
        }
    }
    
    class func trackLoadTime(screenName: String, interval: NSNumber, label: String) {
        trackers.forEach { (tracker) in
            (tracker as? ScreenTrackerProtocol)?.trackLoadTime?(screenName: screenName, interval: interval, label: label)
        }
    }
    
    class func trackScreenName(screenName:String) {
        self.trackers.forEach { (tracker) in
            (tracker as? ScreenTrackerProtocol)?.trackScreenName(screenName: screenName)
        }
    }
    
    class func sendTag(tags: [String:Any], completion: @escaping TagTrackerCompletion) {
        self.trackers.forEach { (tracker) in
            (tracker as? TagTrackerProtocol)?.sendTags(tags, completion: completion)
        }
    }
}
