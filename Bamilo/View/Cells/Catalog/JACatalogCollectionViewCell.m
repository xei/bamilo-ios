//
//  JACatalogCollectionViewCell.m
//  Jumia
//
//  Created by josemota on 7/3/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACatalogCollectionViewCell.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"
#import "RILanguage.h"
#import "JAStrings.h"

@interface JACatalogCollectionViewCell () {
    CGFloat _lastWidth;
    CGFloat _textWidth;
    CGRect _brandLabelRect;
    CGRect _nameLabelRect;
    CGRect _productImageViewRect;
    CGRect _recentProductBadgeLabelRect;
    CGRect _favoriteButtonRect;
    CGRect _discountLabelRect;
    CGRect _sizeButtonRect;
    CGRect _sizeLabelRect;
    BOOL _ratingRefresh;
}

@end


@implementation JACatalogCollectionViewCell

- (JAClickableView *)feedbackView {
    if (!VALID_NOTEMPTY(_feedbackView, JAClickableView)) {
        _feedbackView = [[JAClickableView alloc] initWithFrame:self.bounds];
    }
    return _feedbackView;
}

- (UIImageView *)productImageView {
    if (!VALID_NOTEMPTY(_productImageView, UIImageView)) {
        _productImageView = [[UIImageView alloc] init];
    }
    return _productImageView;
}

- (UILabel *)brandLabel {
    if (!VALID_NOTEMPTY(_brandLabel, UILabel)) {
        _brandLabel = [[UILabel alloc] init];
        [_brandLabel setFont:JACaptionFont];
        [_brandLabel setText:@"BrandLabel"];
        _brandLabel.textColor = JABlack800Color;
    }
    return _brandLabel;
}

- (UILabel *)nameLabel {
    if (!VALID_NOTEMPTY(_nameLabel, UILabel)) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:JABodyFont];
        [_nameLabel setText:@"NameLabel"];
        _nameLabel.textColor = JABlackColor;
    }
    return _nameLabel;
}

- (UILabel *)discountLabel {
    if (!VALID_NOTEMPTY(_discountLabel, UILabel)) {
        _discountLabel = [[UILabel alloc] init];
        [_discountLabel setFont:JACaptionFont];
        [_discountLabel setText:@"DiscountLabel"];
        [_discountLabel setTextColor:JAOrange1Color];
        [_discountLabel setTextAlignment:NSTextAlignmentCenter];
        _discountLabel.layer.borderColor = [JAOrange1Color CGColor];
        _discountLabel.layer.borderWidth = 1.0f;
    }
    return _discountLabel;
}

- (UIButton *)favoriteButton {
    if (!VALID_NOTEMPTY(_favoriteButton, UIButton)) {
        _favoriteButtonRect = CGRectMake(16, 16, 18, 18);
        _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_favoriteButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
        [_favoriteButton setFrame:_favoriteButtonRect];
        [_favoriteButton setImage:[UIImage imageNamed:@"FavButton"] forState:UIControlStateNormal];
        [_favoriteButton setImage:[UIImage imageNamed:@"FavButtonPressed"] forState:UIControlStateSelected];
    }
    return _favoriteButton;
}

- (UILabel *)recentProductBadgeLabel {
    if (!VALID_NOTEMPTY(_recentProductBadgeLabel, UILabel)) {
        _recentProductBadgeLabelRect = CGRectMake(0, 10, 200, 16);
        _recentProductBadgeLabel = [[UILabel alloc] initWithFrame:_recentProductBadgeLabelRect];
        [_recentProductBadgeLabel setFont:JABADGEFont];
        [_recentProductBadgeLabel setBackgroundColor:JABlack700Color];
        [_recentProductBadgeLabel setTextColor:[UIColor whiteColor]];
        [_recentProductBadgeLabel setTextAlignment:NSTextAlignmentCenter];
        [_recentProductBadgeLabel setText:[STRING_NEW uppercaseString]];
        [_recentProductBadgeLabel sizeToFit];
        [_recentProductBadgeLabel setWidth:_recentProductBadgeLabel.width + 4];
        [_recentProductBadgeLabel setHeight:_recentProductBadgeLabel.height + 2];
    }
    return _recentProductBadgeLabel;
}

