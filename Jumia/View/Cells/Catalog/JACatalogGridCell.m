//
//  JACatalogGridCell.m
//  Jumia
//
//  Created by Telmo Pinto on 07/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogGridCell.h"

@implementation JACatalogGridCell

- (void)loadWithProduct:(RIProduct *)product
{
    [super loadWithProduct:product];
    
    self.priceView.frame = CGRectMake(5.0f,
                                      180.0f,
                                      self.frame.size.width - 4.0f,
                                      self.priceView.frame.size.height);
}

@end
