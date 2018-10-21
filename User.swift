//
//  User.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/25/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON
import RealmSwift

enum Gender: String {
    case male = "male"
    case female = "female"
}

@objcMembers class User: NSObject, Mappable {
    
    var userID: UInt64?
    var email: String?
    var firstName: String?
    var lastName: String?
    var birthday: Date?
    var gender: Gender?
    var password: String?
    var createdAt: String?
    var loginMethod: String?
    var addressList: AddressList?
    var phone: String?
    var nationalID: String?
    var bankCartNumber: String?
    var wishListSkus: [String]?
    
    required init?(map: Map) {}
    override init() {}
    
    public convenience init(json: [String: Any]) {
        self.init(JSON: json)!
    }
    
    func mapping(map: Map) {
        userID <- map["id"]
        email <- map["email"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        let dateFormatter = DateFormatter(withFormat: "yyyy-MM-dd", locale: "en_US")
        dateFormatter.calendar = Calendar(identifier: .persian)
        birthday <- (map["birthday"], DateFormatterTransform(dateFormatter: dateFormatter))
        gender <- (map["gender"], EnumTransform())
        password <- map["password"]
        createdAt <- map["created_at"]
        phone <- map["phone"]
        nationalID <- map["national_id"]
        bankCartNumber <- map["card_number"]
        
        if let addressJson = JSON(map.JSON)["address_list"].dictionary {
            self.addressList = AddressList()
            do {
                try self.addressList?.merge(from: addressJson, useKeyMapping: true, error: ())
            } catch {}
        }
        
        if let wishListSkus = JSON(map.JSON)["wishlist_products"].array {
            self.wishListSkus = wishListSkus.map { $0.dictionary?.values.first?.stringValue }.compactMap { $0 }
        }
    }
    
    
    //Objective c helper functions
    func getID() -> NSNumber {
        return NSNumber(value: self.userID ?? 0)
    }
    func getGender() -> String? {
        return self.gender?.rawValue
    }
}


class CustomerEntity: NSObject, Mappable {
    
    var entity: User?
    var warningMessage: String?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        entity <- map["customer_entity"]
        warningMessage <- map["warning_message"]
    }
}

fileprivate let separator = "\u{FFFF}"
class SavingUser: Object {
    @objc dynamic var userID = 0
    @objc dynamic var firstName :String?
    @objc dynamic var plainPassword :String?
    @objc dynamic var gender :String?
    @objc dynamic var phone :String?
    @objc dynamic var email :String?
    @objc dynamic var lastName: String?
    @objc dynamic private var _wishListSkus: String?
    
    var wishListSkus: [String] {
        get { return _wishListSkus?.components(separatedBy: separator) ?? [] }
        set { _wishListSkus = newValue.isEmpty ? nil : newValue.joined(separator: separator) }
    }

    override static func ignoredProperties() -> [String] {
        return ["wishListSkus"]
    }
}

@objcMembers class CurrentUserManager: NSObject {
    
    static private let realm = try! Realm()
    static private(set) var user = User()
    
    static private var shareUser: SavingUser? = {
        return CurrentUserManager.realm.objects(SavingUser.self).first
    }()
    
    static func loadLocal() {
        if let userID = self.user.userID, userID != 0 { return } //no need to continue
        self.user.userID = UInt64(self.shareUser?.userID ?? 0)
        if let userID = self.user.userID, userID == 0 { return } //no need to continue
        self.user.firstName = self.shareUser?.firstName
        self.user.lastName = self.shareUser?.lastName
        self.user.gender = Gender(rawValue: self.shareUser?.gender ?? "")
        self.user.wishListSkus = self.shareUser?.wishListSkus
        self.user.phone = self.shareUser?.phone
        self.user.email = self.shareUser?.email
    }
    
    static func isUserLoggedIn() -> Bool {
        if let userID = self.user.userID { return userID != 0 }
        return false
    }
    
    static func cleanFromDB() {
        if let user = self.shareUser, user.userID != 0 {
            try! realm.write {
                self.realm.delete(user)
                self.shareUser = nil
            }
        }
        
        self.user = User()
        self.user.userID = 0
    }
    
    //TODO: the plainPass param should be removed
    static func saveUser(user: User, plainPassword: String) {
        if shareUser == nil {
            self.shareUser = SavingUser()
        }
        if let inputUserID = user.userID, let previousID = self.shareUser?.userID, inputUserID == previousID {
            try! realm.write {
                self.realm.add(shareUser!)
            }
        }
        
        self.shareUser?.userID = Int(user.userID ?? 0)
        self.shareUser?.firstName = user.firstName
        self.shareUser?.lastName = user.lastName
        self.shareUser?.email = user.email
        self.shareUser?.plainPassword = plainPassword
        self.shareUser?.phone = user.phone
        self.shareUser?.wishListSkus = user.wishListSkus ?? []
        self.user = user
        
        try! realm.write {
            self.realm.add(shareUser!)
        }
    }
}
