//
//  EmarsysRecommendationMinimalCarouselWidgetView.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationMinimalCarouselWidgetView.h"
#import "EmarsysRecommendationMinimalCarouselCollectionViewCell.h"

@interface EmarsysRecommendationMinimalCarouselWidgetView()

@property (weak, nonatomic) IBOutlet UILabel *carouselTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation EmarsysRecommendationMinimalCarouselWidgetView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setWidgetBacgkround:[UIColor clearColor]];
    [self.carouselTitle applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[UIColor blackColor]];
    [self.collectionView registerNib:[UINib nibWithNibName:[EmarsysRecommendationMinimalCarouselCollectionViewCell nibName] bundle:nil]
          forCellWithReuseIdentifier:[EmarsysRecommendationMinimalCarouselCollectionViewCell nibName]];
    [self.activityIndicator startAnimating];
}


- (void)updateWithModel:(NSArray *)arrayModel {
    if ([arrayModel isKindOfClass:[NSArray<RecommendItem *> class]]) {
        if (arrayModel.count) {
            [self.activityIndicator stopAnimating];
        }
        [super updateWithModel:arrayModel];
    }
}

- (void)updateTitle:(NSString *)title {
    self.carouselTitle.text = title;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmarsysRecommendationMinimalCarouselCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[EmarsysRecommendationMinimalCarouselCollectionViewCell nibName] forIndexPath:indexPath];
    [cell updateWithModel:self.collectionItems[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [EmarsysRecommendationMinimalCarouselCollectionViewCell preferedSize];
}

@end
