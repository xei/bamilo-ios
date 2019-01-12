//
//  CheckoutBaseViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutBaseViewController.h"
#import "OrangeButton.h"

@interface CheckoutBaseViewController()
@property (weak, nonatomic) IBOutlet CheckoutProgressViewControl *checkoutProgressViewControl;
@property (weak, nonatomic) IBOutlet OrangeButton *continueButton;
- (IBAction)continueButtonTapped:(id)sender;
@end

@implementation CheckoutBaseViewController

-(void)setIsStepValid:(BOOL)isStepValid {
    [self.continueButton setEnabled:isStepValid];
    _isStepValid = isStepValid;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.continueButton.layer.cornerRadius = self.continueButtonHeightConstraint.constant / 2;
    
    //Setup Progress View
    [self.checkoutProgressViewControl setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.checkoutProgressViewControl requestUpdate];
    [self.continueButton setTitle:[self getTitleForContinueButton] forState:UIControlStateNormal];
    
    [self setIsStepValid:YES];
}

#pragma mark - Public Methods
-(NSString *)getTitleForContinueButton {
    return nil;
}

-(NSString *)getNextStepViewControllerSegueIdentifier:(NSString *)serviceIdentifier {
    return nil;
}

-(void)performPreDepartureAction:(CheckoutActionCompletion)completion {
    if(completion) {
        completion(nil, NO);
    }
}

#pragma mark - SideMenuProtocol
-(BOOL)getIsSideMenuAvailable {
    return NO;
}

#pragma mark - CheckoutProgressViewDelegate
-(NSArray *)getButtonsForCheckoutProgressView {
    return nil;
}

-(void)checkoutProgressViewButtonTapped:(id)sender {
    UIButton *checkoutProgressViewButton = (UIButton *)sender;
    [self popToCheckoutViewControllerAtStep:(int)checkoutProgressViewButton.tag];
}

- (IBAction)continueButtonTapped:(id)sender {
    [self performPreDepartureAction:^(NSString *nextStep, BOOL success) {
        if(success == YES) {
            NSString *nextStepViewControllerSegueIdentifier = [self getNextStepViewControllerSegueIdentifier:nextStep];
            if(nextStepViewControllerSegueIdentifier) {
//                dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:nextStepViewControllerSegueIdentifier sender:self];
//                });
            }
        }
    }];
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    return;
}

#pragma mark - Helpers
-(void) popToCheckoutViewControllerAtStep:(int)step {
    if(step < self.navigationController.viewControllers.count) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:step] animated:YES];
    }
}

#pragma mark - hide tabbar in this view controller 
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

@end
