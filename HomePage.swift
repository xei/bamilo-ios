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
        .slider            : HomePageSlider.self,
        .featuredStores    : HomePageFeaturedStores.self,
        .dailyDeals        : HomePageDailyDeals.self,
        .tiles             : HomePageTileTeaser.self
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
            //create id for each teaser box
            var teaserCounter = [HomePageTeaserBox]()
            teasersToParse.forEach({ (item) in
                let index = teaserCounter.filter {$0.type == item.type}.count
                if let type = item.type?.rawValue {
                    item.teaserId = "\(type)_\(index)"
                }
                teaserCounter.append(item)
            })
    
            self.teasers = teasersToParse
        }
    }
}
