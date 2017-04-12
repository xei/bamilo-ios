//
//  EmarsysRecommendationCarouselCollectionViewCell.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationCarouselCollectionViewCell.h"
#import "RIProduct.h"
#import "ImageManager.h"

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
    [self.titleLabel applyStyle:[Theme font:kFontVariationBold size:8.0f] color:[UIColor blackColor]];
    [self.brandLabel applyStyle:[Theme font:kFontVariationRegular size:8.0f] color:[Theme color:kColorLightGray]];
    [self.priceLabel applyStyle:[Theme font:kFontVariationRegular size:8.0f] color: [Theme color:kColorLightGray]];
    [self.discountedPriceLabel applyStyle:[Theme font:kFontVariationBold size:8.0f] color: [UIColor blackColor]];
    
    self.discountedPriceLabel.attributedText = (NSAttributedString *)[STRING_PRICE struckThroughText];
}

- (void)updateWithModel:(id)model {
    if (![model isKindOfClass:[RecommendItem class]]) {
        return;
    }
    RecommendItem *item = model;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:[ImageManager defaultPlaceholder]];
    [self.titleLabel setText:item.name];
    [self.brandLabel setText:item.brandName];
    [self.priceLabel setText:item.formattedDiscountedPrice];
    self.discountedPriceLabel.attributedText = (NSAttributedString *)[item.formattedPrice struckThroughText];
}

- (void)prepareForReuse {
    self.imageView.image = nil;
    self.titleLabel.text = nil;
    self.brandLabel.text = nil;
    self.priceLabel.text = nil;
    self.discountedPriceLabel.text = nil;
}

@end
