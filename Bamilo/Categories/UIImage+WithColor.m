//
//  UIImage+WithColor.m
//  Jumia
//
//  Created by josemota on 7/28/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "UIImage+WithColor.h"

@implementation UIImage (WithColor)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
