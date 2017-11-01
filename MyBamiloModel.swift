//
//  MyBamilo.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import EmarsysPredictSDK

class MyBamiloRecommendItem: RecommendItem {
    
    var id: String! //which is the same as recommendation logic
    var topic: String?
    
    static func instance(with recItem: EMRecommendationItem, topic: String?, identifier: String?) -> Self? {
        let item = self.instance(with: recItem)
        item?.id = identifier
        item?.topic = topic
        return item
    }
    
    func convertToProduct() -> Product {
        let product = Product()
        product.name = self.name
        product.imageUrl = URL(string: self.imageUrl)
        product.sku = self.sku
        product.price = UInt64(self.price)
        product.brand = self.brandName
        product.specialPrice = UInt64(self.dicountedPrice)
        return product
    }
}

class MyBamiloModel {
    
    lazy var topics = [String:String]()
    lazy var products = [MyBamiloRecommendItem]()
    
    @discardableResult func embedNewRecommends(result: EMRecommendationResult) -> [MyBamiloRecommendItem] {
        var newjoinedProducts = [MyBamiloRecommendItem]()
        
        if let receivedTopic = result.topic , self.topics[receivedTopic] == nil {
            if let pureTopic = receivedTopic.components(separatedBy: ">").first {
                self.topics[pureTopic] = result.featureID
            }
        }
        
        result.products.forEach { (recommendedProduct) in
            if let item = MyBamiloRecommendItem.instance(with: recommendedProduct, topic: result.topic, identifier: result.featureID) {
                self.products.append(item)
                newjoinedProducts.append(item)
            }
        }
        return newjoinedProducts
    }
    
    func resetAndClear() {
        self.topics.removeAll()
        self.products.removeAll()
    }
    
    func filterById(id: String) -> [MyBamiloRecommendItem] {
        return self.products.filter { $0.id == id }
    }
}
