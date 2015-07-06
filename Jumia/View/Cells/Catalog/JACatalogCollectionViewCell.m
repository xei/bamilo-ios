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

@interface JACatalogCollectionViewCell () {
    CGFloat _lastWidth;
    CGFloat _textWidth;
    CGRect _brandLabelRect;
    CGRect _nameLabelRect;
    CGRect _productImageViewRect;
    CGRect _recentProductImageViewRect;
    CGRect _favoriteButtonRect;
    CGRect _discountImageViewRect;
    CGRect _discountLabelRect;
    CGRect _sizeButtonRect;
    CGRect _sizeLabelRect;
}

@end


@implementation JACatalogCollectionViewCell

@synthesize productImageView = _productImageView, brandLabel = _brandLabel, nameLabel = _nameLabel, recentProductImageView = _recentProductImageView, favoriteButton = _favoriteButton, discountImageView = _discountImageView, discountLabel = _discountLabel, sizeButton = _sizeButton, priceView = _priceView, feedbackView = _feedbackView, grid = _grid;

- (void)initViews
{
    _feedbackView = [[JAClickableView alloc] initWithFrame:self.bounds];
    [self addSubview:_feedbackView];
    
    _brandLabel = [[UILabel alloc] init];
    [_brandLabel setFont:[UIFont fontWithName:kFontRegularName size:13]];
    [_brandLabel setText:@"BrandLabel"];
    _brandLabel.textColor = UIColorFromRGB(0x666666);
    [self addSubview:_brandLabel];
    
    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setFont:[UIFont fontWithName:kFontRegularName size:12]];
    [_nameLabel setText:@"NameLabel"];
    _nameLabel.textColor = UIColorFromRGB(0x666666);
    [self addSubview:_nameLabel];
    
    _productImageView = [[UIImageView alloc] init];
    [self addSubview:_productImageView];
    
    _discountImageView = [[UIImageView alloc] init];
    [_discountImageView setImage:[UIImage imageNamed:@"img_badge_discount"]];
    [self addSubview:_discountImageView];
    
    _discountLabel = [[UILabel alloc] init];
    [_discountLabel setFont:[UIFont fontWithName:kFontBoldName size:8]];
    [_discountLabel setText:@"DiscountLabel"];
    [_discountLabel setTextColor:[UIColor whiteColor]];
    [_discountLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_discountLabel];
    
    _favoriteButtonRect = CGRectMake(0, 10, 24, 24);
    _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_favoriteButton setFrame:_favoriteButtonRect];
    [_favoriteButton setImage:[UIImage imageNamed:@"FavButton"] forState:UIControlStateNormal];
    [_favoriteButton setImage:[UIImage imageNamed:@"FavButtonPressed"] forState:UIControlStateSelected];
    [self addSubview:_favoriteButton];
    [_favoriteButton setXRightAligned:6.f];
    _favoriteButtonRect = _favoriteButton.frame;
    
    RICountryConfiguration* config = [RICountryConfiguration getCurrentConfiguration];
    RILanguage* language = [config.languages firstObject];
    NSString* imageName = @"ProductBadgeNew_";
    if (NSNotFound != [language.langCode rangeOfString:@"fr"].location) {
        imageName = [imageName stringByAppendingString:@"fr"];
    } else if (NSNotFound != [language.langCode rangeOfString:@"fa"].location) {
        imageName = [imageName stringByAppendingString:@"fa"];
    } else if (NSNotFound != [language.langCode rangeOfString:@"pt"].location) {
        imageName = [imageName stringByAppendingString:@"pt"];
    } else {
        imageName = [imageName stringByAppendingString:@"en"];
    }
    
    _recentProductImageViewRect = CGRectMake(0, 0, 48, 48);
    _recentProductImageView = [[UIImageView alloc] initWithFrame:_recentProductImageViewRect];
    UIImage* recentProductImage = [UIImage imageNamed:imageName];
    [_recentProductImageView setImage:recentProductImage];
    
    [self addSubview:_recentProductImageView];
    
    _priceView = [[JAPriceView alloc] init];
    [self addSubview:_priceView];
    
    if (_grid) {
        [self initGridViews];
    }else{
        [self initListViews];
    }
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setClipsToBounds:YES];
    [self.layer setCornerRadius:3.f];
}

- (void)initListViews
{
    _textWidth = self.width - 80 - 30;
    
    _brandLabelRect = CGRectMake(80, 9, _textWidth, 15);
    [_brandLabel setFrame:_brandLabelRect];
    
    _nameLabelRect = CGRectMake(80, 26, _textWidth, 15);
    [_nameLabel setFrame:_nameLabelRect];
    
    _productImageViewRect = CGRectMake(6, 8, 68, 85);
    [_productImageView setFrame:_productImageViewRect];
    
    _discountImageViewRect = CGRectMake(0, 71, 26, 14);
    [_discountImageView setFrame:_discountImageViewRect];
    [_discountImageView setXRightAligned:6.f];
    _discountImageViewRect = _discountImageView.frame;
    
    _discountLabelRect = CGRectMake(0, 71, 26, 14);
    [_discountLabel setFrame:_discountLabelRect];
    [_discountLabel setXRightAligned:6.f];
    _discountLabelRect = _discountLabel.frame;
    
    [_priceView setFrame:CGRectMake(80, 0, _textWidth, 50)];
}

