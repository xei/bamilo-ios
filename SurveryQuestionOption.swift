//
//  SurveryQuestionOption.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 2/27/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class SurveyQuestionOption: NSObject, Mappable, SelectViewItemDataSourceProtocol {
    var image           : URL?
    var id              : Int?
    var title           : String?
    var value           : String?
    var isOtherType     : Bool = false
    var isSelected      : Bool? //for state of unselected cases we use optional state (nil)
    var optionalComment : String?
    
    override init() {} //for initializeing without mapping
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        value <- map["value"]
        image <- (map["image"], URLTransform())
        
        var other: Bool?
        other <- map["other"]
        isOtherType = other ?? false
    }
}
