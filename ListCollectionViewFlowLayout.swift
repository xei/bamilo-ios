//
//  ListCollectionViewFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class ListCollectionViewFlowLayout: BaseCatalogCollectionFlowLayout {
    
    let cellHeight: CGFloat = 115
    let cellSpacing: CGFloat = 5
    
    override func setupLayout() {
        super.setupLayout()
        minimumInteritemSpacing = 0
        minimumLineSpacing = cellSpacing
        scrollDirection = .vertical
    }
    
    override func itemWidth() -> CGFloat {
        return collectionView!.frame.width
    }
    
    override func itemHeight() -> CGFloat {
        return cellHeight
    }
}
