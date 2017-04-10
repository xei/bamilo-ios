//
//  EmarsysRecommendationCarouselCollectionViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationCarouselCollectionViewCell.h"
#import "RIProduct.h"

@interface EmarsysRecommendationCarouselCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountedPriceLabel;
@end

@implementation EmarsysRecommendationCarouselCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (void) setupView {
    [self.titleLabel applyStyle:[Theme font:kFontVariationRegular size:9.0f] color:[UIColor blackColor]];
    [self.brandLabel applyStyle:[Theme font:kFontVariationRegular size:9.0f] color:[Theme color:kColorLightGray]];
    [self.priceLabel applyStyle:[Theme font:kFontVariationRegular size:9.0f] color:[UIColor blackColor]];
    [self.discountedPriceLabel applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[Theme color:kColorExtraDarkGray]];
    
    self.discountedPriceLabel.attributedText = (NSAttributedString *)[STRING_PRICE struckThroughText];
}

- (void)updateWithModel:(id)model {
    if (![model isKindOfClass:[RecommendItem class]]) {
        return;
    }

}

@end
