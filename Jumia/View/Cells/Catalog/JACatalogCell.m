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

@implementation JACatalogCell

- (void)loadWithProduct:(RIProduct*)product
{
    self.backgroundColor = [UIColor clearColor];
    
    self.backgroundContentView.layer.cornerRadius = JACatalogCellContentCornerRadius;
    
    RIImage* firstImage = [product.images firstObject];
    
    [self.productImageView setImageWithURL:[NSURL URLWithString:firstImage.url]
                          placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    
    [self.backgroundContentView sendSubviewToBack:self.productImageView];
    
    self.recentProductImageView.hidden = ![product.isNew boolValue];
    self.recentProductLabel.hidden = ![product.isNew boolValue];
    self.recentProductLabel.text = STRING_NEW;
    self.recentProductLabel.transform = CGAffineTransformMakeRotation (-M_PI/4);
    
    self.brandLabel.text = product.brand;
    self.brandLabel.textColor = UIColorFromRGB(0x666666);
    self.nameLabel.text = product.name;
    self.nameLabel.textColor = UIColorFromRGB(0x666666);
    
    [self.priceView removeFromSuperview];
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:product.priceFormatted
                     specialPrice:product.specialPriceFormatted
                         fontSize:10.0f
            specialPriceOnTheLeft:NO];
    self.priceView.frame = CGRectMake(85.0f,
                                      43.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.contentView addSubview:self.priceView];
    
    
    self.discountLabel.text = [NSString stringWithFormat:@"-%@%%",product.maxSavingPercentage];
    self.discountLabel.hidden = !product.maxSavingPercentage;
    self.discountImageView.hidden = !product.maxSavingPercentage;
    
    self.favoriteButton.selected = [product.isFavorite boolValue];
    
    if (1 >= product.productSimples.count) {
        self.sizeButton.hidden = YES;
    } else {
        self.sizeButton.hidden = NO;
    }
    [self.sizeButton setTitle:STRING_SIZE forState:UIControlStateNormal];
    [self.sizeButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
    [self.sizeButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
}

- (void)loadWithCartItem:(RICartItem*)cartItem
{
    [self.productImageView setImageWithURL:[NSURL URLWithString:cartItem.imageUrl]
                          placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    
    self.recentProductImageView.hidden = YES;
    self.recentProductLabel.hidden = YES;
    
    self.nameLabel.text = cartItem.name;
    
    [self.priceView removeFromSuperview];
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:cartItem.priceFormatted
                     specialPrice:cartItem.specialPriceFormatted
                         fontSize:10.0f
            specialPriceOnTheLeft:NO];
    self.priceView.frame = CGRectMake(96.0f,
                                      34.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.contentView addSubview:self.priceView];
    
    self.sizeLabel.text = cartItem.variation;
    
    self.discountLabel.text = [NSString stringWithFormat:@"-%d%%",[cartItem.savingPercentage integerValue]];
    self.discountLabel.hidden = !cartItem.savingPercentage;
    self.discountImageView.hidden = !cartItem.savingPercentage;
}

@end