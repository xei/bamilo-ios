//
//  JAMyOrderCell.h
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIOrder.h"
#import "JAClickableView.h"

@interface JAMyOrderCell : UICollectionViewCell

@property (strong, nonatomic) JAClickableView *clickableView;

- (void)setupWithOrder:(RITrackOrder*)order;

+ (CGFloat)getCellHeight;

@end
