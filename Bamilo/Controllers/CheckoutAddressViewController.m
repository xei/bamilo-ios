//
//  CheckoutAddressViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"
#import "CheckoutAddressViewController.h"
#import "CheckoutProgressViewButtonModel.h"
#import "ViewControllerManager.h"
#import "AddressViewController.h"

@interface CheckoutAddressViewController()
@property (weak, nonatomic) IBOutlet UIView *addressView;
@end

@implementation CheckoutAddressViewController
-(void)viewDidLoad {
    [super viewDidLoad];
    
    AddressViewController *addressViewController = (AddressViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"AddressViewController"];
    [self addChildViewController:addressViewController];
    addressViewController.view.frame = self.addressView.frame;
    addressViewController.titleHeaderText = STRING_PLEASE_CHOOSE_YOUR_ADDRESS;
    self.addressView = addressViewController.view;
    [addressViewController didMoveToParentViewController:self];
}

#pragma mark - Overrides
-(NSString *)getNextStepViewControllerSegueIdentifier {
    return @"pushAddressToReview";
}

-(void)updateNavBar {
    [super updateNavBar];

    self.navBarLayout.title = STRING_CHOOSE_ADDRESS;
}

#pragma mark - CheckoutProgressViewDelegate
-(NSArray *)getButtonsForCheckoutProgressView {
    return @[
        [CheckoutProgressViewButtonModel buttonWith:1 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE],
        [CheckoutProgressViewButtonModel buttonWith:2 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING],
        [CheckoutProgressViewButtonModel buttonWith:3 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING]
    ];
}

@end
