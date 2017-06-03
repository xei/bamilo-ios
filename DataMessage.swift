//
//  DataMessage.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import ObjectMapper

class DataMessage: Mappable {
    var message: String?
    var reason: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        message     <- map["message"]
        reason      <- map["reason"]
    }
}
