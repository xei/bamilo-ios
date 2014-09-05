//
//  UIImageView+JA.m
//  Jumia
//
//  Created by Pedro Lopes on 05/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "UIImageView+JA.h"

@implementation UIImageView (JA)

- (void) setImage:(UIImage*)image
       withHeight:(CGFloat)height
         andWidth:(CGFloat)width {
    if (0.0f != height)
    {
        [self setImage:image basedOnHeight:height];
    }
    else if(0.0f != width)
    {
        [self setImage:image basedOnWidth:width];
    }
    else
    {
        [self setImage:image];
    }
}

- (void) changeImageSize:(CGFloat)height
                andWidth:(CGFloat)width
{
    if (0.0f != height)
    {
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  [self getImageWidth:self.image fromHeight:height],
                                  height)];
    }
    else if(0.0f != width)
    {
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  width,
                                  [self getImageHeight:self.image fromWidth:width])];
    }
}

- (void) setImage:(UIImage*)image
    basedOnHeight:(CGFloat)height
{
    [self setImage:image];
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              [self getImageWidth:image fromHeight:height],
                              height)];
}

- (void) setImage:(UIImage*)image
     basedOnWidth:(CGFloat)width
{
    [self setImage:image];
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              [self getImageHeight:image fromWidth:width])];
}

- (CGFloat) getImageWidth:(UIImage*)image
               fromHeight:(CGFloat)height
{
    return image.size.width*height/image.size.height;
}

- (CGFloat) getImageHeight:(UIImage*)image
                 fromWidth:(CGFloat)width
{
    return image.size.height*width/image.size.width;
}

@end
