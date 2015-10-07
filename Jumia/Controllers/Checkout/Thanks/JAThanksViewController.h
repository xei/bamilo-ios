//
//  JAThanksViewController.h
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RICart.h"

@interface JAThanksViewController : JABaseViewController

@property (strong, nonatomic) RICart *cart;
@property (strong, nonatomic) NSString *orderNumber;

@end
