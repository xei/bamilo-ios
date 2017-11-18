//
//  HomeDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class HomeDataManager: DataManagerSwift {
    
    static let sharedInstance = HomeDataManager()
    
    func getHomeData(_ target: DataServiceProtocol, requestType: ApiRequestExecutionType, completion: @escaping DataClosure) {
        HomeDataManager.requestManager.async(.get, target: target, path: RI_API_GET_TEASERS, params: nil, type: requestType) { (responseType, data, errors) in
            self.processResponse(responseType, aClass: HomePage.self, data: data, errorMessages: errors, completion: completion)
        }
    }
}
