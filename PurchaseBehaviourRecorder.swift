//
//  PurchaseBehaviourRecorder.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import RealmSwift

@objcMembers class PurchaseBehaviour: Object {
    @objc dynamic var categoryName: String?
    @objc dynamic var label: String?
    @objc dynamic var sku: String?
}

@objcMembers class BehaviourTrackingInfo: NSObject {
    class func trackingInfo(category: String, label: String) -> String {
        return "\(category):::\(label)"
    }
}

@objcMembers class PurchaseBehaviourRecorder: NSObject {
    
    static var sharedInstance = PurchaseBehaviourRecorder()
    
    let realm = try! Realm()
    
    //tracking info is an string with `category:::label` template
    func recordAddToCart(sku: String, trackingInfo: String) {
        let trackInfoArray = trackingInfo.components(separatedBy: ":::")
        if trackInfoArray.count > 1 {
            
            //delete previous beviour by this sku
            self.deleteBehaviour(sku: sku)
            
            let behaviour = PurchaseBehaviour()
            behaviour.categoryName = trackInfoArray[0]
            behaviour.label = trackInfoArray[1]
            behaviour.sku = sku
            
            try! realm.write {
                realm.add(behaviour)
            }
        }
    }
    
    func deleteBehaviour(sku: String) {
        let behaviours = realm.objects(PurchaseBehaviour.self)
        let targetBehaviour = behaviours.filter {$0.sku == sku}
        if targetBehaviour.count > 0 {
            try! realm.write {
                realm.delete(targetBehaviour.first!)
            }
        }
    }
    
    func getBehviourBySku(sku: String) -> PurchaseBehaviour? {
        let behaviours = realm.objects(PurchaseBehaviour.self)
        let targetBehaviour = behaviours.filter {$0.sku == sku}
        if targetBehaviour.count > 0 {
            return targetBehaviour.first
        }
        return nil
    }
}
