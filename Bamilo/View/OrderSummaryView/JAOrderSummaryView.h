//
//  JAOrderSummaryView.h
//  Jumia
//
//  Created by Telmo Pinto on 24/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RICart.h"

@interface JAOrderSummaryView : UIView

- (void)loadWithCart:(RICart*)cart;

- (void)loadWithCart:(RICart*)cart shippingMethod:(BOOL)shippingMethod;

@end
