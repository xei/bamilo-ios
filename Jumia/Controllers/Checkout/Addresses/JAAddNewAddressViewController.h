//
//  JAAddNewAddressViewController.h
//  Jumia
//
//  Created by Pedro Lopes on 02/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RICart;

@interface JAAddNewAddressViewController : JABaseViewController

@property (assign, nonatomic) BOOL isBillingAddress;
@property (assign, nonatomic) BOOL isShippingAddress;
@property (assign, nonatomic) BOOL showBackButton;
@property (nonatomic, strong) RICart *cart;

@end
