//
//  JAReturnStepByStepModel.m
//  Jumia
//
//  Created by Jose Mota on 22/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAReturnStepByStepModel.h"
#import "JACenterNavigationController.h"
#import "JAORConfirmationScreenViewController.h"
#import "JAORReasonsViewController.h"
#import "JAORWaysViewController.h"
#import "JAORPaymentViewController.h"
#import "Bamilo-Swift.h"

@implementation JAReturnStepByStepModel

- (NSArray *)viewControllersArray
{
    return @[[JAORReasonsViewController class], [JAORWaysViewController class], [JAORPaymentViewController class], [JAORConfirmationScreenViewController class]];
}

- (NSArray *)iconsArray
{
    return @[[UIImage imageNamed:@"step_by_step_1"], [UIImage imageNamed:@"step_by_step_2"], [UIImage imageNamed:@"step_by_step_3"], [UIImage imageNamed:@"step_by_step_4"]];
}

- (BOOL)isFreeToChoose:(UIViewController *)viewController
{
    if (viewController.class == [self.viewControllersArray lastObject]) {
        return YES;
    }
    return [super isFreeToChoose:viewController];
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
    return 0;
}

- (void)goToIndex:(NSInteger)index
{
    Class classKind = [self.viewControllersArray objectAtIndex:index];
    
    if (classKind == [JAORReasonsViewController class]) {
        [[MainTabBarViewController topNavigationController] goToOnlineReturnsReasonsScreenForItems:self.items order:self.order];
    } else if (classKind == [JAORWaysViewController class]) {
        [[MainTabBarViewController topNavigationController] goToOnlineReturnsWaysScreenForItems:self.items order:self.order];
    } else if (classKind == [JAORPaymentViewController class]) {
        [[MainTabBarViewController topNavigationController] goToOnlineReturnsPaymentScreenForItems:self.items order:self.order];
    } else if (classKind == [JAORConfirmationScreenViewController class]) {
        [[MainTabBarViewController topNavigationController] goToOnlineReturnsConfirmScreenForItems:self.items order:self.order];
    }
}

- (BOOL)ignoreStep:(NSInteger)index
{
    return [super ignoreStep:index];
}

@end
