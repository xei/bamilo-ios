//
//  EmarsysRecommendationGridWidgetView.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationGridWidgetView.h"
#import "EmarsysRecommendationCarouselCollectionViewCell.h"

@interface EmarsysRecommendationGridWidgetView()

@property (nonatomic, weak) IBOutlet UILabel *widgetTitle;
@property (nonatomic, weak) IBOutlet UIButton *leftButton;

@end

@implementation EmarsysRecommendationGridWidgetView

const CGFloat cellSpace = 2;
const int numberOfColumns = 2;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setWidgetBacgkround:[UIColor clearColor]];
    [self.leftButton setHidden:YES];
    
    [self.widgetTitle applyStyle:[Theme font:kFontVariationBold size:11.0f] color:[UIColor blackColor]];
    [self.collectionView registerNib:[UINib nibWithNibName:[EmarsysRecommendationCarouselCollectionViewCell nibName] bundle:nil] forCellWithReuseIdentifier:[EmarsysRecommendationCarouselCollectionViewCell nibName]];
}

- (void)updateLeftButtonTitle:(NSString *)title {
    [self.leftButton setHeight:NO];
    [self.leftButton setTitle:title forState:UIControlStateNormal];
}

- (void)updateTitle:(NSString *)title {
    self.widgetTitle.text = title;
}

- (void)updateWithModel:(NSArray *)arrayModel {
    if ([arrayModel isKindOfClass:[NSArray<RecommendItem *> class]]) {
        [super updateWithModel:arrayModel];
    }
}

+ (CGFloat)preferredHeightWithContentModel:(NSArray<RecommendItem *> *)arrayModel boundWidth:(CGFloat)width {
    const CGFloat collectionViewTopConstrint = 40;
    const CGFloat collectionViewMarginConstrint = 15;
    const int collectionItemsRowsCount = ceil(arrayModel.count / (CGFloat)numberOfColumns);
    
    CGSize cellPrefferedSize = [EmarsysRecommendationCarouselCollectionViewCell preferedSize];
    CGFloat ratio = cellPrefferedSize.height / cellPrefferedSize.width;
    CGFloat cellItemWidth = (width - (collectionViewMarginConstrint * 2) - (numberOfColumns - 1) * cellSpace) / numberOfColumns;
    
    return collectionViewTopConstrint +
    collectionViewMarginConstrint +
    collectionItemsRowsCount * (ratio * cellItemWidth) +
    (collectionItemsRowsCount - 1) * cellSpace;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmarsysRecommendationCarouselCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[EmarsysRecommendationCarouselCollectionViewCell nibName] forIndexPath:indexPath];
    [cell updateWithModel:self.collectionItems[indexPath.row]];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return cellSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return cellSpace;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize cellPrefferedSize = [EmarsysRecommendationCarouselCollectionViewCell preferedSize];
    CGFloat ratio = cellPrefferedSize.height / cellPrefferedSize.width;
    
    CGFloat itemWidth = (CGRectGetWidth(self.collectionView.frame) - ((numberOfColumns - 1) * cellSpace)) / numberOfColumns;
    return CGSizeMake(itemWidth, itemWidth * ratio);
}

@end
