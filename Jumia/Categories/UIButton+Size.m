//
//  UIButton+Size.m
//  Jumia
//
//  Created by Jose Mota on 09/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "UIButton+Size.h"
#import "NSString+Size.h"

@implementation UIButton (Size)

- (CGSize)sizeWithMaxWidth:(CGFloat)width
{
    return [self.titleLabel.text sizeForFont:self.titleLabel.font withMaxWidth:width];
}

@end
