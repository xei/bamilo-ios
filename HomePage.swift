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
        
        //mock for daily deals
        let deals = HomePageDailyDeals()
        deals.title = "پرفروش ها"
        deals.type = .dailyDeals
        deals.ramainingSeconds = 45
        deals.counterColor = .red
        deals.titleColor = .black
        let sampleProduct = Product()
        sampleProduct.name = "کفش مامان دوز"
        sampleProduct.brand = "نام برند"
        sampleProduct.imageUrl = URL(string: "http://zpvliimg.bamilo.com/p/goliran-9726-5009012-1-product.jpg")
        sampleProduct.price = 300000
        sampleProduct.maxSavingPrecentage = 30
        sampleProduct.target = "product_detail::IK259HL0YW7P2NAFAMZ"
        sampleProduct.specialPrice = 299999
        let moreOption = MoreButtonObject()
        moreOption.title = "بیشتر"
        moreOption.color = .red
        moreOption.target = "campaign::flash-sale2"
        deals.moreOption = moreOption
        
        
        deals.products = [sampleProduct, sampleProduct, sampleProduct, sampleProduct, sampleProduct, sampleProduct, sampleProduct, sampleProduct, sampleProduct, sampleProduct, sampleProduct, sampleProduct]
        teasersToParse.append(deals)
        //end of mock for daily deals
        
        
        //start of mock of tile teasers
        let tiles = HomePageTileTeaser()
        tiles.type = .tiles
        let tileItem = HomePageTileTeaserItem()
        tileItem.imageUrl = URL(string: "http://img.bamilo.com/bnp/hp/small-teaser/6104_380X170_watch.jpg")
        tileItem.target = "product_detail::IK259HL0YW7P2NAFAMZ"
        
        tiles.items = [tileItem, tileItem, tileItem, tileItem, tileItem]
        teasersToParse.append(tiles)
        //end of mock of tile teasers
        
        //start of mock of tile teasers
        let tiles1 = HomePageTileTeaser()
        tiles1.type = .tiles
        let tileItem1 = HomePageTileTeaserItem()
        tileItem1.imageUrl = URL(string: "http://img.bamilo.com/app/homepage/wide/6034-wide-faw.jpg")
        tileItem1.target = "product_detail::IK259HL0YW7P2NAFAMZ"
        tiles1.items = [tileItem1]
        teasersToParse.append(tiles1)
        //end of mock of tile teasers
        
        //start of mock of tile teasers
        let tiles2 = HomePageTileTeaser()
        tiles2.type = .tiles
        let tileItem2 = HomePageTileTeaserItem()
        tileItem2.imageUrl = URL(string: "http://img.bamilo.com/app/homepage/small/6098-small-heater.jpg")
        tileItem2.target = "product_detail::IK259HL0YW7P2NAFAMZ"
        tiles2.items = [tileItem2, tileItem2, tileItem2]
        teasersToParse.append(tiles2)
        //end of mock of tile teasers
        
        if let teasersToParse = teasersToParse as? [HomePageTeaserBox] {
            self.teasers = teasersToParse
        }
    }
}
