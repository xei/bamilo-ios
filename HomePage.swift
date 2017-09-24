//
//  HomePage.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class HomePage: NSObject, Mappable {
    
    lazy var teasers = [HomePageTeaserBox]()
    
    let teaserBoxTypeMapper: [HomePageTeaserType: Any] = [
        HomePageTeaserType.slider            : HomePageSlider.self,
        HomePageTeaserType.featuredStores    : HomePageFeaturedStores.self
    ]
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        let json = JSON(map.JSON)
        var teasersToParse = [Any]()
        json["data"].array?.forEach({ (teaserJSon) in
            if let typeName = teaserJSon["type"].string, let teaserDictionary = teaserJSon.dictionaryObject ,let knownType = HomePageTeaserType(rawValue: typeName) {
                if let teaserType = self.teaserBoxTypeMapper[knownType] as? Mappable.Type {
                    if let newTeaser = teaserType.init(JSON: teaserDictionary) {
                        teasersToParse.append(newTeaser)
                    }
                }
            }
        })
        
        if let teasersToParse = teasersToParse as? [HomePageTeaserBox] {
            self.teasers = teasersToParse
        }
    }
}
