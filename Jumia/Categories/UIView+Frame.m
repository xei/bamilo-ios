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


@end
