//
//  ListCollectionViewFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class ListCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    let itemHeight: CGFloat = 115
    let cellSpacing: CGFloat = 5
    
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
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width: itemWidth(), height: itemHeight)
        }
        get {
            return CGSize(width: itemWidth(), height: itemHeight)
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
}
