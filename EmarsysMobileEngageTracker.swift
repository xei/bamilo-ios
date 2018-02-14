//
//  EmarsysMobileEngageTracker.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 2/10/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import MobileEngageSDK

class EmarsysMobileEngageTracker: EmarsysBaseTracker, MobileEngageStatusDelegate, EventTrackerProtocol {
    //TODO: Must be changed when we migrate all Trackers
    private static var sharedInstance: EmarsysMobileEngageTracker? // = GoogleAnalyticsTracker()
    override class func shared() -> EmarsysMobileEngageTracker {
        if sharedInstance == nil {
            sharedInstance = EmarsysMobileEngageTracker()
            sharedInstance?.setConfig()
        }
        return sharedInstance!
    }
    
    
    func setConfig() {
        let config = MEConfig.make { builder in
            if let mobileEngageConfigs = AppUtility.getInfoConfigs(for: "EmarsysMobileEngage") as? [String:String], let code = mobileEngageConfigs["Application_CODE"], let password = mobileEngageConfigs["Application_PASSWORD"] {
                builder.setCredentialsWithApplicationCode(code, applicationPassword: password)
            }
        }
        MobileEngage.setup(with: config)
        MobileEngage.statusDelegate = self
    }
    
    //MARK: - EventTrackerProtocol
    func appOpened(attributes: EventAttributeType) {
        if let customer = RICustomer.getCurrent() {
            MobileEngage.appLogin(withContactFieldId: 3, contactFieldValue: customer.email)
            return
        }
        MobileEngage.appLogin()
    }
    
    func logout(attributes: EventAttributeType) {
         MobileEngage.appLogout()
    }
    
    override func postEvent(byName eventName: String!, attributes: [AnyHashable : Any]! = [:]) {
        super.postEvent(byName: eventName, attributes: attributes)
        if let attributes = attributes as? [String : Any] {
            
            //convert all attribute values to string
            var convertedEventAttribute = [String: String]()
            attributes.forEach({ (key, value) in
                convertedEventAttribute[key] = "\(value)"
            })
            MobileEngage.trackCustomEvent(eventName, eventAttributes: convertedEventAttribute)
        }
    }
    
    //MARK: - MobileEngageStatusDelegate
    func mobileEngageLogReceived(withEventId eventId: String, log: String) {
        print(eventId, log)
    }
    
    func mobileEngageErrorHappened(withEventId eventId: String, error: Error) {
        print(eventId, error)
    }
}

