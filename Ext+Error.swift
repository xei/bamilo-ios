//
//  Ext+Error.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 12/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation


extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
