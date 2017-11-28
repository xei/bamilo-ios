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
        let item = self.init(JSON: recItem.data)  //self.instance(with: recItem)
        item?.id = identifier
        item?.topic = topic
        return item
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
                
                self.products.insert(item, at: self.products.count)
                
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
