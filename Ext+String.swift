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
    
    func convertTo(language: LocalLang) -> String {
        let characters = self.characters
        var converted: String = ""
        for character in characters {
            converted.append(convertSingleCharTo(character: String(character), language: language))
        }
        return converted
    }
    
    func priceFormat() -> String {
        var cammaIndex: Int = self.characters.count % 3 == 0 ? 3 : self.characters.count % 3
        var result = self
        while (cammaIndex < result.characters.count) {
            result.insert(",", at: result.index(result.startIndex, offsetBy: cammaIndex))
            cammaIndex += 4;
        }
        
        return result
    }
    
    func formatPriceWithCurrency() -> String {
        return convertTo(language: .arabic).priceFormat() + " " + STRING_CURRENCY
    }
    
    func strucThroughPriceFormat() -> NSAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSBaselineOffsetAttributeName, value: 0, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
        return attributeString
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
