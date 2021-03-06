//
//  String.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

extension String {
    
    static let EMPTY = ""
    
    func forceLTR() -> String {
        return "\u{200E}".appending(self)
    }
    func forceRTL() -> String {
        return "\u{200F}".appending(self)
    }
    
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func convertTo(language: LocalLang) -> String {
        var converted: String = ""
        for character in self {
            converted.append(convertSingleCharTo(character: String(character), language: language))
        }
        return converted
    }
    
    func persianDoubleFormat() -> String {
        return self.replacingOccurrences(of: ".", with: "/")
    }
    
    func priceFormat() -> String {
        
        let TPrice = self.dropLast()
        var cammaIndex: Int = TPrice.count % 3 == 0 ? 3 : TPrice.count % 3
        var result = TPrice
        while (cammaIndex < result.count) {
            result.insert(",", at: result.index(result.startIndex, offsetBy: cammaIndex))
            cammaIndex += 4;
        }
        return String(result)
    }
    
    func formatPriceWithCurrency() -> String {
        return convertTo(language: .arabic).priceFormat() + " " + STRING_CURRENCY
    }
    
    func strucThroughPriceFormat() -> NSAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
    static func phoneRegx() -> String {
        return "^(((\\+|00)98)|0)?9[01239]\\d{8}$"
    }
    
    static func emailRegx() -> String {
        return "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
    }
    
    //MARK: Private Methods
    private func convertSingleCharTo(character: String, language: LocalLang) -> String {
        let formatter: NumberFormatter = NumberFormatter()
        let irLoc = NSLocale(localeIdentifier: language.rawValue) as Locale
        formatter.locale = irLoc
        if let final = formatter.number(from: character) {
            return formatter.string(from: final)!
        }
        return character
    }
}
