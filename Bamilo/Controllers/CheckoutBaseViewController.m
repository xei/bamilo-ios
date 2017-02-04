//
//  CheckoutBaseViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutBaseViewController.h"

@implementation CheckoutBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
