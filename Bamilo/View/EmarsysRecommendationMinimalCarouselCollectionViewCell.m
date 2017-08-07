//
//  EmarsysRecommendationMinimalCarouselCollectionViewCell.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationMinimalCarouselCollectionViewCell.h"

@interface EmarsysRecommendationMinimalCarouselCollectionViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation EmarsysRecommendationMinimalCarouselCollectionViewCell

- (void)setupView {
    [super setupView];
    [self.titleLabel applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[Theme color:kColorExtraDarkGray]];
}

+ (CGSize)preferedSize {
    return CGSizeMake(133, 197);
}

@end
