//
//  JACartViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACartViewController.h"
#import "JAConstants.h"
#import "RIForm.h"
#import "RIField.h"
#import "JALoginViewController.h"
#import "JAAddressesViewController.h"

@implementation JACartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // If the user is not logged in go to login view controller
    [self.goToLogin setTitle:@"Go to login" forState:UIControlStateNormal];
    [self.goToLogin sizeToFit];
    [self.goToLogin addTarget:self action:@selector(goToLoginAction) forControlEvents:UIControlEventTouchUpInside];
    
    // If the user is  logged in go to addresses view controller
    [self.loginAndGoToAddresses setTitle:@"Login and go to addresses" forState:UIControlStateNormal];
    [self.loginAndGoToAddresses sizeToFit];
    [self.loginAndGoToAddresses addTarget:self action:@selector(loginAndGoToAddressesAction) forControlEvents:UIControlEventTouchUpInside];
}


-(void)goToLoginAction
{
    JALoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    
    [self.navigationController pushViewController:loginVC
                                         animated:YES];
}

-(void)loginAndGoToAddressesAction
{
    [self showLoading];
    [RIForm getForm:@"login" successBlock:^(id form) {
        NSLog(@"Got login form with success");
        for (RIField *field in [form fields])
        {
            if([@"Alice_Module_Customer_Model_LoginForm[email]" isEqualToString:[field name]])
            {
                field.value = @"sofias@jumia.com";
            }
            else if([@"Alice_Module_Customer_Model_LoginForm[password]" isEqualToString:[field name]])
            {
                field.value = @"123456";
            }
        }
        [RIForm sendForm:form successBlock:^(NSDictionary *jsonObject) {
            NSLog(@"Login with success");
            [self hideLoading];
            
            JAAddressesViewController *addressesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesViewController"];
            
            [self.navigationController pushViewController:addressesVC
                                                 animated:YES];
            
        } andFailureBlock:^(NSArray *errorObject) {
            NSLog(@"Login failed");
            [self hideLoading];
        }];
    } failureBlock:^(NSArray *errorMessage) {
        NSLog(@"Failed getting login form");
        [self hideLoading];
    }];
}


@end
