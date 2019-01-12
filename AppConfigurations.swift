//
//  AppConfigurations.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/12/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

enum AppUpdateStatus: Int32 {
    case normal = 0
    case optionalUpdate = 1
    case forceUpdate = 2
}

class AppConfigurations: NSObject, Mappable {
    
    var currency: String?
    var phoneNumber: String?
    var csEmail: String?
    var status: AppUpdateStatus?
    var updateTitle: String?
    var updateMessage: String?
    var storeUrl: String?
    
    override init() {}
    required init?(map: Map) {}
    func mapping(map: Map) {
        currency <- map["currency_symbol"]
        phoneNumber <- map["phone_number"]
        csEmail <- map["cs_email"]
        status <- (map["version.status"], EnumTransform())
        updateTitle <- map["version.message_title"]
        updateMessage <- map["version.message_content"]
        storeUrl <- map["version.store_url"]
    }
}
