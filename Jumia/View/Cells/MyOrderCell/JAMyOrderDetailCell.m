//
//  JAMyOrderDetailCell.m
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyOrderDetailCell.h"

@implementation JAMyOrderDetailCell

- (void)awakeFromNib
{
    [self.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
}

- (void)setupWithOrder:(RITrackOrder*)order
{
    [self.orderDetailView setupWithOrder:order maxWidth:self.frame.size.width];
}

@end
