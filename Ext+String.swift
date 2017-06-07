//
//  String.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

extension String {
    
    func convertTo(language: LocalLang) -> String {
        let characters = self.characters
        var converted: String = ""
        for character in characters {
            converted.append(AppUtility.convertSignleCharTo(character: String(character), language: language))
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
}