- (JAProductInfoPriceLine *)priceLine {
    if (!VALID_NOTEMPTY(_priceLine, JAProductInfoPriceLine)) {
        _priceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(0, 0, self.width, 15)];
        [_priceLine setPriceSize:JAPriceSizeSmall];
        [_priceLine setLineContentXOffset:0.f];
    }
    return _priceLine;
}

- (JAProductInfoRatingLine *)ratingLine {
    if (!VALID_NOTEMPTY(_ratingLine, JAProductInfoRatingLine)) {
        _ratingLine = [[JAProductInfoRatingLine alloc] initWithFrame:CGRectZero];
        _ratingLine.imageRatingSize = kImageRatingSizeSmall;
        _ratingLine.lineContentXOffset = 0.f;
        _ratingLine.topSeparatorVisibility = NO;
        _ratingLine.bottomSeparatorVisibility = NO;
    }
    return _ratingLine;
}

- (void)setHideRating:(BOOL)hideRating {
    _hideRating = hideRating;
    [self.nameLabel setNumberOfLines:2];
}

- (JADropdownControl *)sizeButton {
    if (!VALID_NOTEMPTY(_sizeButton, UIButton)) {
        
        CGRect frame = CGRectMake(self.priceLine.frame.origin.x, self.priceLine.frame.origin.y+20.0f,
                                  100, 20.f);
        _sizeButton = [JADropdownControl buttonWithType:UIButtonTypeSystem];
        [_sizeButton setFrame:frame];
    }
    return _sizeButton;
}

- (UIImageView*)shopFirstImageView {
    if (!VALID_NOTEMPTY(_shopFirstImageView, UIImageView)) {
        
        UIImage *shopFirstImage = [UIImage imageNamed:@"shop_first_logo"];
        _shopFirstImageView = [[UIImageView alloc] initWithImage:shopFirstImage];
    }
    return _shopFirstImageView;
}

- (void)setHideShopFirstLogo:(BOOL)hideShopFirstLogo {
    _hideShopFirstLogo = hideShopFirstLogo;
}

- (void)initViews {
    [self addSubview:self.feedbackView];
    [self addSubview:self.productImageView];
    [self addSubview:self.brandLabel];
    [self addSubview:self.nameLabel];
    [self addSubview:self.favoriteButton];
    [self addSubview:self.recentProductBadgeLabel];
    [self addSubview:self.priceLine];
    [self addSubview:self.ratingLine];
    [self addSubview:self.sizeButton];
    [self addSubview:self.discountLabel];
    [self addSubview:self.shopFirstImageView];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setClipsToBounds:YES];
}

- (void)reloadViews {
    self.feedbackView.frame = self.bounds;
    _lastWidth = self.width;
}

- (void)reloadGridViews {
}

- (void)prepareForReuse {
    //    NSLog(@"prepareForReuse");
}

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    [self.favoriteButton setTag:tag];
    [self.feedbackView setTag:tag];
    [self.sizeButton setTag:tag];
}

