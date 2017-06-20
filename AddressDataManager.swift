//
//  AddressDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/2/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

class AddressDataManager: DataManagerSwift {
    static let sharedInstance = AddressDataManager()

    //MARK: - Address List API
    func getUserAddressList(_ target: DataServiceProtocol, completion: @escaping DataClosure) {
        AddressDataManager.requestManager.async(.post, target: target, path: RI_API_GET_CUSTOMER_ADDRESS_LIST, params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: AddressList.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func setDefaultAddress(_ target: DataServiceProtocol, address: Address, isBilling: Bool, completion: @escaping DataClosure) {
        let params : [String: String] = [
            "id"   : address.uid,
            "type" : isBilling ? "billing" : "shipping"
        ]
        AddressDataManager.requestManager.async(.put, target: target, path: RI_API_GET_CUSTOMER_SELECT_DEFAULT, params: params, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: AddressList.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    //MARK: - Address CRUD
    func addAddress(_ target: DataServiceProtocol, params: [String:String], completion:@escaping DataClosure) {
        AddressDataManager.requestManager.async(.post, target: target, path: RI_API_POST_CUSTOMER_ADDDRESS_CREATE, params: params, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func updateAddress(_ target: DataServiceProtocol, params: [String:String], id: String, completion:@escaping DataClosure) {
        let path = "\(RI_API_POST_CUSTOMER_ADDDRESS_EDIT)\(id)"
        AddressDataManager.requestManager.async(.post, target: target, path: path, params: params, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getAddress(_ target: DataServiceProtocol, id: String, completion:@escaping DataClosure) {
        let path = "\(RI_API_GET_CUSTOMER_ADDDRESS)?id=\(id)"
        AddressDataManager.requestManager.async(.get, target: target, path: path, params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: Address.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
//    func deleteAddress(_ target: DataServiceProtocol, address: Address, completion: @escaping DataClosure) {
//        let params : [String: String] = ["id" : address.uid ]
//        AddressDataManager.requestManager.async(.delete, target: target, path: RI_API_DELETE_ADDRESS_REMOVE, params: params, type: .container) { (responseType, data, errorMesssages) in
//            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMesssages, completion: completion)
//        }
//    }
    
    func getRegions(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        self.getAreaZone(target, type: .background, path: RI_API_GET_CUSTOMER_REGIONS, completion: completion)
    }
    
    func getCities(_ target: DataServiceProtocol, regionId:String, completion:@escaping DataClosure) {
        let path = "\(RI_API_GET_CUSTOMER_CITIES)region/\(regionId)"
        self.getAreaZone(target, type: .background, path: path, completion: completion)
    }
    
    func getVicinity(_ target: DataServiceProtocol, cityId: String, completion:@escaping DataClosure) {
        let path = "\(RI_API_GET_CUSTOMER_POSTCODES)city_id/\(cityId)"
        self.getAreaZone(target, type: .background, path:path, completion: completion)
    }
    
    // MARK: - Helpers
    private func getAreaZone(_ tagret: DataServiceProtocol, type: ApiRequestExecutionType, path: String, completion:@escaping DataClosure) {
        AddressDataManager.requestManager.async(.get, target: tagret, path: path, params: nil, type: type) { (statusCode, data, errorMessages) in
            if let response = data, (statusCode == .success) {
                var dictionary: [String: String] = [:]
                if let regions = response.metadata?["data"] as? [[String:Any]] {
                    for region in regions {
                        if let regionLabel = region["label"] as? String, let regionValue = region["value"] as? Int {
                            dictionary[regionLabel] = String(regionValue)
                        }
                    }
                }
                completion(dictionary, nil)
            } else {
                completion(nil, self.createError(statusCode, errorMessages: errorMessages))
            }
        }
    }
}
