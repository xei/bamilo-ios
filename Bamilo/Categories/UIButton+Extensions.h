//
//  UIButton+Extensions.h
//  Jumia
//
//  Created by josemota on 7/14/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Extensions)

@property(nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

-(void) applyStyle:(UIFont *)font color:(UIColor *)color;
-(void) applyStyle:(NSString *)fontName fontSize:(CGFloat)fontSize color:(UIColor *)color;

@end
