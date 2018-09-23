//
//  CheckoutBaseViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseViewController.h"
#import "ProtectedViewControllerProtocol.h"
#import "CheckoutProgressViewControl.h"
#import "DataServiceProtocol.h"
#import "RICart.h"
#import "MultistepEntity.h"

typedef void(^CheckoutActionCompletion)(NSString *nextStep, BOOL success);

@interface CheckoutBaseViewController : BaseViewController <DataServiceProtocol, ProtectedViewControllerProtocol, CheckoutProgressViewDelegate>

@property (strong, nonatomic) RICart *cart;
@property (assign, nonatomic) BOOL isCompleteFetch;
@property (assign, nonatomic) BOOL isStepValid;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonHeightConstraint;

-(NSString *) getTitleForContinueButton;
-(NSString *)getNextStepViewControllerSegueIdentifier:(NSString *)serviceIdentifier;
-(void) performPreDepartureAction:(CheckoutActionCompletion)completion;

@end
