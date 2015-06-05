//
//  JACatalogGridCell.m
//  Jumia
//
//  Created by Telmo Pinto on 07/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogGridCell.h"
#import "UIImageView+WebCache.h"
#import "RIProduct.h"
#import "RIImage.h"

@implementation JACatalogGridCell

- (void)loadWithProduct:(RIProduct *)product
{
    [super loadWithProduct:product];
    
    [self.brandLabel setX:6.f];
    [self.brandLabel setWidth:self.backgroundContentView.width - 2*6.f];
    [self.nameLabel setX:6.f];
    [self.nameLabel setWidth:self.backgroundContentView.width - 2*6.f];
    
    self.priceView.frame = CGRectMake(self.nameLabel.frame.origin.x,// + priceXOffset,
                                      CGRectGetMaxY(self.nameLabel.frame) + JACatalogCellPriceLabelOffsetY,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.priceView sizeToFit];
    [self.priceView setY:CGRectGetMaxY(self.nameLabel.frame) + 2*JACatalogCellPriceLabelOffsetY];
    
    [self.favoriteButton setX:self.backgroundContentView.width - self.favoriteButton.width - 6.f];
    
    RIImage* firstImage = [product.images firstObject];
 
    [self.productImageView setImageWithURL:[NSURL URLWithString:firstImage.url]
                          placeholderImage:[UIImage imageNamed:@"placeholder_grid"]];
    
    CGFloat priceY = JACatalogViewControllerGridCellPriceViewY;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        priceY = JACatalogViewControllerGridCellPriceViewY_ipad;
    }
    
    self.priceView.x = 6.f;
    self.priceView.y = priceY;
    [self.priceView sizeToFit];
    
    CGFloat recentLabelY = JACatalogViewControllerGridCellNewLabelY;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        recentLabelY = JACatalogViewControllerGridCellNewLabelY_ipad;
    }
    
    [self.recentLabel removeFromSuperview];
    self.recentLabel = [[UILabel alloc] initWithFrame:CGRectMake(-2.0f, recentLabelY, 48.0f, 14.0f)];
    self.recentLabel.font = [UIFont fontWithName:kFontBoldName size:8.0f];
    self.recentLabel.text = STRING_NEW;
    self.recentLabel.textAlignment = NSTextAlignmentCenter;
    self.recentLabel.textColor = [UIColor whiteColor];
    self.recentLabel.transform = CGAffineTransformMakeRotation (-M_PI/4);
    [self addSubview:self.recentLabel];
    self.recentLabel.hidden = ![product.isNew boolValue];
    
    if (RI_IS_RTL) {
        [self.backgroundContentView flipAllSubviews];
    }
}

@end
