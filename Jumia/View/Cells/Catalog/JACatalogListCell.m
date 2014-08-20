//
//  JACatalogListCell.m
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogListCell.h"
#import "JARatingsView.h"
#import "RIProduct.h"
#import "JAUtils.h"

@interface JACatalogListCell()

@property (weak, nonatomic) IBOutlet JARatingsView *ratingsView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfReviewsLabel;

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

- (void)loadWithProduct:(RIProduct *)product
{
    [super loadWithProduct:product];
    
    if (self.numberOfReviewsLabel) {
        [self.ratingsView setFrame:CGRectMake(self.priceLabel.frame.origin.x + JACatalogCellRatingsViewOffsetY,
                                              CGRectGetMaxY(self.priceLabel.frame) + JACatalogCellRatingsViewOffsetX,
                                              self.ratingsView.frame.size.width,
                                              self.ratingsView.frame.size.height)];
        self.ratingsView.rating = [product.avr integerValue];
        
        
        self.numberOfReviewsLabel.font = JACatalogCellLightFont;
        self.numberOfReviewsLabel.textColor = JACatalogCellGrayFontColor;
        if (1 == [product.sum integerValue]) {
            self.numberOfReviewsLabel.text = [NSString stringWithFormat:@"%@ review", [product.sum stringValue]];
        } else {
            self.numberOfReviewsLabel.text = [NSString stringWithFormat:@"%@ reviews", [product.sum stringValue]];
        }
    } else {
        [self.ratingsView removeFromSuperview];
    }
    
    [self.addToCartButton setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    self.addToCartButton.layer.cornerRadius = 3.0f;
    [self.addToCartButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.addToCartButton setTitle:@"Add to Cart" forState:UIControlStateNormal];
}

@end
