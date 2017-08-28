//
//  ListCollectionViewFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class ListCollectionViewFlowLayout: BaseCatalogCollectionFlowLayout {
    
    private let cellHeight: CGFloat = 145
    
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
