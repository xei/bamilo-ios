//
//  JACatalogCell.m
//  Jumia
//
//  Created by Telmo Pinto on 07/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogCell.h"
#import "RIProduct.h"
#import "RICartItem.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"
#import "JARatingsView.h"
#import "RILanguage.h"

@implementation JACatalogCell

- (void)loadWithProduct:(RIProduct*)product
{
    self.backgroundColor = [UIColor clearColor];
    
    self.backgroundContentView.backgroundColor = [UIColor whiteColor];
    [self.backgroundContentView setFrame:CGRectMake(0.f, 3.f, self.width, self.height-6.f)];
    self.backgroundContentView.layer.cornerRadius = JACatalogCellContentCornerRadius;
    self.backgroundContentView.clipsToBounds = YES;
    
    [self.feedbackView setFrame:CGRectMake(0.f, 0.f, self.backgroundContentView.width, self.backgroundContentView.height)];
    self.feedbackView.layer.cornerRadius = JACatalogCellContentCornerRadius;
    
    RIImage* firstImage = [product.images firstObject];
    
    [self.productImageView setImageWithURL:[NSURL URLWithString:firstImage.url]
                          placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    
    [self.backgroundContentView sendSubviewToBack:self.productImageView];
    
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
    
    UIImage* recentProductImage = [UIImage imageNamed:imageName];
    [self.recentProductImageView setImage:recentProductImage];
    self.recentProductImageView.frame = CGRectMake(0.0f,
                                                   0.0f,
                                                   recentProductImage.size.width,
                                                   recentProductImage.size.height);
    self.recentProductImageView.hidden = ![product.isNew boolValue];
    
    self.brandLabel.font = [UIFont fontWithName:kFontRegularName size:self.brandLabel.font.pointSize];
    self.brandLabel.text = product.brand;
    [self.brandLabel setTextAlignment:NSTextAlignmentLeft];
    self.brandLabel.textColor = UIColorFromRGB(0x666666);
    
    self.nameLabel.font = [UIFont fontWithName:kFontLightName size:self.nameLabel.font.pointSize];
    self.nameLabel.text = product.name;
    self.nameLabel.textColor = UIColorFromRGB(0x666666);
    [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
    
    [self.priceView removeFromSuperview];
    self.priceView = [[JAPriceView alloc] init];
    if (VALID_NOTEMPTY(product.priceRange, NSString)) {
        [self.priceView loadWithPrice:product.priceRange
                         specialPrice:nil
                             fontSize:10.0f
                specialPriceOnTheLeft:YES];
    } else {
        [self.priceView loadWithPrice:product.priceFormatted
                         specialPrice:product.specialPriceFormatted
                             fontSize:10.0f
                specialPriceOnTheLeft:YES];
    }
    [self.priceView sizeToFit];
    
    CGFloat priceXOffset = JACatalogCellPriceLabelOffsetX;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        priceXOffset = JACatalogCellPriceLabelOffsetX_ipad;
    }
    
    [self.backgroundContentView addSubview:self.priceView];
    
    self.discountLabel.text = [NSString stringWithFormat:@"-%@%%",product.maxSavingPercentage];
    self.discountLabel.hidden = !product.maxSavingPercentage;
    [self.discountLabel setX:48];
    self.discountImageView.hidden = !product.maxSavingPercentage;
    [self.discountImageView setX:48];
    
    self.favoriteButton.selected = VALID_NOTEMPTY(product.favoriteAddDate, NSDate);
    [self.favoriteButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    if (1 >= product.productSimples.count) {
        self.sizeButton.hidden = YES;
    } else {
        self.sizeButton.hidden = NO;
    }
    self.sizeButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.sizeButton.titleLabel.font.pointSize];
    [self.sizeButton setTitle:STRING_SIZE forState:UIControlStateNormal];
    [self.sizeButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
    [self.sizeButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.sizeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.sizeButton setFrame:CGRectMake(80.0f,
                                         self.sizeButton.frame.origin.y,
                                         self.sizeButton.frame.size.width,
                                         self.sizeButton.frame.size.height)];
}

- (void)loadWithCartItem:(RICartItem*)cartItem
{
    [self.backgroundContentView setWidth:self.width];
    
    [self.productImageView setX:6.f];
    [self.productImageView setImageWithURL:[NSURL URLWithString:cartItem.imageUrl]
                          placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    
    self.recentProductImageView.hidden = YES;
    
    [self.nameLabel setX:96.f];
    [self.nameLabel setWidth:self.width - 120.f];
    self.nameLabel.font = [UIFont fontWithName:kFontLightName size:self.nameLabel.font.pointSize];
    self.nameLabel.text = cartItem.name;
    self.nameLabel.textColor = UIColorFromRGB(0x666666);
    [self.nameLabel sizeToFit];
    
    [self.priceView removeFromSuperview];
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:cartItem.priceFormatted
                     specialPrice:cartItem.specialPriceFormatted
                         fontSize:10.0f
            specialPriceOnTheLeft:YES];
    self.priceView.frame = CGRectMake(96.0f,
                                      34.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.backgroundContentView addSubview:self.priceView];
    
    [self.sizeLabel setX:96.f];
    self.sizeLabel.font = [UIFont fontWithName:kFontLightName size:self.sizeLabel.font.pointSize];
    
    NSString *variationString = [cartItem.variation lowercaseString];
    if ([@"1" isEqualToString:variationString] ||
        [@"," isEqualToString:variationString] ||
        [@"..." isEqualToString:variationString] ||
        [@"." isEqualToString:variationString] ||
        [@"\u2026" isEqualToString:variationString] )
    {
        variationString = @"";
    }
    
    self.sizeLabel.text = variationString;
    [self.sizeLabel setNumberOfLines:1];
    [self.sizeLabel sizeToFit];
    
    if (VALID_NOTEMPTY(cartItem.shopFirst, NSNumber) && [cartItem.shopFirst boolValue])	{
        [self.shopFirstLogo setHidden:NO];
        [self.shopFirstLogo setY:[self getShopFirstLogoPostion]];
    } else {
        [self.shopFirstLogo setHidden:YES];
    }
    
    self.discountLabel.font = [UIFont fontWithName:kFontBoldName size:self.discountLabel.font.pointSize];
    self.discountLabel.text = [NSString stringWithFormat:@"-%ld%%",[cartItem.savingPercentage longValue]];
    self.discountLabel.hidden = !cartItem.savingPercentage;
    self.discountImageView.hidden = !cartItem.savingPercentage;
    [self.discountImageView setX:54.f];
    [self.discountLabel setX:54.f];
}

- (UIImageView *)shopFirstLogo
{
    if (!_shopFirstLogo) {
        _shopFirstLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop_first_logo"]];
        [_shopFirstLogo sizeToFit];
        [_shopFirstLogo setX:96.0f];
        [_shopFirstLogo setHidden:YES];
        [_backgroundContentView addSubview:_shopFirstLogo];
    }
    return _shopFirstLogo;
}

- (CGFloat)getShopFirstLogoPostion
{
    if ([self.sizeLabel.text isEqualToString:@""]) {
        return 50.0f;
    }
    return 70.0f;
}

@end
