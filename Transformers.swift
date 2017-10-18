//
//  Transformers.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

public let colorTransformer = TransformOf<UIColor?, String?>(fromJSON: { (hexString) -> UIColor?? in
    guard let hexString = hexString as? String else { return nil }
    return UIColor.fromHexString(hex: hexString)
    
}) { (color) -> String?? in
    return color??.toHexString()
}

