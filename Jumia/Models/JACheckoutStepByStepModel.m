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

@interface JACheckoutStepByStepModel ()

@property (nonatomic, strong) NSMutableDictionary *viewControllersInstancesDictionary;

@end

@implementation JACheckoutStepByStepModel

- (NSMutableDictionary *)viewControllersInstancesDictionary
{
    if (!VALID_NOTEMPTY(_viewControllersInstancesDictionary, NSMutableDictionary)) {
        _viewControllersInstancesDictionary = [NSMutableDictionary new];
    }
    return _viewControllersInstancesDictionary;
}

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

- (UIViewController *)goToIndex:(NSInteger)index
{
    if ([self.viewControllersInstancesDictionary objectForKey:[self.viewControllersArray objectAtIndex:index]]) {
        return [self.viewControllersInstancesDictionary objectForKey:[self.viewControllersArray objectAtIndex:index]];
    }
    switch (index) {
        case 0:{
            JAAddressesViewController *viewController = [[JAAddressesViewController alloc] init];
            [viewController setFromCheckout:YES];
            [self.viewControllersInstancesDictionary setObject:viewController forKey:[self.viewControllersArray objectAtIndex:index]];
            viewController.view.tag = 0;
            return viewController;
        }
        case 1:{
            JAShippingViewController *viewController = [[JAShippingViewController alloc] init];
            [self.viewControllersInstancesDictionary setObject:viewController forKey:[self.viewControllersArray objectAtIndex:index]];
            viewController.view.tag = 1;
            return viewController;
        }
        case 2:{
            JAPaymentViewController *viewController = [[JAPaymentViewController alloc] init];
            [self.viewControllersInstancesDictionary setObject:viewController forKey:[self.viewControllersArray objectAtIndex:index]];
            viewController.view.tag = 2;
            return viewController;
        }
        default:{
            JAAddressesViewController *viewController = [[JAAddressesViewController alloc] init];
            [viewController setFromCheckout:YES];
            [self.viewControllersInstancesDictionary setObject:viewController forKey:[self.viewControllersArray objectAtIndex:index]];
            viewController.view.tag = 0;
            return viewController;
        }
    }
}

@end
