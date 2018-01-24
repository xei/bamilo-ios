//
//  Ext+Array.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/10/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import Foundation

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        if from == to || self.count <= from || self.count <= to { return }
        insert(remove(at: from), at: to)
    }
}
