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

@synthesize productImageView = _productImageView, brandLabel = _brandLabel, nameLabel = _nameLabel, recentProductImageView = _recentProductImageView, favoriteButton = _favoriteButton,discountLabel = _discountLabel, sizeButton = _sizeButton, priceView = _priceView, feedbackView = _feedbackView, cellType = _cellType;

- (void)initViews
{
    _feedbackView = [[JAClickableView alloc] initWithFrame:self.bounds];
    [self addSubview:_feedbackView];
    
    _brandLabel = [[UILabel alloc] init];
    [_brandLabel setFont:JACaptionFont];
    [_brandLabel setText:@"BrandLabel"];
    _brandLabel.textColor = UIColorFromRGB(0x808080);
    [self addSubview:_brandLabel];
    
    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setFont:JABody3Font];
    [_nameLabel setText:@"NameLabel"];
    _nameLabel.textColor = UIColorFromRGB(0x000000);
    [self addSubview:_nameLabel];
    
    _productImageView = [[UIImageView alloc] init];
    [self addSubview:_productImageView];
    
    _discountLabel = [[UILabel alloc] init];
    [_discountLabel setFont:JACaptionFont];
    [_discountLabel setText:@"DiscountLabel"];
    [_discountLabel setTextColor:JAOrange1Color];
    [_discountLabel setTextAlignment:NSTextAlignmentCenter];
    _discountLabel.layer.borderColor = [JAOrange1Color CGColor];
    _discountLabel.layer.borderWidth = 1.0f;
    [self addSubview:_discountLabel];

    _favoriteButtonRect = CGRectMake(0, 10, 18, 18);
    _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_favoriteButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    [_favoriteButton setFrame:_favoriteButtonRect];
    [_favoriteButton setImage:[UIImage imageNamed:@"FavButton"] forState:UIControlStateNormal];
    [_favoriteButton setImage:[UIImage imageNamed:@"FavButtonPressed"] forState:UIControlStateSelected];
    [self addSubview:_favoriteButton];
    [_favoriteButton setXRightAligned:16.f];
    _favoriteButtonRect = _favoriteButton.frame;
    
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
    
    [self addSubview:_recentProductImageView];
    
    _priceView = [[JAPriceView alloc] init];
    [self addSubview:_priceView];
    
    switch (_cellType) {
        case JACatalogCollectionViewGridCell:
            [self initGridViews];
            break;
            
        case JACatalogCollectionViewListCell:
            [self initListViews];
            break;
            
        case JACatalogCollectionViewPictureCell:
            [self initPictureViews];
            break;
        default:
            [self initListViews];
            break;
    }
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setClipsToBounds:YES];
}

- (void)initListViews
{
    _textWidth = self.width - 90 - 30;
    
    _brandLabelRect = CGRectMake(90, 9, _textWidth, 15);
    [_brandLabel setFrame:_brandLabelRect];
    
    _nameLabelRect = CGRectMake(90, 26, _textWidth, 15);
    [_nameLabel setFrame:_nameLabelRect];
    
    _productImageViewRect = CGRectMake(16, 8, 68, 85);
    [_productImageView setFrame:_productImageViewRect];
    
    _discountLabelRect = CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame) + JACatalogCellPriceLabelOffsetY + 10.f, 60, 19);
    [_discountLabel setFrame:_discountLabelRect];
    [_discountLabel setXRightAligned:16.f];
    _discountLabelRect = _discountLabel.frame;
}

- (void)initGridViews
{
    _textWidth = self.width - 16 - 16;
    _brandLabelRect = CGRectMake(16, 164, _textWidth, 15);
    [_brandLabel setFrame:_brandLabelRect];
    
    _nameLabelRect = CGRectMake(16, 178, _textWidth, 15);
    [_nameLabel setFrame:_nameLabelRect];
    
    _productImageViewRect = CGRectMake(self.width/2 - 112/2, 8, 112, 140);
    [_productImageView setFrame:_productImageViewRect];
    
    _discountLabelRect = CGRectMake(0, CGRectGetMaxY(_productImageViewRect) +2, 60, 19);
    [_discountLabel setFrame:_discountLabelRect];
    [_discountLabel setXRightAligned:16.f];
    _discountLabelRect = _discountLabel.frame;
}