- (void)initGridViews
{
    _textWidth = self.width - 6 - 6;
    _brandLabelRect = CGRectMake(6, 148, _textWidth, 15);
    [_brandLabel setFrame:_brandLabelRect];
    
    _nameLabelRect = CGRectMake(6, 162, _textWidth, 15);
    [_nameLabel setFrame:_nameLabelRect];
    
    _productImageViewRect = CGRectMake(self.width/2 - 112/2, 8, 112, 140);
    [_productImageView setFrame:_productImageViewRect];
    
    _discountImageViewRect = CGRectMake(0, CGRectGetMaxY(_productImageViewRect) - 14, 26, 14);
    [_discountImageView setFrame:_discountImageViewRect];
    [_discountImageView setXRightAligned:6.f];
    _discountImageViewRect = _discountImageView.frame;
    
    _discountLabelRect = CGRectMake(0, CGRectGetMaxY(_productImageViewRect) - 14, 26, 14);
    [_discountLabel setFrame:_discountLabelRect];
    [_discountLabel setXRightAligned:6.f];
    _discountLabelRect = _discountLabel.frame;
    
    [_priceView setFrame:CGRectMake(6, 0, _textWidth, 50)];
}

- (void)reloadViews
{
    [_brandLabel setFrame:CGRectMake(_brandLabelRect.origin.x,
                                     _brandLabelRect.origin.y,
                                     _textWidth,
                                     _brandLabelRect.size.height)];
    
    [_nameLabel setFrame:CGRectMake(_nameLabelRect.origin.x,
                                    _nameLabelRect.origin.y,
                                    _textWidth,
                                    _nameLabelRect.size.height)];
    
    [_priceView setY:CGRectGetMaxY(self.nameLabel.frame) + JACatalogCellPriceLabelOffsetY + 6.f];
    
    [_productImageView setFrame:_productImageViewRect];
    [_recentProductImageView setFrame:_recentProductImageViewRect];
    [_favoriteButton setXRightAligned:6];
    [_discountImageView setFrame:_discountImageViewRect];
    [_discountLabel setFrame:_discountLabelRect];
    
    if (RI_IS_RTL) {
        [_productImageView flipViewPositionInsideSuperview];
        [_recentProductImageView flipViewPositionInsideSuperview];
        [_favoriteButton flipViewPositionInsideSuperview];
        [_discountLabel flipViewPositionInsideSuperview];
        [_discountImageView flipViewPositionInsideSuperview];
        [_brandLabel flipViewPositionInsideSuperview];
        [_nameLabel flipViewPositionInsideSuperview];
        [_brandLabel setTextAlignment:NSTextAlignmentRight];
        [_nameLabel setTextAlignment:NSTextAlignmentRight];
    }else{
        [_brandLabel setTextAlignment:NSTextAlignmentLeft];
        [_nameLabel setTextAlignment:NSTextAlignmentLeft];
    }
    
    _lastWidth = self.width;
}

- (void)prepareForReuse
{
    //    NSLog(@"prepareForReuse");
}

- (void)loadWithProduct:(RIProduct*)product
{
    [_brandLabel setText:product.brand];
    [_nameLabel setText:product.name];
    
    RIImage* firstImage = [product.images firstObject];
    
    [_productImageView setImageWithURL:[NSURL URLWithString:firstImage.url]
                      placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    
    [_priceView loadWithPrice:product.priceFormatted
                 specialPrice:product.specialPriceFormatted
                     fontSize:10.0f
        specialPriceOnTheLeft:NO];
    
    if (_grid) {
        [_priceView setX:6];
    }else{
        [_priceView setX:80];
    }
    
    if (RI_IS_RTL) {
        [_priceView flipViewPositionInsideSuperview];
    }
    
    _favoriteButton.selected = VALID_NOTEMPTY(product.favoriteAddDate, NSDate);
    
    _recentProductImageView.hidden = ![product.isNew boolValue];
    
    CGFloat priceXOffset = JACatalogCellPriceLabelOffsetX;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        priceXOffset = JACatalogCellPriceLabelOffsetX_ipad;
    }
    
    _discountLabel.text = [NSString stringWithFormat:@"-%@%%",product.maxSavingPercentage];
    _discountLabel.hidden = !product.maxSavingPercentage;
    _discountImageView.hidden = !product.maxSavingPercentage;
}

@end