- (void)setProduct:(RIProduct*)product {
    _product = product;
    [_brandLabel setText:product.brand];
    [_nameLabel setText:product.name];
    
    RIImage* firstImage = [product.images firstObject];
    
    [_productImageView sd_setImageWithURL:[NSURL URLWithString:firstImage.url]
                      placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    
    if (VALID_NOTEMPTY(product.priceRange, NSString)) {
        [self.priceLine setPrice:product.priceRange];
        [self.priceLine setOldPrice:nil];
    } else if (VALID_NOTEMPTY(product.specialPriceFormatted, NSString)) {
        [self.priceLine setPrice:product.specialPriceFormatted];
        [self.priceLine setOldPrice:product.priceFormatted];
    } else {
        [self.priceLine setPrice:product.priceFormatted];
        [self.priceLine setOldPrice:nil];
    }
    
    if (VALID_NOTEMPTY(product.shopFirst, NSNumber) && [product.shopFirst boolValue]) {
        if (self.hideShopFirstLogo) {
            [self.shopFirstImageView setHidden:YES];
        } else {
            [self.shopFirstImageView setHidden:NO];
        }
    } else {
        self.shopFirstImageView.hidden = YES;
    }
    
    _favoriteButton.selected = VALID_NOTEMPTY(product.favoriteAddDate, NSDate);
    
    self.recentProductBadgeLabel.hidden = ![product.isNew boolValue];
    
    CGFloat priceXOffset = JACatalogCellPriceLabelOffsetX;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        priceXOffset = JACatalogCellPriceLabelOffsetX_ipad;
    }
    
    _discountLabel.text = [NSString stringWithFormat:STRING_FORMAT_OFF,[product.maxSavingPercentage integerValue]];
    _discountLabel.hidden = !product.maxSavingPercentage;
    if (VALID_NOTEMPTY(product.priceRange, NSString)) {
        _discountLabel.hidden = YES;
    }
    _discountLabel.font = JACaptionFont;
    [_discountLabel sizeToFit];
    _discountLabel.frame = CGRectMake(0.0f, 0.0f, _discountLabel.width+8, 16.0f);
    

    if (!self.hideRating) {
        if (0 == [product.sum integerValue] ) {
            [self.ratingLine setHidden:YES];
        }else
            [self.ratingLine setHidden:NO];
        
        self.ratingLine.ratingAverage = product.avr;
        self.ratingLine.ratingSum = product.sum;
        
        BOOL refresh = NO;
        if (0 != [product.sum integerValue]) {
            
            if (!_ratingRefresh) {
                refresh = YES;
                _ratingRefresh = YES;
            }
        }
    } else {
        [self.ratingLine setHidden:YES];
    }
}

- (void)setVariation:(RIVariation *)variation {
    _variation = variation;
    [_brandLabel setText:variation.brand];
    [_nameLabel setText:variation.name];
    
    
    RIImage* firstImage = variation.image;
    
    [_productImageView sd_setImageWithURL:[NSURL URLWithString:firstImage.url]
                      placeholderImage:[UIImage imageNamed:@"placeholder_list"]];

    if (VALID_NOTEMPTY(variation.specialPrice, NSNumber)) {
        [self.priceLine setPrice:[RICountryConfiguration formatPrice:variation.specialPrice country:[RICountryConfiguration getCurrentConfiguration]]];
        [self.priceLine setOldPrice:[RICountryConfiguration formatPrice:variation.price country:[RICountryConfiguration getCurrentConfiguration]]];
    }else{
        [self.priceLine setPrice:[RICountryConfiguration formatPrice:variation.price country:[RICountryConfiguration getCurrentConfiguration]]];
        [self.priceLine setOldPrice:nil];
    }
    
    self.recentProductBadgeLabel.hidden = YES;
    //self.recentProductImageView.hidden = YES;
    self.discountLabel.hidden = YES;
    self.favoriteButton.hidden = YES;
    self.ratingLine.hidden = YES;
    
    if (self.hideShopFirstLogo) {
        [self.shopFirstImageView setHidden:YES];
    } else {
        [self.shopFirstImageView setHidden:NO];
    }
}


- (void)setSimplePrice:(NSString *)price andOldPrice:(NSString *)oldPrice {
    if (!oldPrice) {
        [self.product setPriceFormatted:price];
        [self.product setSpecialPriceFormatted:nil];
    }else{
        [self.product setPriceFormatted:oldPrice];
        [self.product setSpecialPriceFormatted:price];
    }
    [self setProduct:self.product];
}

@end
