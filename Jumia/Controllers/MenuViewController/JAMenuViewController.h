//
//  JAMenuViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RICart;

@interface JAMenuViewController : JABaseViewController

@property (strong, nonatomic) RICart *cart;
@property (assign, nonatomic) BOOL needsExternalPaymentMethod;

@end
