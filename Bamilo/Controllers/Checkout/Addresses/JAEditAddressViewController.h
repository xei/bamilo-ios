//
//  JAEditAddressViewController.h
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"

@class RIAddress;
@class RICart;

@interface JAEditAddressViewController : JABaseViewController

@property (assign, nonatomic) BOOL fromCheckout;
@property (strong, nonatomic) RIAddress *editAddress;
@property (strong, nonatomic) RICart *cart;

@end
