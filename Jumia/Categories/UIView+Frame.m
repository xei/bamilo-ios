//
//  UIView+Frame.m
//  Jumia
//
//  Created by josemota on 5/27/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

@dynamic x, y, width, height;

- (CGFloat)x {
    return self.frame.origin.x;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)xRightAligned {
    return self.superview.width - CGRectGetMaxX(self.frame);
}

- (CGFloat)yBottomAligned {
    return self.superview.height - CGRectGetMaxY(self.frame);
}

- (void)setX:(CGFloat)x {
    CGRect frame = [self frame];
    frame.origin.x = x;
    [self setFrame:frame];
}

- (void)setY:(CGFloat)y {
    CGRect frame = [self frame];
    frame.origin.y = y;
    [self setFrame:frame];
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = [self frame];
    frame.size.width = width;
    [self setFrame:frame];
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = [self frame];
    frame.size.height = height;
    [self setFrame:frame];
}

- (void)setXRightAligned:(CGFloat)xRightAligned
{
    self.x = self.superview.width - self.width - xRightAligned;
}

- (void)setYBottomAligned:(CGFloat)yBottomAligned
{
    self.y = self.superview.height - self.height - yBottomAligned;
}


- (void)setXLeftOf:(UIView *)view at:(CGFloat)distance
{
    self.x = view.x - self.width - distance;
}

- (void)setXRightOf:(UIView *)view at:(CGFloat)distance
{
    self.x = CGRectGetMaxX(view.frame) + distance;
}

- (void)setYTopOf:(UIView *)view at:(CGFloat)distance
{
    self.y = view.y - self.height - distance;
}

- (void)setYBottomOf:(UIView *)view at:(CGFloat)distance
{
    self.y = CGRectGetMaxY(view.frame) + distance;
}


@end
