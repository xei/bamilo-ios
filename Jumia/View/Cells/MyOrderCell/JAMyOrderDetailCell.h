//
//  JAMyOrderDetailCell.h
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAMyOrderDetailView.h"

@interface JAMyOrderDetailCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet JAMyOrderDetailView *orderDetailView;

- (void)setupWithOrder:(RITrackOrder*)order;

@end
