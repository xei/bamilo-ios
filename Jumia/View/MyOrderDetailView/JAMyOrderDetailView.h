//
//  JAMyOrderDetailView.h
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIOrder.h"

@interface JAMyOrderDetailView : UIView

- (void)setupWithOrder:(RITrackOrder*)order maxWidth:(CGFloat)maxWidth allowsFlip:(BOOL)allowsFlip;

+ (CGFloat)getOrderDetailViewHeight:(RITrackOrder*)order maxWidth:(CGFloat)maxWidth;

@end
