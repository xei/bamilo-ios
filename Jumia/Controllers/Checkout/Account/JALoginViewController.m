//
//  JALoginViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JALoginViewController.h"
#import "RIForm.h"
#import "RIField.h"
#import "JAAddressesViewController.h"

@interface JALoginViewController ()

@end

@implementation JALoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.loginAndGoToAddresses setTitle:@"Login and go to addresses" forState:UIControlStateNormal];
    [self.loginAndGoToAddresses sizeToFit];
    
    [self.loginAndGoToAddresses addTarget:self action:@selector(loginAndGoToAddressesAction) forControlEvents:UIControlEventTouchUpInside];
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
