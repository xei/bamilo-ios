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

class AppUtility {

    class var appName: String? {
        get {
            if let bundle = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
                return bundle.replacingOccurrences(of: " ", with: "_")
            }
            return nil
        }
    }
    
    class func getStringFromClass(for obj: AnyClass) -> String? {
        let fullClassString = NSStringFromClass(obj)
        if let name = appName {
            return fullClassString.replacingOccurrences(of: "\(name).", with: "")
        }
        return nil
    }
    
    class func getFullClassName(for className: String) -> String? {
        if let appName = AppUtility.appName {
            return appName + "." + className
        }
        
        return nil
    }
    
    class func getClassFromName(name: String) -> AnyClass? {
        if let fullClassName = getFullClassName(for: name) {
            return NSClassFromString(fullClassName)
        }
        
        return nil
    }
    
    class func getInfoValue<T>(for key:String) -> T? {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) as? T else {
            return nil
        }
        return object
    }
    
    class func getUserAgent() -> String {
        if let userAgent = UIWebView(frame: CGRect.zero).stringByEvaluatingJavaScript(from: "navigator.userAgent") {
            return userAgent
        }
        
        return String.EMPTY
    }
    
    class func getInfoConfigs(for key: String) -> Any? {
        if let configs = Bundle.main.infoDictionary?[AppKeys.Configs] as? NSDictionary {
            return configs[key]
        }
        
        return nil
    }
}
