//
//  CancellingOrder.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/8/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class CancellingOrder {
    var orderNum: String!
    var description: String?
    var items:[CancellingOrderProduct]?
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        
        json.updateField(key: "orderNumber", value: orderNum)
        json.updateField(key: "description", value: description)
        
        
        let cancelligItems = self.items?.map{ $0.toJson() }
        if let cancelligItems =  cancelligItems {
            for (index, item) in cancelligItems.enumerated() {
                for (key, value) in item {
                    json["items[\(index)][\(key)]"] = value
                }
            }
        }
        
        return json
    }
}

class CancellingOrderProduct: OrderProductItem {
    var reasonId: String?
    var isSelected: Bool = false
    var cancellingQuantity: Int = 1
    func toJson() -> [String: Any] {
        var json = [String:Any]()
        json.updateField(key: "simpleSku", value: simpleSku)
        json.updateField(key: "quantity", value: cancellingQuantity)
        json.updateField(key: "reasonId", value: reasonId)
        return json
    }
}
