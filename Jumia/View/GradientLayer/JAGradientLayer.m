//
//  JAGradientLayer.m
//  Jumia
//
//  Created by plopes on 09/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAGradientLayer.h"

@implementation JAGradientLayer

//Alpha gradient
+ (CAGradientLayer*)alphaGradient:(UIColor*)color bounds:(CGRect)bounds leftToRight:(BOOL)leftToRight
{
    const CGFloat* colorComponents = CGColorGetComponents(color.CGColor);
    UIColor *colorOne = [UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:1.0f];
    UIColor *colorTwo = [UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:0.0f];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    
    NSNumber *gradTopStart = [NSNumber numberWithFloat:0.0];
    NSNumber *gradTopEnd = [NSNumber numberWithFloat:1.0];
    NSNumber *gradBottomStart = [NSNumber numberWithFloat:0.0];
    NSNumber *gradBottomEnd = [NSNumber numberWithFloat:1.0];
    
    headerLayer.locations = [NSArray arrayWithObjects:gradTopStart, gradTopEnd, gradBottomStart, gradBottomEnd, nil];
    
    if(leftToRight)
    {
        headerLayer.startPoint = CGPointMake(0.0f, 0.0f);
        headerLayer.endPoint = CGPointMake(1.0f, 0.0f);
    }
    else
    {
        headerLayer.startPoint = CGPointMake(1.0f, 0.0f);
        headerLayer.endPoint = CGPointMake(0.0f, 0.0f);
    }
    
    headerLayer.bounds = bounds;
    headerLayer.anchorPoint = CGPointZero;
    
    return headerLayer;
}

@end
