//
//  BaseEmarsysRecommendationCollectionViewCell.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseEmarsysRecommendationCollectionViewCell.h"
#import "ImageManager.h"
#import "Bamilo-Swift.h"

@interface BaseEmarsysRecommendationCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountedPriceLabel;

@end

@implementation BaseEmarsysRecommendationCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (void)setupView {
    [self.titleLabel applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[UIColor blackColor]];
    [self.brandLabel applyStyle:[Theme font:kFontVariationRegular size:9.0f] color:[Theme color:kColorLightGray]];
    [self.priceLabel applyStyle:[Theme font:kFontVariationRegular size:9.0f] color: [Theme color:kColorLightGray]];
    [self.discountedPriceLabel applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[UIColor blackColor]];
    
    self.priceLabel.attributedText = (NSAttributedString *)[STRING_PRICE struckThroughText];
}

- (void)updateWithModel:(id)model {
    if (![model isKindOfClass:[RecommendItem class]]) {
        return;
    }
    
    RecommendItem *item = model;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:[ImageManager defaultPlaceholder]];
    [self.titleLabel setText:item.name];
    [self.brandLabel setText:item.brandName];
    [self.discountedPriceLabel setText:item.formattedDiscountedPrice];
    self.priceLabel.attributedText = (NSAttributedString *)[item.formattedPrice struckThroughText];
    if (item.price == item.dicountedPrice) {
        [self.priceLabel setHidden:YES];
    } else {
        [self.priceLabel setHidden:NO];
    }
}

- (void)prepareForReuse {
    self.imageView.image = nil;
    self.titleLabel.text = nil;
    self.brandLabel.text = nil;
    self.priceLabel.text = nil;
    self.discountedPriceLabel.text = nil;
}

+ (CGSize)preferedSize {
    return CGSizeMake(0,0);
}

@end
