//
//  HomePageSlider.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class HomePageSliderItem: NSObject, Mappable {
    
    var title: String?
    var imagePortraitUrl: URL?
    var imageLandscapeUrl: URL?
    var target: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        imagePortraitUrl <- (map["image_portrait"], URLTransform())
        imageLandscapeUrl <- (map["image_landscape"], URLTransform())
        target <- map["target"]
    }
}


class HomePageSlider: HomePageTeaserBox {
    var sliders: [HomePageSliderItem]?
    override func mapping(map: Map) {
        super.mapping(map: map)
        sliders <- map["data"]
    }
}
