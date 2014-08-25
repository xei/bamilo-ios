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
#import "JAPriceView.h"

@interface JACatalogCell()

@property (strong, nonatomic)JAPriceView *priceView;

@end

@implementation JACatalogCell

- (void)loadWithProduct:(RIProduct*)product
{
    self.backgroundContentView.layer.cornerRadius = JACatalogCellContentCornerRadius;
    
    RIImage* firstImage = [product.images firstObject];
    
    [self.productImageView setImageWithURL:[NSURL URLWithString:firstImage.url]
                          placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    self.recentProductImageView.hidden = !product.isNew;
    self.recentProductLabel.hidden = !product.isNew;
    self.recentProductLabel.text = @"NEW";
    self.recentProductLabel.transform = CGAffineTransformMakeRotation (-M_PI/4);
    
    self.brandLabel.text = product.brand;
    self.nameLabel.text = product.name;
    
    NSMutableAttributedString* finalPriceString;
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                JACatalogCellNormalFont, NSFontAttributeName,
                                JACatalogCellRedFontColor, NSForegroundColorAttributeName, nil];
    if (product.specialPrice && 0 < [product.specialPrice floatValue]) {
        
        NSString* specialPrice = product.specialPriceFormatted;
        NSString* price = product.priceFormatted;
        
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", specialPrice, price]
                                                                  attributes:attributes];
        NSDictionary* oldPriceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            JACatalogCellLightFont, NSFontAttributeName,
                                            JACatalogCellGrayFontColor, NSForegroundColorAttributeName, nil];
        NSRange oldPriceRange = NSMakeRange(specialPrice.length + 1, price.length);
        
        [finalPriceString setAttributes:oldPriceAttributes
                                  range:oldPriceRange];
        
    } else {
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:product.priceFormatted attributes:attributes];
    }
    
    [self.priceLabel setAttributedText:finalPriceString];
    
    self.priceLabel.hidden = YES;
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:product.priceFormatted
                     specialPrice:product.specialPriceFormatted
                         fontSize:10.0f
            specialPriceOnTheLeft:NO];
    self.priceView.frame = CGRectMake(self.priceLabel.frame.origin.x + 5.0f,
                                      self.priceLabel.frame.origin.y + 4.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.contentView addSubview:self.priceView];
    
    
    self.discountLabel.text = [NSString stringWithFormat:@"-%@%%",product.maxSavingPercentage];
    self.discountLabel.hidden = !product.maxSavingPercentage;
    self.discountImageView.hidden = !product.maxSavingPercentage;
    
    self.favoriteButton.selected = [product.isFavorite boolValue];
}

- (void)loadWithCartItem:(RICartItem*)cartItem
{
    [self.productImageView setImageWithURL:[NSURL URLWithString:cartItem.imageUrl]
                          placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    self.recentProductImageView.hidden = YES;
    self.recentProductLabel.hidden = YES;
    
    self.nameLabel.text = cartItem.name;
    
    NSMutableAttributedString* finalPriceString;
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                JACatalogCellNormalFont, NSFontAttributeName,
                                JACatalogCellRedFontColor, NSForegroundColorAttributeName, nil];

    if (cartItem.specialPrice && 0 < [cartItem.specialPrice floatValue])
    {
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", cartItem.specialPriceFormatted, cartItem.priceFormatted]
                                                                  attributes:attributes];
        NSDictionary* oldPriceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            JACatalogCellLightFont, NSFontAttributeName,
                                            JACatalogCellGrayFontColor, NSForegroundColorAttributeName, nil];
        NSRange oldPriceRange = NSMakeRange(cartItem.specialPriceFormatted.length + 1, cartItem.priceFormatted.length);
        
        [finalPriceString setAttributes:oldPriceAttributes range:oldPriceRange];
    } else
    {
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:cartItem.priceFormatted attributes:attributes];
    }
    
    [self.priceLabel setAttributedText:finalPriceString];
    
    self.priceLabel.hidden = YES;
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:cartItem.priceFormatted
                     specialPrice:cartItem.specialPriceFormatted
                         fontSize:10.0f
            specialPriceOnTheLeft:NO];
    self.priceView.frame = CGRectMake(self.priceLabel.frame.origin.x,
                                      self.priceLabel.frame.origin.y,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.contentView addSubview:self.priceView];
    
    self.discountLabel.text = [NSString stringWithFormat:@"-%d%%",[cartItem.savingPercentage integerValue]];
    self.discountLabel.hidden = !cartItem.savingPercentage;
    self.discountImageView.hidden = !cartItem.savingPercentage;
}

@end
