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

@property (assign, nonatomic) BOOL fromCheckout;
@property (strong, nonatomic) RICart *cart;

@end