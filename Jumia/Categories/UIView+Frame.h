//
//  UIView+Frame.h
//  Jumia
//
//  Created by josemota on 5/27/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat xRightAligned;
@property (nonatomic) CGFloat yBottomAligned;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

- (void)setXLeftOf:(UIView *)view at:(CGFloat)distance;
- (void)setXRightOf:(UIView *)view at:(CGFloat)distance;
- (void)setYTopOf:(UIView *)view at:(CGFloat)distance;
- (void)setYBottomOf:(UIView *)view at:(CGFloat)distance;
- (void)setXCenterAligned;
- (void)setYCenterAligned;

@end
