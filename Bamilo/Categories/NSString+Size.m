//
//  NSString+Size.m
//  Jumia
//
//  Created by Jose Mota on 09/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "NSString+Size.h"

@implementation NSString (Size)

- (CGFloat)widthForFont:(UIFont *)font
{
    NSDictionary *attributes = @{NSFontAttributeName: font};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    CGRect rect = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    return rect.size.width;
}

- (CGSize)sizeForFont:(UIFont *)font withMaxWidth:(CGFloat)width
{
    NSDictionary *attributes = @{NSFontAttributeName: font};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    return rect.size;
}

@end
