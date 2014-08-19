//
//  JATopSellersTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATopSellersTeaserView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"

#define JATopSellersTeaserViewHeight 144.0f
#define JATopSellersTeaserViewHorizontalMargin 6.0f
#define JATopSellersTeaserViewContentY 4.0f
#define JATopSellersTeaserViewContentCornerRadius 3.0f
#define JATopSellersTeaserViewTitleHeight 26.0f
#define JATopSellersTeaserViewTitleFont [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
#define JATopSellersTeaserViewTitleColor UIColorFromRGB(0x4e4e4e)
#define JATopSellersTeaserViewLineColor UIColorFromRGB(0xfaa41a)
#define JATopSellersTeaserViewProductTeaserWidth 110.0f
#define JATopSellersTeaserViewProductImageWidth 57.0f
#define JATopSellersTeaserViewProductImageHeight 71.0f
#define JATopSellersTeaserViewProductFont [UIFont fontWithName:@"HelveticaNeue" size:9.0f]
#define JATopSellersTeaserViewProductLabelColor UIColorFromRGB(0x666666)
#define JATopSellersTeaserViewProductPriceColor UIColorFromRGB(0xcc0000)


@implementation JATopSellersTeaserView

- (void)load
{
    [super load];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              JATopSellersTeaserViewHeight)];
    
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(JATopSellersTeaserViewHorizontalMargin,
                                                                   JATopSellersTeaserViewContentY,
                                                                   self.bounds.size.width - JATopSellersTeaserViewHorizontalMargin*2,
                                                                   self.bounds.size.height - JATopSellersTeaserViewContentY*2)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = JATopSellersTeaserViewContentCornerRadius;
    [self addSubview:contentView];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x + JATopSellersTeaserViewHorizontalMargin,
                                                                    contentView.bounds.origin.y,
                                                                    contentView.bounds.size.width - JATopSellersTeaserViewHorizontalMargin*2,
                                                                    JATopSellersTeaserViewTitleHeight)];
    titleLabel.text = @"Top Sellers";
    titleLabel.font = JATopSellersTeaserViewTitleFont
    titleLabel.textColor = JATopSellersTeaserViewTitleColor;
    [contentView addSubview:titleLabel];
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x,
                                                                contentView.bounds.origin.y + JATopSellersTeaserViewTitleHeight,
                                                                contentView.bounds.size.width,
                                                                1.0f)];
    lineView.backgroundColor = JATopSellersTeaserViewLineColor;
    [contentView addSubview:lineView];
    
    UIScrollView* productScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(contentView.bounds.origin.x,
                                                                                     CGRectGetMaxY(lineView.frame),
                                                                                     contentView.bounds.size.width,
                                                                                     contentView.bounds.size.height - lineView.frame.size.height - titleLabel.frame.size.height)];
    productScrollView.showsHorizontalScrollIndicator = NO;
    [contentView addSubview:productScrollView];
    
    CGFloat currentX = productScrollView.bounds.origin.x;
    
    for (int i = 0; i < self.teasers.count; i++) {
        RITeaser* teaser = [self.teasers objectAtIndex:i];
        
        for (RITeaserProduct* teaserProduct in teaser.teaserProducts) {
            
            UIView* productTeaserView = [[UIView alloc] initWithFrame:CGRectMake(currentX,
                                                                                 productScrollView.bounds.origin.y,
                                                                                 JATopSellersTeaserViewProductTeaserWidth,
                                                                                 productScrollView.bounds.size.height)];
            [productScrollView addSubview:productTeaserView];
            currentX += productTeaserView.frame.size.width;
            
            UIImageView* productImage = [[UIImageView alloc] initWithFrame:CGRectMake((productTeaserView.frame.size.width - JATopSellersTeaserViewProductImageWidth) / 2,
                                                                                      productTeaserView.bounds.origin.y,
                                                                                      JATopSellersTeaserViewProductImageWidth,
                                                                                      JATopSellersTeaserViewProductImageHeight)];
            [productImage setImageWithURL:[NSURL URLWithString:teaserProduct.imageUrl]];
            [productTeaserView addSubview:productImage];
            
            
            UILabel* brandLabel = [[UILabel alloc] init];
            brandLabel.text = teaserProduct.brand;
            brandLabel.font = JATopSellersTeaserViewProductFont;
            brandLabel.textColor = JATopSellersTeaserViewProductLabelColor;
            brandLabel.textAlignment = NSTextAlignmentCenter;
            [brandLabel sizeToFit];
            [brandLabel setFrame:CGRectMake(productTeaserView.bounds.origin.x + JATopSellersTeaserViewHorizontalMargin,
                                            CGRectGetMaxY(productImage.frame),
                                            productTeaserView.bounds.size.width - JATopSellersTeaserViewHorizontalMargin*2,
                                            brandLabel.frame.size.height)];
            [productTeaserView addSubview:brandLabel];
            
            UILabel* nameLabel = [[UILabel alloc] init];
            nameLabel.text = teaserProduct.name;
            nameLabel.font = JATopSellersTeaserViewProductFont;
            nameLabel.textColor = JATopSellersTeaserViewProductLabelColor;
            nameLabel.textAlignment = NSTextAlignmentCenter;
            [nameLabel sizeToFit];
            [nameLabel setFrame:CGRectMake(productTeaserView.bounds.origin.x + JATopSellersTeaserViewHorizontalMargin,
                                           CGRectGetMaxY(brandLabel.frame),
                                           productTeaserView.bounds.size.width - JATopSellersTeaserViewHorizontalMargin*2,
                                           nameLabel.frame.size.height)];
            [productTeaserView addSubview:nameLabel];
            
            UILabel* priceLabel = [[UILabel alloc] init];
            if (VALID_NOTEMPTY(teaserProduct.specialPrice, NSString)) {
                priceLabel.text = [teaserProduct.specialPrice stringValue];
            } else {
                priceLabel.text = [teaserProduct.price stringValue];
            }
            priceLabel.font = JATopSellersTeaserViewProductFont;
            priceLabel.textColor = JATopSellersTeaserViewProductPriceColor;
            priceLabel.textAlignment = NSTextAlignmentCenter;
            [priceLabel sizeToFit];
            [priceLabel setFrame:CGRectMake(productTeaserView.bounds.origin.x + JATopSellersTeaserViewHorizontalMargin,
                                            CGRectGetMaxY(nameLabel.frame),
                                            productTeaserView.bounds.size.width - JATopSellersTeaserViewHorizontalMargin*2,
                                            priceLabel.frame.size.height)];
            [productTeaserView addSubview:priceLabel];
            
            UIControl* control = [UIControl new];
            [control setFrame:productTeaserView.frame];
            [productScrollView addSubview:control];
            control.tag = i;
            [control addTarget:self action:@selector(teaserProductPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    [productScrollView setContentSize:CGSizeMake(currentX,
                                                 productScrollView.frame.size.height)];
}

- (void)teaserProductPressed:(UIControl*)control
{
    NSInteger index = control.tag;
    
    RITeaser* teaser = [self.teasers objectAtIndex:index];
    
    RITeaserProduct* teaserProduct = [teaser.teaserProducts firstObject];
    
    [self teaserPressedWithTeaserProduct:teaserProduct];
}

@end
