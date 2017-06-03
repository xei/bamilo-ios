//
//  ResponseData.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 5/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import ObjectMapper

class ApiResponseData: Mappable {
    var metadata: [String: Any]?
    var messages: DataMessageList?
    var success: Bool = false
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        metadata    <- map["metadata"]
        messages    <- map["messages"]
        success     <- map["success"]
    }
}
