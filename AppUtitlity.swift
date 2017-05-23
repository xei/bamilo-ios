//
//  AppUtitlity.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

enum LocalLang : String {
    case english = "en"
    case arabic  = "ar"
}

struct AppUtility {
    
    static func convertSignleCharTo(character: String, language: LocalLang) -> String {
        let formatter: NumberFormatter = NumberFormatter()
        let irLoc = NSLocale(localeIdentifier: language.rawValue) as Locale
        formatter.locale = irLoc
        let final = formatter.number(from: character)
        if final != nil {
            return formatter.string(from: final!)!
        }
        return character
    }
    
    static var appName: String? {
        get {
            if let bundle = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
                return bundle.replacingOccurrences(of: " ", with: "_")
            }
            return nil
        }
    }
    
    static func getStringFromClass(for obj: AnyClass) -> String? {
        let fullClassString = NSStringFromClass(obj)
        if let name = appName {
            return fullClassString.replacingOccurrences(of: "\(name).", with: "")
        }
        return nil
    }
    
    static func getFullClassName(for className: String) -> String? {
        if let appName = AppUtility.appName {
            return appName + "." + className
        }
        
        return nil
    }
    
    static func getClassFromName(name: String) -> AnyClass? {
        if let fullClassName = getFullClassName(for: name) {
            return NSClassFromString(fullClassName)
        }
        
        return nil
    }
    
}
