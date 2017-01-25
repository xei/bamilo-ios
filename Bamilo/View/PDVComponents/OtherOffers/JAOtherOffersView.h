//
//  JAOtherOffersView.h
//  Jumia
//
//  Created by Telmo Pinto on 22/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProduct.h"

@interface JAOtherOffersView : UIView

+ (JAOtherOffersView *)getNewOtherOffersView;
- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product;

@end
