//
//  Transformers.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

public let colorTransformer = TransformOf<UIColor, String>(fromJSON: { UIColor.fromHexString(hex: $0!) }, toJSON: { $0?.toHexString() })
