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
#import "JARatingsView.h"

#define JACatalogListCellNormalFont [UIFont fontWithName:@"HelveticaNeue" size:10.0f]
#define JACatalogListCellLightFont [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0f]
#define JACatalogListCellRedFontColor UIColorFromRGB(0xcc0000)
#define JACatalogListCellGrayFontColor UIColorFromRGB(0xcccccc)
#define JACatalogListCellRatingsViewOffsetY 7.0f
#define JACatalogListCellRatingsViewOffsetX 7.0f

@interface JACatalogListCell()

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet JARatingsView *ratingsView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfReviewsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *recentProductImageView;
@property (weak, nonatomic) IBOutlet UILabel *recentProductLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *discountImageView;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;

@end

@implementation JACatalogListCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.ratingsView = [JARatingsView getNewJARatingsView];
        [self addSubview:self.ratingsView];
    }
    return self;
}

- (void)loadWithProduct:(RIProduct*)product
{
    RIImage* firstImage = [product.images firstObject];
    
    [self.productImageView setImageWithURL:[NSURL URLWithString:firstImage.url]];
    
    self.recentProductImageView.hidden = !product.isNew;
    self.recentProductLabel.hidden = !product.isNew;
    self.recentProductLabel.text = @"NEW";
    self.recentProductLabel.transform = CGAffineTransformMakeRotation (-M_PI/4);
    
    self.brandLabel.text = product.brand;
    self.nameLabel.text = product.name;
    
    NSMutableAttributedString* finalPriceString;
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                JACatalogListCellNormalFont, NSFontAttributeName,
                                JACatalogListCellRedFontColor, NSForegroundColorAttributeName, nil];
    if (product.specialPrice && 0 < [product.specialPrice floatValue]) {
        
        NSString* specialPrice = [product.specialPrice stringValue];
        NSString* price = [product.price stringValue];
        
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", specialPrice, price]
                                                             attributes:attributes];
        NSDictionary* oldPriceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         JACatalogListCellLightFont, NSFontAttributeName,
                                         JACatalogListCellGrayFontColor, NSForegroundColorAttributeName, nil];
        NSRange oldPriceRange = NSMakeRange(specialPrice.length + 1, price.length);
        
        [finalPriceString setAttributes:oldPriceAttributes
                                  range:oldPriceRange];

    } else {
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:[product.price stringValue]
                                                             attributes:attributes];
    }
    
    [self.priceLabel setAttributedText:finalPriceString];
    
    
    [self.ratingsView setFrame:CGRectMake(self.priceLabel.frame.origin.x + JACatalogListCellRatingsViewOffsetY,
                                          CGRectGetMaxY(self.priceLabel.frame) + JACatalogListCellRatingsViewOffsetX,
                                          self.ratingsView.frame.size.width,
                                          self.ratingsView.frame.size.height)];
    self.ratingsView.rating = [product.avr integerValue];
    
    
    self.numberOfReviewsLabel.font = JACatalogListCellLightFont;
    self.numberOfReviewsLabel.textColor = JACatalogListCellGrayFontColor;
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
