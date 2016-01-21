//
//  JAProductCollectionViewFlowLayout.m
//  Jumia
//
//  Created by Jose Mota on 02/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAProductCollectionViewFlowLayout.h"

@interface JAProductCollectionViewFlowLayout ()
{
    NSMutableDictionary *_frameDictionary;
}

@end

@implementation JAProductCollectionViewFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* attributesToReturn = [super layoutAttributesForElementsInRect:rect];
    
    if (!VALID(_frameDictionary, NSMutableDictionary)) {
        _frameDictionary = [NSMutableDictionary new];
    }
    
    int init = (int)[(UICollectionViewLayoutAttributes*)[attributesToReturn firstObject] indexPath].row;
    int last = (int)[(UICollectionViewLayoutAttributes*)[attributesToReturn lastObject] indexPath].row;
    
    for (UICollectionViewLayoutAttributes* attributes in attributesToReturn) {
        if (last<attributes.indexPath.row) {
            last = (int)attributes.indexPath.row;
        }
        if (init>attributes.indexPath.row) {
            init = (int)attributes.indexPath.row;
        }
        NSIndexPath* indexPath = attributes.indexPath;
        if (nil == attributes.representedElementKind) {
            attributes.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
        }
    }
    return [attributesToReturn arrayByAddingObjectsFromArray:[self getLayoutAttributesForSeparatorsInRect:rect forInitIndex:init andLastIndex:last]];
}

- (NSArray*)getLayoutAttributesForSeparatorsInRect:(CGRect)rect forInitIndex:(NSInteger)init andLastIndex:(NSInteger)last {
    NSMutableArray* decorationAttributes = [NSMutableArray new];
    NSInteger numberOfItemsPerLine = floorf(rect.size.width / self.itemSize.width);
    NSInteger countOfItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    
    if (countOfItems == 0) {
        return nil;
    }
    
    for (int i = (int)init; i <= (int)last; i++) {
        if (countOfItems == i+1 || ((i+1) % numberOfItemsPerLine != 0)) {
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForDecorationViewOfKind:@"verticalSeparator" atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [decorationAttributes addObject:attributes];
        }
        if (((i+1) % numberOfItemsPerLine == 0 || i+1 == countOfItems) && i != countOfItems) {
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForDecorationViewOfKind:@"horizontalSeparator" atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [decorationAttributes addObject:attributes];
        }
    }
    return decorationAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewLayoutAttributes* currentItemAttributes = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
    
    UIEdgeInsets sectionInset = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout sectionInset];
    
    CGRect frame = currentItemAttributes.frame;
    CGRect strecthedCurrentFrame = CGRectMake(0,
                                              frame.origin.y,
                                              self.collectionView.frame.size.width,
                                              frame.size.height);
    NSValue *lastFrameValue = [_frameDictionary objectForKey:[NSNumber numberWithInteger:indexPath.row-1]];
    CGRect lastFrame = CGRectZero;
    if (lastFrameValue) {
        lastFrame = lastFrameValue.CGRectValue;
    }
    if (indexPath.item == 0) { // first item of section
        frame.origin.x = sectionInset.left; // first item of the section should always be left aligned
        if (RI_IS_RTL) {
            frame.origin.x = self.collectionView.frame.size.width - frame.size.width;
        }
        
    }else if (!CGRectIntersectsRect(lastFrame, strecthedCurrentFrame)) {
        frame.origin.x = sectionInset.left;
        if (RI_IS_RTL) {
            frame.origin.x = self.collectionView.frame.size.width - frame.size.width;
        }
    } else {
        CGFloat previousFrameRightPoint = lastFrame.origin.x + lastFrame.size.width + self.minimumLineSpacing;
        CGFloat previousFrameLeftPoint = lastFrame.origin.x - self.minimumLineSpacing;
        frame.origin.x = previousFrameRightPoint;
        if (RI_IS_RTL) {
            frame.origin.x = previousFrameLeftPoint - frame.size.width;
        }
    }
    currentItemAttributes.frame = frame;
    [_frameDictionary setObject:[NSValue valueWithCGRect:frame] forKey:[NSNumber numberWithInteger:indexPath.row]];
    return currentItemAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    NSValue *itemFrameValue = [_frameDictionary objectForKey:[NSNumber numberWithInteger:indexPath.row]];
    CGRect itemFrame = CGRectZero;
    if (itemFrameValue) {
        itemFrame = itemFrameValue.CGRectValue;
    }
    
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
