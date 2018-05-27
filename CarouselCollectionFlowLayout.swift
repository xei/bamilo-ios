//
//  CarouselCollectionFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CarouselCollectionFlowLayout: BaseCollectionFlowLayout {
    
    private static let smallWindowSize: CGFloat = 520
    private static let mediumWindowSize: CGFloat = 767
    
    override func setupLayout() {
        super.setupLayout()
        minimumInteritemSpacing = 0
        minimumLineSpacing = cellSpacing
        scrollDirection = .horizontal
    }
    
    override func itemWidth() -> CGFloat {
        return CarouselCollectionFlowLayout.itemWidth(relateTo: self.collectionView?.frame.width ?? 0, cellSpacing: cellSpacing)
    }
    
    class func itemWidth(relateTo parentWidth: CGFloat, cellSpacing: CGFloat) -> CGFloat {
        let collectionWidth = parentWidth
        
        if collectionWidth < smallWindowSize {
            return round((collectionWidth - (3 * cellSpacing)) / 2.25)
        } else if collectionWidth > smallWindowSize && collectionWidth < mediumWindowSize {
            return round((collectionWidth - (4 * cellSpacing)) / 3.5)
        } else {
            return round((collectionWidth - (5 * cellSpacing)) / 4.5)
        }
    }
}
