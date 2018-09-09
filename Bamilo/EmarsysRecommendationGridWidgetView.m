//
//  EmarsysRecommendationGridWidgetView.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationGridWidgetView.h"
#import "EmarsysRecommendationCarouselCollectionViewCell.h"
#import "Bamilo-Swift.h"

@interface EmarsysRecommendationGridWidgetView()

@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
@end

@implementation EmarsysRecommendationGridWidgetView

const CGFloat cellSpace = 5;
const int numberOfColumns = 2;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setWidgetBacgkround:[UIColor clearColor]];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.moreButton applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[Theme color:kColorBlue]];
    [self.moreButton setTitle:[NSString stringWithFormat:@"%@ %@", STRING_ALL, STRING_RELATED_ITEMS] forState:UIControlStateNormal];
    [self.collectionView registerNib:[UINib nibWithNibName:[EmarsysRecommendationCarouselCollectionViewCell nibName] bundle:nil] forCellWithReuseIdentifier:[EmarsysRecommendationCarouselCollectionViewCell nibName]];
}

- (IBAction)moreButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(moreButtonTappedInWidgetView:)]) {
        [self.delegate moreButtonTappedInWidgetView:self];
    }
}

- (void)updateWithModel:(NSArray *)arrayModel {
    if ([arrayModel isKindOfClass:[NSArray<RecommendItem *> class]]) {
        [super updateWithModel:arrayModel];
        CGFloat contentWidth = UIScreen.mainScreen.bounds.size.width - 8 * 2;
        self.collectionViewHeightConstraint.constant = [self collectionViewHeightWithContentModel: arrayModel
                                                                                       boundWidth: contentWidth];
    }
}

- (CGFloat)collectionViewHeightWithContentModel:(NSArray<RecommendItem *> *)arrayModel boundWidth:(CGFloat)width {
    const int collectionItemsRowsCount = ceil(arrayModel.count / (CGFloat)numberOfColumns);
    
    CGSize cellPrefferedSize = [EmarsysRecommendationCarouselCollectionViewCell preferedSize];
    CGFloat ratio = cellPrefferedSize.height / cellPrefferedSize.width;
    CGFloat cellItemWidth = (width - (numberOfColumns - 1) * cellSpace) / numberOfColumns;
    return collectionItemsRowsCount * (ratio * cellItemWidth) + (collectionItemsRowsCount - 1) * cellSpace;
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
