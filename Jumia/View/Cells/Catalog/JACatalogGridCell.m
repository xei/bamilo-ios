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
    
    RIImage* firstImage = [product.images firstObject];
 
    [self.productImageView setImageWithURL:[NSURL URLWithString:firstImage.url]
                          placeholderImage:[UIImage imageNamed:@"placeholder_grid"]];
    
    self.priceView.frame = CGRectMake(2.0f,
                                      181.0f,
                                      self.frame.size.width - 4.0f,
                                      self.priceView.frame.size.height);
}

@end
