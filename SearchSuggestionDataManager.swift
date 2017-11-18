//
//  SearchSuggestionDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class SearchSuggestionDataManager: DataManagerSwift {
    
    static let sharedInstance = SearchSuggestionDataManager()
    
    func getSuggestion(_ target: DataServiceProtocol, queryString: String, completion: @escaping DataClosure) -> URLSessionTask? {
            return SearchSuggestionDataManager.requestManager.async(.get, target: target, path:  "\(RI_API_SEARCH_SUGGESTIONS)\(queryString)", params: nil, type: .background) { (responseType, data, errorMessages) in
                self.processResponse(responseType, aClass: SearchSuggestion.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
}
