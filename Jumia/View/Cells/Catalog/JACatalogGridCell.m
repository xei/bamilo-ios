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
    
    self.priceLine.frame = CGRectMake(self.nameLabel.frame.origin.x,// + priceXOffset,
                                      CGRectGetMaxY(self.nameLabel.frame) + JACatalogCellPriceLabelOffsetY,
                                      self.priceLine.frame.size.width,
                                      self.priceLine.frame.size.height);
    [self.priceLine setY:CGRectGetMaxY(self.nameLabel.frame) + 2*JACatalogCellPriceLabelOffsetY];
    
    [self.favoriteButton setX:self.backgroundContentView.width - self.favoriteButton.width - 6.f];
    
    RIImage* firstImage = [product.images firstObject];
 
    [self.productImageView setImageWithURL:[NSURL URLWithString:firstImage.url]
                          placeholderImage:[UIImage imageNamed:@"placeholder_grid"]];
    
    CGFloat priceY = JACatalogViewControllerGridCellPriceViewY;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        priceY = JACatalogViewControllerGridCellPriceViewY_ipad;
    }
    
    self.priceLine.x = 6.f;
    self.priceLine.y = priceY;
    
    CGFloat recentLabelY = JACatalogViewControllerGridCellNewLabelY;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        recentLabelY = JACatalogViewControllerGridCellNewLabelY_ipad;
    }
    
    if (RI_IS_RTL) {
        [self.backgroundContentView flipAllSubviews];
    }
}

@end
