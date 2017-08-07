//
//  DataMessage.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import ObjectMapper

@objc class ApiDataMessage: NSObject, Mappable {
    
    var message: String? = nil
    var reason: String? = nil
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        message     <- map["message"]
        reason      <- map["reason"]
    }
}
