//
//  CardCollectionViewFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CardCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    let otherContentHeight: CGFloat = 90
    let cellSpacing: CGFloat = 5
    let imageRatio: CGFloat = 1.25
    let imageWidthProportionalToParentWidth: CGFloat = 176 / 348
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 0
        minimumLineSpacing = cellSpacing
        scrollDirection = .vertical
    }
    
    func itemWidth() -> CGFloat {
        return collectionView!.frame.width
    }
    
    func itemHeight() -> CGFloat {
        let imageHeight = itemWidth() * imageWidthProportionalToParentWidth * imageRatio
        return imageHeight + otherContentHeight
    }
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width: itemWidth(), height: itemHeight())
        }
        get {
            return CGSize(width: itemWidth(), height: itemHeight())
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
}
