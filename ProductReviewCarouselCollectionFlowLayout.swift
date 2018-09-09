//
//  ProductReviewCarouselCollectionFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/2/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductReviewCarouselCollectionFlowLayout: CarouselCollectionFlowLayout {
    
    fileprivate static let SCROLL_DISTANCE_TOLERANCE: CGFloat = 10
    
    override func itemHeight() -> CGFloat {
        return collectionView?.frame.size.height ?? 0
    }
    
    override func itemWidth() -> CGFloat {
        return (collectionView?.frame.size.width ?? 0) * 0.8
    }
        
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if let collectionView = self.collectionView {
            if proposedContentOffset.x + collectionView.bounds.width >= collectionView.contentSize.width - ProductReviewCarouselCollectionFlowLayout.SCROLL_DISTANCE_TOLERANCE {
                return CGPoint(x: proposedContentOffset.x + self.minimumInteritemSpacing/2, y: proposedContentOffset.y)
            }
            let collectionViewBounds = collectionView.bounds
            let attributesArray = self.layoutAttributesForElements(in: collectionViewBounds)
            
            var candidateAttributes : UICollectionViewLayoutAttributes?
            for attributes in attributesArray! {
                
                // == Skip comparison with non-cell items (headers and footers) == //
                if attributes.representedElementCategory != UICollectionElementCategory.cell {
                    continue
                }
                
                // == First time in the loop == //
                if candidateAttributes == nil {
                    candidateAttributes = attributes
                    continue
                }
                
                if fabs(attributes.frame.origin.x - proposedContentOffset.x) <
                    fabs(candidateAttributes!.frame.origin.x - proposedContentOffset.x) {
                    candidateAttributes = attributes
                    
                    if attributes.indexPath.row != 0 && attributes.indexPath.row != collectionView.numberOfItems(inSection: attributes.indexPath.section) {
                        let leftSpace = (collectionView.bounds.width - (attributes.frame.size.width + (minimumLineSpacing * 2))) / 2
                        candidateAttributes?.frame.origin.x -= leftSpace
                    }
                }
            }
            return CGPoint(x: candidateAttributes!.frame.origin.x - self.minimumInteritemSpacing, y: proposedContentOffset.y)
        }
        // Fallback
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
}
