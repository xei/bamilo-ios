//
//  BaseCollectionViewCellSwift.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class BaseCollectionViewCellSwift: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    static var nibName: String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    func setupView() {
        return
    }
}
