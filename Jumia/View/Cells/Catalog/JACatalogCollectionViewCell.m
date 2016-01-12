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
}

@end


@implementation JACatalogCollectionViewCell

- (JAClickableView *)feedbackView
{
    if (!VALID_NOTEMPTY(_feedbackView, JAClickableView)) {
        _feedbackView = [[JAClickableView alloc] initWithFrame:self.bounds];
    }
    return _feedbackView;
}

- (UIImageView *)productImageView
{
    if (!VALID_NOTEMPTY(_productImageView, UIImageView)) {
        _productImageView = [[UIImageView alloc] init];
    }
    return _productImageView;
}

- (UILabel *)brandLabel
{
    if (!VALID_NOTEMPTY(_brandLabel, UILabel)) {
        _brandLabel = [[UILabel alloc] init];
        [_brandLabel setFont:JACaptionFont];
        [_brandLabel setText:@"BrandLabel"];
        _brandLabel.textColor = UIColorFromRGB(0x808080);
    }
    return _brandLabel;
}

- (UILabel *)nameLabel
{
    if (!VALID_NOTEMPTY(_nameLabel, UILabel)) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:JABody3Font];
        [_nameLabel setText:@"NameLabel"];
        _nameLabel.textColor = UIColorFromRGB(0x000000);
    }
    return _nameLabel;
}

- (UILabel *)discountLabel
{
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

- (UIButton *)favoriteButton
{
    if (!VALID_NOTEMPTY(_favoriteButton, UIButton)) {
        _favoriteButtonRect = CGRectMake(0, 10, 18, 18);
        _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_favoriteButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
        [_favoriteButton setFrame:_favoriteButtonRect];
        [_favoriteButton setImage:[UIImage imageNamed:@"FavButton"] forState:UIControlStateNormal];
        [_favoriteButton setImage:[UIImage imageNamed:@"FavButtonPressed"] forState:UIControlStateSelected];
    }
    return _favoriteButton;
}

- (UILabel *)recentProductBadgeLabel
{
    if (!VALID_NOTEMPTY(_recentProductBadgeLabel, UILabel)) {
        _recentProductBadgeLabelRect = CGRectMake(0, 10, 200, 20);
        _recentProductBadgeLabel = [[UILabel alloc] initWithFrame:_recentProductBadgeLabelRect];
        [_recentProductBadgeLabel setFont:JABadgeFont];
        [_recentProductBadgeLabel setBackgroundColor:JABlack700Color];
        [_recentProductBadgeLabel setTextColor:[UIColor whiteColor]];
        [_recentProductBadgeLabel setTextAlignment:NSTextAlignmentCenter];
        [_recentProductBadgeLabel setText:[STRING_NEW uppercaseString]];
        [_recentProductBadgeLabel sizeToFit];
        [_recentProductBadgeLabel setWidth:_recentProductBadgeLabel.width + 8];
        [_recentProductBadgeLabel setHeight:_recentProductBadgeLabel.height + 12];
    }
    return _recentProductBadgeLabel;
}

- (JAProductInfoPriceLine *)priceLine
{
    if (!VALID_NOTEMPTY(_priceLine, JAProductInfoPriceLine)) {
        _priceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(0, 0, self.width, 15)];
        [_priceLine setPriceSize:kPriceSizeSmall];
        [_priceLine setLineContentXOffset:0.f];
    }
    return _priceLine;
}

- (JADropdownControl *)sizeButton
{
    if (!VALID_NOTEMPTY(_sizeButton, UIButton)) {
        
        CGRect frame = CGRectMake(self.priceLine.frame.origin.x, self.priceLine.frame.origin.y+20.0f,
                                  100, 20.f);
        _sizeButton = [JADropdownControl buttonWithType:UIButtonTypeSystem];
        [_sizeButton setFrame:frame];
    }
    return _sizeButton;
}

- (UIImageView*)shopFirstImageView
{
    if (!VALID_NOTEMPTY(_shopFirstImageView, UIImageView)) {
        
        UIImage *shopFirstImage = [UIImage imageNamed:@"shop_first_logo"];
        _shopFirstImageView = [[UIImageView alloc] initWithImage:shopFirstImage];
    }
    return _shopFirstImageView;
}

- (void)initViews
{
    [self addSubview:self.feedbackView];
    [self addSubview:self.productImageView];
    [self addSubview:self.brandLabel];
    [self addSubview:self.nameLabel];
    [self addSubview:self.favoriteButton];
    [self addSubview:self.recentProductBadgeLabel];
    [self addSubview:self.priceLine];
    [self addSubview:self.sizeButton];
    [self addSubview:self.discountLabel];
    [self addSubview:self.shopFirstImageView];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setClipsToBounds:YES];
}

- (void)reloadViews
{
    self.feedbackView.frame = self.bounds;
    _lastWidth = self.width;
}

- (void)reloadGridViews
{
}

- (void)prepareForReuse
{
    //    NSLog(@"prepareForReuse");
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [self.favoriteButton setTag:tag];
    [self.feedbackView setTag:tag];
    [self.sizeButton setTag:tag];
}

- (void)loadWithProduct:(RIProduct*)product
{
    _product = product;
    [_brandLabel setText:product.brand];
    [_nameLabel setText:product.name];
    
    RIImage* firstImage = [product.images firstObject];
    
    [_productImageView setImageWithURL:[NSURL URLWithString:firstImage.url]
                      placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    
    if (VALID_NOTEMPTY(product.priceRange, NSString)) {
        [self.priceLine setPrice:product.priceRange];
        if (VALID_NOTEMPTY(product.specialPriceFormatted, NSString)) {
            [self.priceLine setOldPrice:product.priceFormatted];
        }
    } else if (VALID_NOTEMPTY(product.specialPriceFormatted, NSString)) {
        [self.priceLine setPrice:product.specialPriceFormatted];
        [self.priceLine setOldPrice:product.priceFormatted];
    } else {
        [self.priceLine setPrice:product.priceFormatted];
        [self.priceLine setOldPrice:nil];
    }
    
    if (VALID_NOTEMPTY(product.shopFirst, NSNumber) && [product.shopFirst boolValue]) {
        self.shopFirstImageView.hidden = NO;
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
    _discountLabel.font = JACaptionFont;
}

- (void)loadWithVariation:(RIVariation *)variation
{
    _variation = variation;
    [_brandLabel setText:variation.brand];
    [_nameLabel setText:variation.name];
    
    
    RIImage* firstImage = variation.image;
    
    [_productImageView setImageWithURL:[NSURL URLWithString:firstImage.url]
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
}


- (void)setSimplePrice:(NSString *)price andOldPrice:(NSString *)oldPrice
{
    if (!oldPrice) {
        [self.product setPriceFormatted:price];
        [self.product setSpecialPriceFormatted:nil];
    }else{
        [self.product setPriceFormatted:oldPrice];
        [self.product setSpecialPriceFormatted:price];
    }
    [self loadWithProduct:self.product];
}

@end
