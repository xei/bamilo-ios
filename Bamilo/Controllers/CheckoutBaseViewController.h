//
//  CheckoutBaseViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "BaseViewController.h"
#import "CheckoutProgressViewControl.h"
#import "DataServiceProtocol.h"

@interface CheckoutBaseViewController : BaseViewController <DataServiceProtocol, CheckoutProgressViewDelegate>

-(NSString *)getNextStepViewControllerSegueIdentifier;

@end
