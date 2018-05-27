//
//  Ext+UIColor.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

extension UIColor {
    class func fromHexString (hex:String) -> UIColor? {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return nil
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
    
    static let placeholderColors:[UIColor] = [ //Sequence of these colors are important
        #colorLiteral(red: 0.9764705882, green: 0.937254902, blue: 0.9176470588, alpha: 1), #colorLiteral(red: 0.9254901961, green: 0.9254901961, blue: 0.9254901961, alpha: 1), #colorLiteral(red: 0.8862745098, green: 0.9098039216, blue: 0.937254902, alpha: 1), #colorLiteral(red: 0.9137254902, green: 0.968627451, blue: 0.968627451, alpha: 1), #colorLiteral(red: 0.9607843137, green: 0.9450980392, blue: 0.968627451, alpha: 1), #colorLiteral(red: 0.9254901961, green: 0.9215686275, blue: 0.9098039216, alpha: 1)
    ]
}
