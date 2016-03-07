//
//  JAMyOrderDetailView.h
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIOrder.h"

@interface JAMyOrderDetailView : UIView

@property (nonatomic) JABaseViewController *parent;

- (void)setupWithOrder:(RITrackOrder*)order frame:(CGRect)frame;

@end
