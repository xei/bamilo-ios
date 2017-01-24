//
//  UILabel+Size.m
//  Jumia
//
//  Created by Jose Mota on 09/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "UILabel+Size.h"
#import "NSString+Size.h"

@implementation UILabel (Size)

- (void)setSizeForcingMaxSize:(CGSize)maxSize
{
    CGSize size = [self sizeThatFits:maxSize];
    if (size.width > maxSize.width) {
        size.width = maxSize.width;
    }
    if (size.height > maxSize.height) {
        size.height = maxSize.height;
    }
    [self setSize:size];
}

@end
