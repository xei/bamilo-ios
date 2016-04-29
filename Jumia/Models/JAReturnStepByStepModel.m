//
//  JAReturnStepByStepModel.m
//  Jumia
//
//  Created by Jose Mota on 22/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAReturnStepByStepModel.h"

@implementation JAReturnStepByStepModel

- (NSArray *)viewControllersArray
{
//    return @[[JAAddressesViewController class], [JAShippingViewController class], [JAPaymentViewController class]];
    return @[];
}

/*
 *  this method tells the model which viewController we are ATM
 */
- (void)setup:(UIViewController *)viewController
{
    [super setup:viewController];
    // this can be a way to set freeToChoose parameter
//    if ([[self.viewControllersArray lastObject] isKindOfClass:[viewController class]]) {
//        self.freeToChoose = YES;
//    }
}

- (UIView *)goToIndex:(NSInteger)index
{
    return nil;
//    [self goToIndex:index];
//    switch (index) {
//        case 0:
//            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification object:@{@"stepByStepModel" : self}];
//            break;
//        case 1:
//            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutShippingScreenNotification object:@{@"stepByStepModel" : self}];
//            break;
//        case 2:
//            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutPaymentScreenNotification object:@{@"stepByStepModel" : self}];
//            break;
//        default:
//            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification object:@{@"stepByStepModel" : self}];
//            break;
//    }
}

@end