- (void)initPictureViews
{
    _textWidth = self.width - 30;
    
    _brandLabelRect = CGRectMake(16, 345, _textWidth, 15);
    [_brandLabel setFrame:_brandLabelRect];
    
    _nameLabelRect = CGRectMake(16, _brandLabelRect.origin.y +12, _textWidth, 15);
    [_nameLabel setFrame:_nameLabelRect];
    
    [_priceView setFrame:CGRectMake(16, 12, _textWidth, 15)];
    
    _productImageViewRect = CGRectMake(self.width/2 - 268/2, 8, 268, 340);
    [_productImageView setFrame:_productImageViewRect];
    
    _discountLabelRect = CGRectMake(16, 392, 60, 19);
    [_discountLabel setFrame:_discountLabelRect];
    [_discountLabel setXRightAligned:16.f];
    _discountLabelRect = _discountLabel.frame;
}

- (void)reloadViews
{
    _feedbackView.frame = self.bounds;
    
    switch (_cellType) {
        case JACatalogCollectionViewGridCell:
            [self initGridViews];
            break;
            
        case JACatalogCollectionViewListCell:
            [self initListViews];
            break;
            
        case JACatalogCollectionViewPictureCell:
            [self initPictureViews];
            break;
        default:
            [self initListViews];
            break;
    }
    
    [_brandLabel setFrame:CGRectMake(_brandLabelRect.origin.x,
                                     _brandLabelRect.origin.y,
                                     _textWidth,
                                     _brandLabelRect.size.height)];
    
    [_nameLabel setFrame:CGRectMake(_nameLabelRect.origin.x,
                                    CGRectGetMaxY(_brandLabelRect) + 8.f,
                                    _textWidth,
                                    _nameLabelRect.size.height)];
    
    [_priceView setY:CGRectGetMaxY(self.nameLabel.frame) + JACatalogCellPriceLabelOffsetY + 6.f];
    
    [_productImageView setFrame:_productImageViewRect];
    [_recentProductImageView setFrame:_recentProductImageViewRect];
    [_favoriteButton setXRightAligned:16];
    [_discountLabel setFrame:_discountLabelRect];
    [_discountLabel setXRightAligned:16];
    
    if (_cellType == JACatalogCollectionViewGridCell) {
        [self reloadGridViews];
    }
    
    if (RI_IS_RTL) {
        [_productImageView flipViewPositionInsideSuperview];
        [_recentProductImageView flipViewPositionInsideSuperview];
        [_favoriteButton flipViewPositionInsideSuperview];
        [_discountLabel flipViewPositionInsideSuperview];
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

- (void)reloadGridViews
{
    [_productImageView setX:self.width/2 - _productImageView.width/2];
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

- (UIButton *)sizeButton
{
    if (!VALID_NOTEMPTY(_sizeButton, UIButton)) {
        
        CGRect frame = CGRectMake(self.priceView.frame.origin.x, self.priceView.frame.origin.y+20.0f,
                                  self.frame.size.width, self.priceView.frame.size.height);
        
        _sizeButton = [[UIButton alloc] initWithFrame:(frame)];
        _sizeButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:_sizeButton.titleLabel.font.pointSize];
        [_sizeButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
        [_sizeButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
        [_sizeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_sizeButton.titleLabel sizeToFit];
        [self addSubview:_sizeButton];
    }
    return _sizeButton;
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
        [_priceView loadWithPrice:product.priceRange
                     specialPrice:nil
                         fontSize:10.0f
            specialPriceOnTheLeft:YES];
    } else {
        [_priceView loadWithPrice:product.priceFormatted
                     specialPrice:product.specialPriceFormatted
                         fontSize:10.0f
            specialPriceOnTheLeft:YES];
    }
    
    switch (_cellType) {
        case JACatalogCollectionViewGridCell:
            [_priceView setX:16];
            break;
            
        case JACatalogCollectionViewListCell:
            [_priceView setX:90];
            break;
            
        case JACatalogCollectionViewPictureCell:
            [_priceView setX:16];
            break;
        default:
            [_priceView setX:90];
            break;
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
    [_priceView loadWithPrice:[RICountryConfiguration formatPrice:[[NSNumberFormatter new] numberFromString:variation.price] country:[RICountryConfiguration getCurrentConfiguration]]
                 specialPrice:nil
                     fontSize:10.0f
        specialPriceOnTheLeft:YES];
    
    switch (_cellType) {
        case JACatalogCollectionViewGridCell:
            [_priceView setX:16];
            break;
            
        case JACatalogCollectionViewListCell:
            [_priceView setX:90];
            break;
            
        case JACatalogCollectionViewPictureCell:
            [_priceView setX:16];
            break;
        default:
            [_priceView setX:90];
            break;
    }
    
    if (RI_IS_RTL) {
        [_priceView flipViewPositionInsideSuperview];
    }
    
    _recentProductImageView.hidden = YES;
    _discountLabel.hidden = YES;
    _favoriteButton.hidden = YES;
    
    if (RI_IS_RTL) {
        [_priceView flipViewPositionInsideSuperview];
    }
}

@end
