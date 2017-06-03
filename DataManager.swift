//
//  DataManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import ObjectMapper

typealias DataClosure = (_ data: Any?, _ error: Error?) -> Void

class DataManagerSwift {
    
    class func sharedInstance() -> DataManagerSwift {
        return DataManagerSwift()
    }
    
    private(set) lazy var requestManager: RequestManagerSwift = {
        return RequestManagerSwift(with: "http://bamilo.com/mobapi/v2.3")
    }()
    
    func processResponse(_ responseType: ApiResponseType, aClass: Any?, data: ResponseData?, errorMessages: [String]?, completion: DataClosure?) {
        
    }
    
    func createError(_ responseType: ApiResponseType, errorMessages: [String]?) -> Error? {
        return nil
    }
}
