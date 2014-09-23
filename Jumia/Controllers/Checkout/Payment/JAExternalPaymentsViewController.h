//
//  JAExternalPaymentsViewController.h
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RICheckout;
@class RIPaymentInformation;

@interface JAExternalPaymentsViewController : JABaseViewController

@property (strong, nonatomic) RICheckout *checkout;
@property (strong, nonatomic) RIPaymentInformation *paymentInformation;

@end
