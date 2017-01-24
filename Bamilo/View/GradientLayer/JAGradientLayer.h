//
//  JAGradientLayer.h
//  Jumia
//
//  Created by plopes on 09/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAGradientLayer : NSObject

+ (CAGradientLayer*)alphaGradient:(UIColor*)color bounds:(CGRect)bounds leftToRight:(BOOL)leftToRight;

@end
