//
//  JACatalogListCell.m
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogListCell.h"
#import "RIProduct.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"

@interface JACatalogListCell()

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *numberOfReviewsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *recentProductImageView;
@property (weak, nonatomic) IBOutlet UILabel *recentProductLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *discountImageView;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;

@end

@implementation JACatalogListCell

- (void)loadWithProduct:(RIProduct*)product
{
    RIImage* firstImage = [product.images firstObject];
    
    [self.productImageView setImageWithURL:[NSURL URLWithString:firstImage.url]];
    
    self.recentProductImageView.hidden = !product.isNew;
    self.recentProductLabel.hidden = !product.isNew;
    
    self.brandLabel.text = product.brand;
    self.nameLabel.text = product.name;
    
    NSMutableAttributedString* finalPriceString;
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"HelveticaNeue" size:10.0f], NSFontAttributeName,
                                UIColorFromRGB(0xcc0000), NSForegroundColorAttributeName, nil];
    if (product.specialPrice && 0 < [product.specialPrice floatValue]) {
        
        NSString* specialPrice = [product.specialPrice stringValue];
        NSString* price = [product.price stringValue];
        
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", specialPrice, price]
                                                             attributes:attributes];
        NSDictionary* oldPriceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0f], NSFontAttributeName,
                                         UIColorFromRGB(0xcccccc), NSForegroundColorAttributeName, nil];
        NSRange oldPriceRange = NSMakeRange(specialPrice.length + 1, price.length);
        
        [finalPriceString setAttributes:oldPriceAttributes
                                  range:oldPriceRange];

    } else {
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:[product.price stringValue]
                                                             attributes:attributes];
    }
    
    [self.priceLabel setAttributedText:finalPriceString];
    
    self.numberOfReviewsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0];
    if (1 == [product.sum integerValue]) {
        self.numberOfReviewsLabel.text = [NSString stringWithFormat:@"%@ review", [product.sum stringValue]];
    } else {
        self.numberOfReviewsLabel.text = [NSString stringWithFormat:@"%@ reviews", [product.sum stringValue]];
    }
    
    self.discountLabel.text = [NSString stringWithFormat:@"-%@%%",product.maxSavingPercentage];
    self.discountLabel.hidden = !product.maxSavingPercentage;
    self.discountImageView.hidden = !product.maxSavingPercentage;
}

@end
