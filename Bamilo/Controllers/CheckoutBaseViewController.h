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
#import "RICart.h"

typedef void(^CheckoutActionCompletion)(void);

@interface CheckoutBaseViewController : ProtectedViewController <DataServiceProtocol, CheckoutProgressViewDelegate>

@property (strong, nonatomic) RICart *cart;

-(NSString *)getNextStepViewControllerSegueIdentifier;
-(void) performPreDepartureAction:(CheckoutActionCompletion)completion;

@end
