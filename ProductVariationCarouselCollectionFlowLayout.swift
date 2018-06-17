//
//  ProductVariationCarouselCollectionFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/9/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductVariationCarouselCollectionFlowLayout: BaseCollectionFlowLayout {
    
    override func setupLayout() {
        super.setupLayout()
        minimumInteritemSpacing = 0
        minimumLineSpacing = cellSpacing
        scrollDirection = .horizontal
    }
    
    override func itemWidth() -> CGFloat {
        let collectionWidth = self.collectionView?.frame.width ?? 0
        return round((collectionWidth - (5 * cellSpacing)) / 4.5)
    }
    
    override func itemHeight() -> CGFloat {
        return self.collectionView?.frame.height ?? 0
    }
}
