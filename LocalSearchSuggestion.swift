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
    @objc dynamic var name: String?
    @objc dynamic var target: String?
    @objc dynamic var imageUrl: String?
    @objc dynamic var type: String?  //can be category || product
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
        }).reversed()
        
        convertSuggestion.products = suggestoins.filter { $0.type == "product"}.map({ (productItem) -> Product in
            let product = Product()
            product.name = productItem.name
            product.target = productItem.target
            product.imageUrl = URL(string: productItem.imageUrl ?? "")
            return product
        }).reversed()
        
        convertSuggestion.searchQueries = suggestoins.filter { $0.type == "searchQuery" }.map({ (searchItem) -> SearchSuggestionItem in
            let searchQuery = SearchSuggestionItem()
            searchQuery.name = searchItem.name
            searchQuery.target = searchItem.target
            return searchQuery
        }).reversed()
        
        return convertSuggestion
    }
    
    func add(product: Product? = nil, category: CategorySuggestion? = nil, searchQuery: String? = nil) {
        
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
        
            try! realm.write {
                if privousProducts.count >= 3 {
                    realm.delete(privousProducts.first!)
                }
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
            try! realm.write {
                if privousCategory.count >= 3 {
                    realm.delete(privousCategory.first!)
                }
                realm.add(convertedSuggestion)
            }
        }
        
        if let searchQuery = searchQuery {
            let trimedString = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimedString.count == 0 {
                return
            }
            
            let target = RITarget.getTarget(.CATALOG_SEARCH, node: trimedString)
            if let searchTarget = target?.targetString {
                let privousCategory = suggestoins.filter { $0.type == "searchQuery"}
                let repeatedSearchQuery = privousCategory.filter{ $0.target == searchTarget }
                if repeatedSearchQuery.count > 0 { return }
                
                let convertedSuggestion = SearchSuggestionItem()
                convertedSuggestion.name = trimedString
                convertedSuggestion.target = searchTarget
                convertedSuggestion.type = "searchQuery"
                
                if privousCategory.count >= 6 {
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

}
