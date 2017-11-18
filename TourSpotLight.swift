//
//  TourSpotLight.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class TourSpotLight: NSObject {
    
    enum TourSpotLightShape {
        case rectangle
        case roundRectangle
        case circle
    }
    
    var rect = CGRect()
    var shape : TourSpotLightShape = .roundRectangle
    var margin = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var isAllowPassTouchesThroughSpotlight = false
    
    var attributedText : NSAttributedString? = nil
    private let zeroMargin = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    
    var rectValue : NSValue {
        return NSValue(cgRect: rect)
    }
    
    init(withRect rect: CGRect,
         shape: TourSpotLightShape,
         attributedText: NSAttributedString,
         margin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
         isAllowPassTouchesThroughSpotlight: Bool = false) {
        super.init()
        self.rect = rect
        self.shape = shape
        self.attributedText = attributedText
        self.margin = margin
        self.isAllowPassTouchesThroughSpotlight = isAllowPassTouchesThroughSpotlight
    }
    
    convenience init(withRect rect: CGRect,
         shape: TourSpotLightShape,
         text: String,
         margin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
         isAllowPassTouchesThroughSpotlight: Bool = false) {
        self.init(withRect: rect, shape: shape, attributedText: NSAttributedString(string: text), margin: margin, isAllowPassTouchesThroughSpotlight: isAllowPassTouchesThroughSpotlight)
    }
    
    convenience override init() {
        self.init(withRect: CGRect(), shape: .roundRectangle, text: "", margin: UIEdgeInsets())
    }
}
