//
//  JAEmptyCartViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAEmptyCartViewController.h"
#import "RICart.h"

@implementation JAEmptyCartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;
    self.title = @"";
    
    
    [self.addProductAndGoToCart setTitle:@"Add product and go to cart" forState:UIControlStateNormal];
    [self.addProductAndGoToCart sizeToFit];
    
    [self.addProductAndGoToCart addTarget:self action:@selector(addProductAndGoToCartAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addProductAndGoToCartAction
{
    [self showLoading];
    
    [RICart addProductWithQuantity:@"1"
                               sku:@"ET938AAABUQKNGAMZ"
                            simple:@"ET938AAABUQKNGAMZ-156048"
                  withSuccessBlock:^(RICart *cart) {
                      NSLog(@"Added product with success");
                      
                      [self hideLoading];
                      
                      NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
                      [userInfo setObject:cart forKey:kUpdateCartNotificationValue];
                      
                      NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
                      [notificationCenter postNotificationName:kUpdateCartNotification object:self userInfo:userInfo];                      
                      
                      [notificationCenter postNotificationName:kOpenCartNotification object:self userInfo:nil];
                      
                  } andFailureBlock:^(NSArray *errorMessages) {
                      NSLog(@"Fail adding product");
                      [self hideLoading];
                  }];
}

@end
