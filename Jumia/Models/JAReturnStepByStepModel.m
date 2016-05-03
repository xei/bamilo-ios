//
//  JAReturnStepByStepModel.m
//  Jumia
//
//  Created by Jose Mota on 22/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAReturnStepByStepModel.h"
#import "JACenterNavigationController.h"
#import "JAORConfirmConditionsViewController.h"
#import "JAORConfirmationScreenViewController.h"

@implementation JAReturnStepByStepModel

- (NSArray *)viewControllersArray
{
    return @[[JAORConfirmConditionsViewController class], [JAORConfirmationScreenViewController class]];
}

- (NSArray *)iconsArray
{
    return @[[UIImage imageNamed:@"step_by_step_1"], [UIImage imageNamed:@"step_by_step_2"]];
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
    
    if (classKind == [JAORConfirmConditionsViewController class]) {
        [[JACenterNavigationController sharedInstance] goToOnlineReturnsConfirmConditions];
    } else if (classKind == [JAORConfirmationScreenViewController class]) {
        [[JACenterNavigationController sharedInstance] goToOnlineReturnsConfirmScreen];
    }
}

- (BOOL)ignoreStep:(NSInteger)index
{
    return [super ignoreStep:index];
}

@end
