//
//  DataMessageList.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import ObjectMapper

class ApiDataMessageList: Mappable {
    var success: [DataMessage]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        success     <- map["success"]
    }
}
