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

- (CGSize)sizeWithMaxWidth:(CGFloat)width
{
    return [self.text sizeForFont:self.font withMaxWidth:width];
}

@end
