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
    if (frame.origin.x == x) {
        return;
    }
    frame.origin.x = x;
    [self setFrame:frame];
}

- (void)setY:(CGFloat)y {
    CGRect frame = [self frame];
    if (frame.origin.y == y) {
        return;
    }
    frame.origin.y = y;
    [self setFrame:frame];
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = [self frame];
    if (frame.size.width == width) {
        return;
    }
    frame.size.width = width;
    [self setFrame:frame];
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = [self frame];
    if (frame.size.height == height) {
        return;
    }
    frame.size.height = height;
    [self setFrame:frame];
}

- (void)setXRightAligned:(CGFloat)xRightAligned
{
    CGFloat x = self.superview.width - self.width - xRightAligned;
    if (self.x != x) {
        self.x = x;
    }
}

- (void)setYBottomAligned:(CGFloat)yBottomAligned
{
    CGFloat y = self.superview.height - self.height - yBottomAligned;
    if (self.y != y) {
        self.y = y;
    }
}


- (void)setXLeftOf:(UIView *)view at:(CGFloat)distance
{
    CGFloat x = view.x - self.width - distance;
    if (self.x != x) {
        self.x = x;
    }
}

- (void)setXRightOf:(UIView *)view at:(CGFloat)distance
{
    CGFloat x = CGRectGetMaxX(view.frame) + distance;
    if (self.x != x) {
        self.x = x;
    }
}

- (void)setYTopOf:(UIView *)view at:(CGFloat)distance
{
    CGFloat y = view.y - self.height - distance;
    if (self.y != y) {
        self.y = y;
    }
}

- (void)setYBottomOf:(UIView *)view at:(CGFloat)distance
{
    CGFloat y = CGRectGetMaxY(view.frame) + distance;
    if (self.y != y) {
        self.y = y;
    }
}

- (void)setXCenterAligned
{
    CGFloat x = [self superview].width/2 - self.width/2;
    if (self.x != x) {
        self.x = x;
    }
}

- (void)setYCenterAligned
{
    CGFloat y = [self superview].height/2 - self.height/2;
    if (self.y != y) {
        self.y = y;
    }
}

@end
