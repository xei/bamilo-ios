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
        
        NSString* specialPrice = [product.specialPrice stringValue];
        NSString* price = [product.price stringValue];
        
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", specialPrice, price]
                                                                  attributes:attributes];
        NSDictionary* oldPriceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            JACatalogCellLightFont, NSFontAttributeName,
                                            JACatalogCellGrayFontColor, NSForegroundColorAttributeName, nil];
        NSRange oldPriceRange = NSMakeRange(specialPrice.length + 1, price.length);
        
        [finalPriceString setAttributes:oldPriceAttributes
                                  range:oldPriceRange];
        
    } else {
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:[product.price stringValue]
                                                                  attributes:attributes];
    }
    
    [self.priceLabel setAttributedText:finalPriceString];
    

    self.discountLabel.text = [NSString stringWithFormat:@"-%@%%",product.maxSavingPercentage];
    self.discountLabel.hidden = !product.maxSavingPercentage;
    self.discountImageView.hidden = !product.maxSavingPercentage;
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
    if (cartItem.specialPrice && 0 < [cartItem.specialPrice floatValue]) {
        
        NSString* specialPrice = [cartItem.specialPrice stringValue];
        NSString* price = [cartItem.price stringValue];
        
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", specialPrice, price]
                                                                  attributes:attributes];
        NSDictionary* oldPriceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            JACatalogCellLightFont, NSFontAttributeName,
                                            JACatalogCellGrayFontColor, NSForegroundColorAttributeName, nil];
        NSRange oldPriceRange = NSMakeRange(specialPrice.length + 1, price.length);
        
        [finalPriceString setAttributes:oldPriceAttributes
                                  range:oldPriceRange];
        
    } else {
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:[cartItem.price stringValue]
                                                                  attributes:attributes];
    }
    
    [self.priceLabel setAttributedText:finalPriceString];
    
    
    self.discountLabel.text = [NSString stringWithFormat:@"-%@%%",[cartItem.savingPercentage stringValue]];
    self.discountLabel.hidden = !cartItem.savingPercentage;
    self.discountImageView.hidden = !cartItem.savingPercentage;
}

@end
