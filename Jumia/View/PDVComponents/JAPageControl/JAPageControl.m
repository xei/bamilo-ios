//
//  JAPageControl.m
//  Jumia
//
//  Created by Telmo Pinto on 11/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPageControl.h"

@interface JAPageControl()

@property(nonatomic, strong) NSMutableArray* dotsArray;
@property(nonatomic, strong) UIView* contentView;

@end

@implementation JAPageControl

-(void)setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}

-(void)updateDots
{
    for (UIView* view in self.dotsArray) {
        [view removeFromSuperview];
    }
    self.dotsArray = [NSMutableArray new];
    for (int i = 0; i < [self.subviews count]; i++) {
        UIView* dot = [self.subviews objectAtIndex:i];
        dot.hidden = YES;
        UIImage* dotImage;
        if (i == self.currentPage) {
            dotImage = [UIImage imageNamed:@"image_indicator_selected"];
        } else {
            dotImage = [UIImage imageNamed:@"image_indicator"];
        }
        UIImageView* dotImageView = [[UIImageView alloc] initWithImage:dotImage];
        [self.dotsArray addObject:dotImageView];
    }
    UIImageView* imageView = [self.dotsArray objectAtIndex:0];
    CGFloat total = imageView.frame.size.width * self.dotsArray.count + 3.0f * (self.dotsArray.count - 1);
    CGFloat currentX = (self.frame.size.width - total) / 2;
    for (UIView* view in self.dotsArray) {
        [view setFrame:CGRectMake(currentX,
                                  self.bounds.origin.y,
                                  view.frame.size.width,
                                  view.frame.size.height)];
        currentX += view.frame.size.width;
        [self addSubview:view];
    }
}

@end
