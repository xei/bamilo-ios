//
//  Ext+Dictionary.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/8/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    mutating func updateField(key: String, value:Any?) {
        guard let value = value else {
            return
        }
        self[key] = value
    }
}
