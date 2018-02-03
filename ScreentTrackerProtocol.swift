
//
//  ScreentTrackerProtocol.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

@objc protocol ScreenTrackerProtocol : NSObjectProtocol {
    func trackScreenName(screenName: String)
    @objc optional func trackLoadTime(screenName: String, interval: NSNumber, label: String)
}
