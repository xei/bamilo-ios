//
//  JAProductCollectionViewFlowLayout.m
//  Jumia
//
//  Created by Jose Mota on 02/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAProductCollectionViewFlowLayout.h"

@implementation JAProductCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* attributesToReturn = [super layoutAttributesForElementsInRect:rect];
    
    int init = (int)[(UICollectionViewLayoutAttributes*)[attributesToReturn firstObject] indexPath].row;
    int last = (int)[(UICollectionViewLayoutAttributes*)[attributesToReturn lastObject] indexPath].row;
    
    for (UICollectionViewLayoutAttributes* attributes in attributesToReturn) {
        NSIndexPath* indexPath = attributes.indexPath;
        if (nil == attributes.representedElementKind) {
            attributes.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
        }
    }
    return [attributesToReturn arrayByAddingObjectsFromArray:[self getLayoutAttributesForSeparatorsInRect:rect forInitIndex:init andLastIndex:last]];
}

- (NSArray*)getLayoutAttributesForSeparatorsInRect:(CGRect)rect forInitIndex:(NSInteger)init andLastIndex:(NSInteger)last {
    NSInteger numberOfItemsPerLine = floorf(rect.size.width / self.itemSize.width);
    NSInteger countOfItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    
    if (countOfItems == 0) {
        return nil;
    }
    
    NSMutableArray* decorationAttributes = [NSMutableArray new];
    for (int i = (int)init; i <= (int)last; i++) {
        int j = i;
        if (self.hasBanner && i != 0 && i < (last - numberOfItemsPerLine) ) {
            j--;
        }
        
        if (last == j || (j+1 % numberOfItemsPerLine != 0)) {
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForDecorationViewOfKind:@"verticalSeparator" atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [decorationAttributes addObject:attributes];
        }
        if (((j+1) % numberOfItemsPerLine == 0 || j+1 == countOfItems) && j != countOfItems) {
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForDecorationViewOfKind:@"horizontalSeparator" atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [decorationAttributes addObject:attributes];
        }
    }
    return [decorationAttributes copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* currentItemAttributes =
    [super layoutAttributesForItemAtIndexPath:indexPath];
    
    UIEdgeInsets sectionInset = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout sectionInset];
    
    if (indexPath.item == 0) { // first item of section
        CGRect frame = currentItemAttributes.frame;
        frame.origin.x = sectionInset.left; // first item of the section should always be left aligned
        if (RI_IS_RTL) {
            frame.origin.x = self.collectionView.frame.size.width - frame.size.width;
        }
        
        currentItemAttributes.frame = frame;
        
        return currentItemAttributes;
    }
    
    NSIndexPath* previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
    CGRect previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
    CGFloat previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width + self.minimumLineSpacing;
    CGFloat previousFrameLeftPoint = previousFrame.origin.x - self.minimumLineSpacing;
    
    CGRect currentFrame = currentItemAttributes.frame;
    CGRect strecthedCurrentFrame = CGRectMake(0,
                                              currentFrame.origin.y,
                                              self.collectionView.frame.size.width,
                                              currentFrame.size.height);
    
    if (!CGRectIntersectsRect(previousFrame, strecthedCurrentFrame)) { // if current item is the first item on the line
        // the approach here is to take the current frame, left align it to the edge of the view
        // then stretch it the width of the collection view, if it intersects with the previous frame then that means it
        // is on the same line, otherwise it is on it's own new line
        CGRect frame = currentItemAttributes.frame;
        frame.origin.x = sectionInset.left; // first item on the line should always be left aligned
        if (RI_IS_RTL) {
            frame.origin.x = self.collectionView.frame.size.width - frame.size.width;
        }
        currentItemAttributes.frame = frame;
        return currentItemAttributes;
    }
    
    CGRect frame = currentItemAttributes.frame;
    frame.origin.x = previousFrameRightPoint;
    if (RI_IS_RTL) {
        frame.origin.x = previousFrameLeftPoint - frame.size.width;
    }
    currentItemAttributes.frame = frame;
    return [currentItemAttributes copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger countOfItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    CGRect itemFrame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
    
    UICollectionViewLayoutAttributes *layoutAttributes = [[UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath] copy];
    if ([decorationViewKind isEqualToString:@"horizontalSeparator"]) {
        if (RI_IS_RTL) {
            layoutAttributes.frame = CGRectMake(itemFrame.origin.x, itemFrame.origin.y + itemFrame.size.height, self.collectionViewContentSize.width - itemFrame.origin.x, self.minimumLineSpacing);
        }else{
            layoutAttributes.frame = CGRectMake(0.0, itemFrame.origin.y + itemFrame.size.height, itemFrame.origin.x + itemFrame.size.width, self.minimumLineSpacing);
        }
    }else if ([decorationViewKind isEqualToString:@"verticalSeparator"]){
        if (RI_IS_RTL) {
            layoutAttributes.frame = CGRectMake(itemFrame.origin.x, itemFrame.origin.y, self.minimumLineSpacing, self.itemSize.height);
        }else{
            layoutAttributes.frame = CGRectMake(itemFrame.origin.x + itemFrame.size.width, itemFrame.origin.y, self.minimumLineSpacing, self.itemSize.height);
        }
    }
    layoutAttributes.zIndex = 1000;
    
    return layoutAttributes;
}

@end
