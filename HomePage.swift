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
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        
        let json = JSON(map.JSON)
        json["data"].array?.forEach({ (teaserJSon) in
            if let typeName = teaserJSon["type"].string, let teaserDictionary = teaserJSon.dictionaryObject ,let knownType = HomePageTeaserType(rawValue: typeName) {
//                if let newTeaser = self.teaserTypeMapper[knownType]?.init(JSON: teaserDictionary) {
//                    self.teasers.append(newTeaser)
//                }
                if knownType == .slider, let newTeaser = HomePageSlider(JSON: teaserDictionary) {
                    self.teasers.append(newTeaser)
                }
            }
        })
    }
}
