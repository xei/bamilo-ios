////
////  JACheckoutStepByStepModel.m
////  Jumia
////
////  Created by Jose Mota on 22/04/16.
////  Copyright © 2016 Rocket Internet. All rights reserved.
////
//
//#import "JACheckoutStepByStepModel.h"
//#import "JAAddressesViewController.h"
//#import "JAEditAddressViewController.h"
//#import "JAAddNewAddressViewController.h"
//#import "JAShippingViewController.h"
//#import "JAPaymentViewController.h"
//#import "JAAuthenticationViewController.h"
//#import "JASignInViewController.h"
//#import "JARegisterViewController.h"
//#import "JAForgotPasswordViewController.h"
//
//@implementation JACheckoutStepByStepModel
//
//- (NSArray *)viewControllersArray
//{
//    return @[[JAAuthenticationViewController class], [JAAddressesViewController class], [JAShippingViewController class], [JAPaymentViewController class]];
//}
//
//- (NSArray *)iconsArray
//{
//    return @[[UIImage imageNamed:@"checkout_login"], [UIImage imageNamed:@"checkout_address"], [UIImage imageNamed:@"checkout_shipping"], [UIImage imageNamed:@"checkout_payment"]];
//}
//
//- (NSArray *)titlesArray
//{
//    return @[STRING_CHECKOUT_ABOUT_YOU, STRING_CHECKOUT_ADDRESS, STRING_CHECKOUT_SHIPPING, STRING_CHECKOUT_PAYMENT];
//}
//
//- (BOOL)isFreeToChoose:(UIViewController *)viewController
//{
//    return [super isFreeToChoose:viewController];
//}
//
//- (NSInteger)getIndexForViewController:(UIViewController *)viewController
//{
//    NSInteger index = [super getIndexForViewController:viewController];
//    if (index == -1) {
//        index = [self getIndexForClass:[viewController class]];
//    }
//    return index;
//}
//
//- (NSInteger)getIndexForClass:(Class)classKind
//{
//    NSInteger index = [self.viewControllersArray indexOfObject:classKind];
//    if (index != NSNotFound) {
//        return index;
//    }
//    if (classKind == [JAAddNewAddressViewController class] || classKind == [JAEditAddressViewController class]) {
//        return [self getIndexForClass:[JAAddressesViewController class]];
//    }else if (classKind == [JASignInViewController class] || classKind == [JARegisterViewController class] || classKind == [JAForgotPasswordViewController class]) {
//        return [self getIndexForClass:[JAAuthenticationViewController class]];
//    }else{
//        return 0;
//    }
//}
//
//- (void)goToIndex:(NSInteger)index
//{
//    Class classKind = [self.viewControllersArray objectAtIndex:index];
//    
//    if (classKind == [JAAuthenticationViewController class]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
//                                                            object:@{@"animated":[NSNumber numberWithBool:YES]}
//                                                          userInfo:@{@"from_checkout":[NSNumber numberWithBool:YES]}];
//    } else if (classKind == [JAShippingViewController class]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutShippingScreenNotification
//                                                            object:nil
//                                                          userInfo:nil]; //this screen loads the cart itself
//    } else if (classKind == [JAPaymentViewController class]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutPaymentScreenNotification
//                                                            object:nil
//                                                          userInfo:nil]; //this screen loads the cart itself
//    }
//}
//
//- (BOOL)ignoreStep:(NSInteger)index
//{
//    if (index == 0) {
//        return YES;
//    }
//    return [super ignoreStep:index];
//}
//
//@end
