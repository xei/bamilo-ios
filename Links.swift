//
//  Links.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 12/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class Link: Mappable {
    var label: String?
    var imageURl: URL?
    
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        label <- map["label"]
        imageURl <- (map["image"], URLTransform(shouldEncodeURLString: true, allowedCharacterSet: .urlQueryAllowed))
    }
}

class InternalLink: Link {
    var target: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        target <- map["target"]
    }
}

class ExternalLink: Link {
    var link: String?
    override func mapping(map: Map) {
        super.mapping(map: map)
        link <- map["external_link_ios"]
    }
}


class InternalLinks: Mappable {
    var items: [InternalLink]?
    var title: String?
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        items <- map["internal_links"]
        title <- map["label"]
    }
}

class ExternalLinks: Mappable {
    var items: [ExternalLink]?
    var title: String?
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        items <- map["external_links"]
        items = []
        title <- map["label"]
        title = nil
    }
}
