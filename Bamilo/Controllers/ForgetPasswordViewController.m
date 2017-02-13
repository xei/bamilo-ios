
//
//  ForgetPasswordViewController.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ForgetPasswordViewController.h"

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    self.navBarLayout.title = @"فراموشی رمز";
}


#pragma mark - Overrides
-(void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.showCartButton = NO;
}


@end
