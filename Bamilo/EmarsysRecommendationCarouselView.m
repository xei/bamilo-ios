//
//  EmarsysRecommendationCarouselView.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationCarouselView.h"
#import "EmarsysRecommendationCarouselCollectionViewCell.h"

@interface EmarsysRecommendationCarouselView()

@property (weak, nonatomic) IBOutlet UILabel *carouselTitle;

@end

@implementation EmarsysRecommendationCarouselView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setWidgetBacgkround:[UIColor clearColor]];
    [self.carouselTitle applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[UIColor blackColor]];
    
    [self.collectionView registerNib:[UINib nibWithNibName:[EmarsysRecommendationCarouselCollectionViewCell nibName] bundle:nil]
          forCellWithReuseIdentifier:[EmarsysRecommendationCarouselCollectionViewCell nibName]];
}

- (void)updateWithModel:(NSArray *)arrayModel {
    if ([arrayModel isKindOfClass:[NSArray<RecommendItem *> class]]) {
        [super updateWithModel:arrayModel];
    }
}

- (void)updateTitle:(NSString *)title {
    self.carouselTitle.text = title;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmarsysRecommendationCarouselCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[EmarsysRecommendationCarouselCollectionViewCell nibName] forIndexPath:indexPath];
    [cell updateWithModel:self.collectionItems[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [EmarsysRecommendationCarouselCollectionViewCell preferedSize];
}

@end
