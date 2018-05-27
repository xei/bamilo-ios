//
//  DataMessageList.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import ObjectMapper

@objcMembers class ApiDataMessageList:NSObject, Mappable {
    
    var success: [ApiDataMessage]?
    var errors: [ApiDataMessage]?
    var validations: [[String:String]]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        success     <- map["success"]
        errors      <- map["error"]
        validations <- map["validate"]
    }
}
