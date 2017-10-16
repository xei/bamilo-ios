//
//  PurchaseBehaviourRecorder.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import RealmSwift

class PurchaseBehaviour: Object {
    dynamic var categoryName: String?
    dynamic var label: String?
    dynamic var sku: String?
}

class PurchaseBehaviourRecorder: NSObject {
    
    let realm = try! Realm()
    
    
}
