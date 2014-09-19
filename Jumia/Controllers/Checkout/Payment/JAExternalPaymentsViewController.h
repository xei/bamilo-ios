//
//  JAExternalPaymentsViewController.h
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RICheckout;

@interface JAExternalPaymentsViewController : JABaseViewController

@property (strong, nonatomic) RICheckout *checkout;

@end
