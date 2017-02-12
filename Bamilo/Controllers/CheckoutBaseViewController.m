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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods
-(NSString *)getNextStepViewControllerSegueIdentifier {
    return nil;
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
    NSString *nextStepViewControllerSegueIdentifier = [self getNextStepViewControllerSegueIdentifier];
    if(nextStepViewControllerSegueIdentifier) {
        [self performSegueWithIdentifier:nextStepViewControllerSegueIdentifier sender:self];
    }
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    return;
}

@end
