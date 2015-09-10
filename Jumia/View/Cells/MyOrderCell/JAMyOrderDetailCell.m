//
//  JAMyOrderDetailCell.m
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyOrderDetailCell.h"

@interface JAMyOrderDetailCell()

@property (weak, nonatomic) IBOutlet UIView *separator;

@end

@implementation JAMyOrderDetailCell

- (void)awakeFromNib
{
    [self.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
}

- (void)setupWithOrder:(RITrackOrder*)order
{
    [self.orderDetailView setupWithOrder:order maxWidth:self.frame.size.width allowsFlip:YES];
    
    CGFloat height = [JAMyOrderDetailView getOrderDetailViewHeight:order maxWidth:self.frame.size.width];
    self.separator.frame = CGRectMake(0.0f,
                                      height - 1.0f,
                                      self.frame.size.width,
                                      1.0f);
}

@end