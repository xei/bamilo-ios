//
//  Bool.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

extension Bool {
    mutating func toggle() {
        self = !self
    }
    
    func getReverse() -> Bool {
        return !self
    }
}
