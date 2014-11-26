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
    
    [self.recentLabel removeFromSuperview];
    self.recentLabel = [[UILabel alloc] initWithFrame:CGRectMake(-2.0f, 17.0f, 48.0f, 14.0f)];
    self.recentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:8.0f];
    self.recentLabel.text = STRING_NEW;
    self.recentLabel.textAlignment = NSTextAlignmentCenter;
    self.recentLabel.textColor = [UIColor whiteColor];
    self.recentLabel.transform = CGAffineTransformMakeRotation (-M_PI/4);
    [self addSubview:self.recentLabel];
    self.recentLabel.hidden = ![product.isNew boolValue];
}

@end
