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
    CGRect _recentProductImageViewRect;
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

- (UIImageView *)recentProductImageView
{
    if (!VALID_NOTEMPTY(_recentProductImageView, UIImageView)) {
        NSString *langCode = [[NSUserDefaults standardUserDefaults] stringForKey:kLanguageCodeKey];
        NSString* imageName = @"ProductBadgeNew_";
        if (NSNotFound != [langCode rangeOfString:@"fr"].location) {
            imageName = [imageName stringByAppendingString:@"fr"];
        } else if (NSNotFound != [langCode rangeOfString:@"fa"].location) {
            imageName = [imageName stringByAppendingString:@"fa"];
        } else if (NSNotFound != [langCode rangeOfString:@"pt"].location) {
            imageName = [imageName stringByAppendingString:@"pt"];
        } else {
            imageName = [imageName stringByAppendingString:@"en"];
        }
        
        _recentProductImageViewRect = CGRectMake(0, 0, 48, 48);
        _recentProductImageView = [[UIImageView alloc] initWithFrame:_recentProductImageViewRect];
        UIImage* recentProductImage = [UIImage imageNamed:imageName];
        [_recentProductImageView setImage:recentProductImage];
    }
    return _recentProductImageView;
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

- (UIButton *)sizeButton
{
    if (!VALID_NOTEMPTY(_sizeButton, UIButton)) {
        
        CGRect frame = CGRectMake(self.priceLine.frame.origin.x, self.priceLine.frame.origin.y+20.0f,
                                  self.frame.size.width, self.priceLine.frame.size.height);
        
        _sizeButton = [[UIButton alloc] initWithFrame:(frame)];
        _sizeButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:_sizeButton.titleLabel.font.pointSize];
        [_sizeButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
        [_sizeButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
        [_sizeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_sizeButton.titleLabel sizeToFit];
    }
    return _sizeButton;
}

- (void)initViews
{
    [self addSubview:self.feedbackView];
    [self addSubview:self.productImageView];
    [self addSubview:self.brandLabel];
    [self addSubview:self.nameLabel];
    [self addSubview:self.favoriteButton];
    [self addSubview:self.recentProductImageView];
    [self addSubview:self.priceLine];
    [self addSubview:self.sizeButton];
    [self addSubview:self.discountLabel];
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
        [self.priceLine setTitle:product.priceRange];
        [self.priceLine setOldPrice:nil];
    } else if (VALID_NOTEMPTY(product.specialPriceFormatted, NSString)) {
        [self.priceLine setTitle:product.specialPriceFormatted];
        [self.priceLine setOldPrice:product.priceFormatted];
    }else{
        [self.priceLine setTitle:product.priceFormatted];
        [self.priceLine setOldPrice:nil];
    }
    
    
    _favoriteButton.selected = VALID_NOTEMPTY(product.favoriteAddDate, NSDate);
    
    _recentProductImageView.hidden = ![product.isNew boolValue];
    
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
    
    if (VALID_NOTEMPTY(variation.price, NSString)) {
        [self.priceLine setTitle:[RICountryConfiguration formatPrice:[[NSNumberFormatter new] numberFromString:variation.price] country:[RICountryConfiguration getCurrentConfiguration]]];
        [self.priceLine setOldPrice:nil];
    }
    
    self.recentProductImageView.hidden = YES;
    self.discountLabel.hidden = YES;
    self.favoriteButton.hidden = YES;
}

- (void)loadWithProductSimple:(RIProductSimple *)productSimple
{
    
}

@end
