//
//  EmarsysRecommendationCarouselView.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationCarouselView.h"
#import "EmarsysRecommendationCarouselCollectionViewCell.h"
#import "Bamilo-Swift.h"

@interface EmarsysRecommendationCarouselView()

@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *carouselTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation EmarsysRecommendationCarouselView 

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setWidgetBacgkround:[UIColor clearColor]];
    [self.carouselTitle applyStyle:[Theme font:kFontVariationBold size:12.0f] color:[UIColor blackColor]];
    [self.collectionView registerNib:[UINib nibWithNibName:[EmarsysRecommendationCarouselCollectionViewCell nibName] bundle:nil]
          forCellWithReuseIdentifier:[EmarsysRecommendationCarouselCollectionViewCell nibName]];
    [self.activityIndicator startAnimating];
    [self.moreButton applyStyle:[Theme font:kFontVariationRegular size:11] color:[Theme color:kColorGray1]];
    [self.moreButton setTitle:STRING_MORE forState:UIControlStateNormal];
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
    EmarsysRecommendationCarouselCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[EmarsysRecommendationCarouselCollectionViewCell nibName] forIndexPath:indexPath];
    [cell updateWithModel:self.collectionItems[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [EmarsysRecommendationCarouselCollectionViewCell preferedSize];
}

- (IBAction)moreButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(moreButtonTappedInWidgetView:)]) {
        [self.delegate moreButtonTappedInWidgetView:self];
    }
}


@end
