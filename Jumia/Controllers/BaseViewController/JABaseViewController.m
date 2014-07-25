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
#import "RIApi.h"

@interface JABaseViewController ()

@end

@implementation JABaseViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [RIApi startApiWithSuccessBlock:^(id api) {
        
        [self loginUser];
        
    } andFailureBlock:^(NSArray *errorMessage) {
        
    }];
}

- (void)loginUser
{
}

- (void)removeFromCart
{
    [RIOrders removeOrderFromCartWithQuantity:@"1"
                                          sku:@"SH660AAAC1MWNGAMZ-177254"
                             withSuccessBlock:^{
                                 
                                 [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                                             message:@"Product removed."
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"Ok", nil] show];
                                 
                             } andFailureBlock:^(NSArray *errorMessages) {
                                 
                                 [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                                             message:@"Error removing product"
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"Ok", nil] show];
                                 
                             }];
}

- (void)request3
{
    [RIOrders getCartChangeWithSuccessBlock:^(RICartData *cartData) {
        
        [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                    message:@"Cart change."
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
        
    } andFailureBlock:^(NSArray *errorMessages) {
        
        [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                    message:@"Error in cart change"
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
        
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

- (void)addProductToCart
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
                          
                          [self request3];
                          
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
