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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //Setup Progress View
    [self.checkoutProgressViewControl setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.checkoutProgressViewControl requestUpdate];
    [self.continueButton setTitle:[self getTitleForContinueButton] forState:UIControlStateNormal];
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
        completion(nil);
    }
}

#pragma mark - Overrides
-(void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.showCartButton = NO;
}

#pragma mark - SideMenuProtocol
-(BOOL)getIsSideMenuAvailable {
    return NO;
}

#pragma mark - CheckoutProgressViewDelegate
-(NSArray *)getButtonsForCheckoutProgressView {
    return nil;
}

- (IBAction)continueButtonTapped:(id)sender {
    [self performPreDepartureAction:^(NSString *nextStep) {
        NSString *nextStepViewControllerSegueIdentifier = [self getNextStepViewControllerSegueIdentifier:nextStep];
        if(nextStepViewControllerSegueIdentifier) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:nextStepViewControllerSegueIdentifier sender:self];
            });
        }
    }];
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    return;
}

@end
