//
//  AddressDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/2/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc class AddressDataManager: DataManager {
    
    //TODO: Must be changed when we migrate all data managers
    private static let shared = AddressDataManager()
    override class func sharedInstance() -> AddressDataManager {
        return shared;
    }
    
    
    //MARK: Address List API
    func getUserAddressList(target:DataServiceProtocol, completion: @escaping DataCompletion) {
        self.requestManager.asyncPOST(target, path: RI_API_GET_CUSTOMER_ADDRESS_LIST, params: nil, type: .foreground) { (responseStatus, data, errorMessages) in
            self.processResponse(responseStatus, of: AddressList.self, forData: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func setDefaultAddress(target: DataServiceProtocol, address: Address, isBilling: Bool, completion: @escaping DataCompletion) {
        let params : [String: String] = [
            "id"   : address.uid,
            "type" : isBilling ? "billing" : "shipping"
        ]
        self.requestManager.asyncPUT(target, path: RI_API_GET_CUSTOMER_SELECT_DEFAULT, params: params, type: .foreground) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: AddressList.self, forData: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    //MARK : Areas for Address create/edit
    func getRegions(target: DataServiceProtocol, completion:@escaping DataCompletion) {
        self.getAreaZone(tagret: target, type: .background, path: RI_API_GET_CUSTOMER_REGIONS, completion: completion)
    }
    
    func getCities(target: DataServiceProtocol, regionId:String, completion:@escaping DataCompletion) {
        
        let path = "\(RI_API_GET_CUSTOMER_CITIES)region/\(regionId)"
        self.getAreaZone(tagret: target, type: .background, path: path, completion: completion)
    }
    
    func getVicinity(target: DataServiceProtocol, cityId: String, completion:@escaping DataCompletion) {
        
        let path = "\(RI_API_GET_CUSTOMER_POSTCODES)city_id/\(cityId)"
        self.getAreaZone(tagret: target, type: .background, path:path, completion: completion)
    }
    
    //MARK: Address CRUD
    func addAddress(target: DataServiceProtocol, params: [String:String], completion:@escaping DataCompletion) {
        self.requestManager.asyncPOST(target, path: RI_API_POST_CUSTOMER_ADDDRESS_CREATE, params: params, type: .foreground) { (statusCode, data, errorMessages) in
            if (statusCode == RIApiResponse.success) {
                completion(data, nil)
            } else {
                completion(nil, self.getErrorFrom(statusCode, errorMessages: errorMessages))
            }
        }
    }
    
    func updateAddress(target: DataServiceProtocol, params: [String:String], id: String, completion:@escaping DataCompletion) {
        let path = "\(RI_API_POST_CUSTOMER_ADDDRESS_EDIT)\(id)"
        self.requestManager.asyncPOST(target, path: path, params: params, type: .foreground) { (statusCode, data, errorMessages) in
            if (statusCode == RIApiResponse.success) {
                completion(data, nil)
            } else {
                completion(nil, self.getErrorFrom(statusCode, errorMessages: errorMessages))
            }
        }
    }
    
    func getAddress(target: DataServiceProtocol, id: String, completion:@escaping DataCompletion) {
        let path = "\(RI_API_GET_CUSTOMER_ADDDRESS)?id=\(id)"
        self.requestManager .asyncGET(target, path: path, params: nil, type: .foreground) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: Address.self, forData: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func deleteAddress(target: DataServiceProtocol, address: Address, completion: @escaping DataCompletion) {
        let params : [String: String] = ["id" : address.uid ]
        self.requestManager.asyncDELETE(target, path: RI_API_DELETE_ADDRESS_REMOVE, params: params, type: .foreground) { (statusCode, data, errorMesssages) in
            self.processResponse(statusCode, of: nil, forData: data, errorMessages: errorMesssages, completion: completion)
        }
    }
    
    // MARK: Helpers
    private func getAreaZone(tagret: DataServiceProtocol, type: RequestExecutionType, path: String, completion:@escaping DataCompletion) {
        self.requestManager.asyncGET(tagret, path: path, params: nil, type: type) { (statusCode, data, errorMessages) in
            if let response = data, (statusCode == RIApiResponse.success) {
                var dictionary: [String: String] = [:]
                if let regions = response.metadata["data"] as? [[String:Any]] {
                    for region in regions {
                        if let regionLabel = region["label"] as? String, let regionValue = region["value"] as? Int {
                            dictionary[regionLabel] = String(regionValue)
                        }
                    }
                }
                completion(dictionary, nil)
            } else {
                completion(nil, self.getErrorFrom(statusCode, errorMessages: errorMessages))
            }
        }
    }
}
