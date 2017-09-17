//
//  SearchSuggestionItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import RealmSwift

class SearchSuggestionItem: Object {
    dynamic var name: String?
    dynamic var target: String?
    dynamic var imageUrl: String?
    dynamic var type: String?  //can be category || product
}

class LocalSearchSuggestion {
    
    let realm = try! Realm()
    
    func clearAllHistories() {
        let suggestoins = realm.objects(SearchSuggestionItem.self)
        try! realm.write {
            realm.delete(suggestoins)
        }
    }
    
    func load() -> SearchSuggestion {
        let suggestoins = realm.objects(SearchSuggestionItem.self)
        let convertSuggestion = SearchSuggestion()
        
        convertSuggestion.categories = suggestoins.filter { $0.type == "category"}.map({ (catItem) -> CategorySuggestion in
            let category = CategorySuggestion()
            category.name = catItem.name
            category.target = catItem.target
            return category
        })
        
        convertSuggestion.products = suggestoins.filter { $0.type == "product"}.map({ (productItem) -> Product in
            let product = Product()
            product.name = productItem.name
            product.target = productItem.target
            product.imageUrl = URL(string: productItem.imageUrl ?? "")
            return product
        })
        return convertSuggestion
    }
    
    func add(product: Product? = nil, category: CategorySuggestion? = nil) {
        
        let suggestoins = realm.objects(SearchSuggestionItem.self)
        if let product = product {
            let privousProducts = suggestoins.filter { $0.type == "product"}
            let repeatedProduct = privousProducts.filter{ $0.target == product.target }
            if repeatedProduct.count > 0 { return }
            
            let convertedSuggestion = SearchSuggestionItem()
            convertedSuggestion.name = product.name
            convertedSuggestion.target = product.target
            convertedSuggestion.imageUrl = product.imageUrl?.absoluteString
            convertedSuggestion.type = "product"

            if privousProducts.count >= 3 {
                try! realm.write {
                    realm.delete(privousProducts.first!)
                }
            }
            
            try! realm.write {
                realm.add(convertedSuggestion)
            }
        }
        
        if let category = category {
            let privousCategory = suggestoins.filter { $0.type == "category"}
            let repeatedCategory = privousCategory.filter{ $0.target == category.target }
            if repeatedCategory.count > 0 { return }
            
            let convertedSuggestion = SearchSuggestionItem()
            convertedSuggestion.name = category.name
            convertedSuggestion.target = category.target
            convertedSuggestion.type = "category"
            
            if privousCategory.count >= 3 {
                try! realm.write {
                    realm.delete(privousCategory.first!)
                }
            }
            try! realm.write {
                realm.add(convertedSuggestion)
            }
        }
    }
}
