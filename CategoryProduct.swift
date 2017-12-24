//
//  CategoryProduct.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class Categories: Mappable {
    var tree: [CategoryProduct]?
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        tree <- map["data"]
    }
}

class CategoryProduct : NSObject, Mappable {
    
    var urlKey : String?
    var target: String?
    var name : String?
    var image: URL?
    var id: String?
    var childern :[CategoryProduct]?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        var parsedName: String?
        var parsedLabel: String?
        parsedName   <- map["name"]
        parsedLabel  <- map["label"]
        
        name = parsedName ?? parsedLabel
        urlKey <- map["url_key"]
        image <- (map["image"], URLTransform())
        id <- map["id"]
        target <- map["target"]
        childern <- map["children"]
    }
}
