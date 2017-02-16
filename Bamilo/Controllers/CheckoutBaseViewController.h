//
//  CheckoutBaseViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//


#import "ProtectedViewController.h"
#import "CheckoutProgressViewControl.h"
#import "DataServiceProtocol.h"

@interface CheckoutBaseViewController : ProtectedViewController <DataServiceProtocol, CheckoutProgressViewDelegate>

-(NSString *)getNextStepViewControllerSegueIdentifier;

@end
