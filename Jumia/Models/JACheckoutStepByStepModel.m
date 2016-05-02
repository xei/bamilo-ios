//
//  JACheckoutStepByStepModel.m
//  Jumia
//
//  Created by Jose Mota on 22/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JACheckoutStepByStepModel.h"
#import "JAAddressesViewController.h"
#import "JAEditAddressViewController.h"
#import "JAAddNewAddressViewController.h"
#import "JAShippingViewController.h"
#import "JAPaymentViewController.h"

@implementation JACheckoutStepByStepModel

- (NSArray *)viewControllersArray
{
    return @[[JAAddressesViewController class], [JAShippingViewController class], [JAPaymentViewController class]];
}

- (NSArray *)iconsArray
{
    return @[[UIImage imageNamed:@"checkout_address"], [UIImage imageNamed:@"checkout_shipping"], [UIImage imageNamed:@"checkout_payment"]];
}

- (NSArray *)titlesArray
{
    return @[@"Address", @"Shipping", @"Payment"];
}

/*
 *  this method tells the model which viewController we are ATM
 */
- (void)setup:(UIViewController *)viewController
{
    [super setup:viewController];
}

- (NSInteger)getIndexForViewController:(UIViewController *)viewController
{
    NSInteger index = [super getIndexForViewController:viewController];
    if (index == -1) {
        index = [self getIndexForClass:[viewController class]];
    }
    return index;
}

- (NSInteger)getIndexForClass:(Class)classKind
{
    NSInteger index = [self.viewControllersArray indexOfObject:classKind];
    if (index != NSNotFound) {
        return index;
    }
    if (classKind == [JAAddNewAddressViewController class] || classKind == [JAEditAddressViewController class]) {
        return [self getIndexForClass:[JAAddressesViewController class]];
    }else{
        return 0;
    }
}

- (void)goToIndex:(NSInteger)index
{
    switch (index) {
        case 0:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                                object:@{@"animated":[NSNumber numberWithBool:YES]}
                                                              userInfo:@{@"from_checkout":[NSNumber numberWithBool:YES]}];
        }
        case 1:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutShippingScreenNotification
                                                                    object:nil
                                                                  userInfo:nil]; //this screen loads the cart itself
        }
        case 2:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutPaymentScreenNotification
                                                                object:nil
                                                              userInfo:nil]; //this screen loads the cart itself
        }
        default:{
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                                object:@{@"animated":[NSNumber numberWithBool:YES]}
                                                              userInfo:@{@"from_checkout":[NSNumber numberWithBool:YES]}];
        }
    }
}

@end
