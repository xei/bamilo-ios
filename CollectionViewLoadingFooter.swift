//
//  CollectionViewLoadingFooter.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CollectionViewLoadingFooter: UICollectionReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static let viewHeight: CGFloat = 50
    static func nibName() -> String {
        return "CollectionViewLoadingFooter"
    }
    
    static var nibInstance: UINib {
        return UINib(nibName: self.nibName(), bundle: nil)
    }
}
