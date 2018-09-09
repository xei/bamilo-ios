//
//  UILabel.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

extension UILabel {
    
    func applyStyle(font: UIFont, color: UIColor) {
        self.font = font
        self.textColor = color
    }
    
    func setTitle(title: String, lineHeight: CGFloat, lineSpaceing: CGFloat, alignment: NSTextAlignment? = .center) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineSpacing = lineSpaceing
        paragraphStyle.alignment = alignment ?? .center
        
        let attrString = NSMutableAttributedString(string: title)
        
        attrString.addAttribute(NSAttributedStringKey.paragraphStyle as NSAttributedStringKey, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
    
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }

}
