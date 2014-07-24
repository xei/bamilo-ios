//
//  JABaseViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RIOrders.h"
#import "RICustomer.h"

@interface JABaseViewController ()

@end

@implementation JABaseViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [RICustomer loginCustomerWithSuccessBlock:^(id customer) {
        
        [self loadOtherRequest];
        
    } andFailureBlock:^(NSArray *errorObject) {
        
    }];
}

- (void)loadOtherRequest
{
    [RIOrders getCartDataWithSuccessBlock:^(RICartData *cartData) {
        
        [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                    message:@"Obtained the cart data."
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
        
    } andFailureBlock:^(NSArray *errorMessages) {
        
        [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                    message:@"Error getting cart data"
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
        
    }];
}

- (void)loadAnotherRequest
{
    [RIOrders addOrderWithCartQuantity:@"1"
                                   sku:@"SH660AAAC1MWNGAMZ-177254"
                                simple:@"SH660AAAC1MWNGAMZ"
                      withSuccessBlock:^(NSInteger orderID) {
                          
                          [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                                      message:@"Order added"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"Ok", nil] show];
                          
                      } andFailureBlock:^(NSArray *errorMessages) {
                          
                          [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                                      message:@"Error adding order"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"Ok", nil] show];
                          
                      }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
