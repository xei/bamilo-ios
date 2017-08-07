//
//  Double.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

extension Double {
    func roundByStep(step: Double) -> Double {
        return floor((self + 0.5 * step ) / step ) * step
    }
}
