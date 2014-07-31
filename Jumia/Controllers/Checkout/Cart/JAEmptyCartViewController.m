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
    
    // TODO: Check if cart is empty..
    // If the cart is empty this should be redirected to a empty cart page
    [RICart addProductWithQuantity:@"1"
                               sku:@"JU278SPACGWSAFRAMZ"
                            simple:@"JU278SPACGWSAFRAMZ-171186"
                  withSuccessBlock:^(RICart *cart) {
                      NSLog(@"Added product with success");
                      
                      NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
                      [userInfo setObject:cart forKey:kUpdateCartNotificationValue];
                      
                      NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
                      [notificationCenter postNotificationName:kUpdateCartNotification object:self userInfo:userInfo];
                      
                      
                  } andFailureBlock:^(NSArray *errorMessages) {
                      NSLog(@"Fail adding product");
                  }];
    
}

@end
