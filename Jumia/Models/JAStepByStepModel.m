//
//  JAStepByStepModel.m
//  Jumia
//
//  Created by Jose Mota on 22/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAStepByStepModel.h"

@implementation JAStepByStepModel

- (BOOL)isFreeToChoose:(UIViewController *)viewController
{
    return NO;
}

- (UIImage *)getIconForIndex:(NSInteger)index
{
    if (!VALID_NOTEMPTY(self.iconsArray, NSArray) || !VALID_NOTEMPTY([self.iconsArray objectAtIndex:index], UIImage)) {
        return nil;
    }
    return [self.iconsArray objectAtIndex:index];
}

- (NSString *)getTitleForIndex:(NSInteger)index
{
    if (VALID_NOTEMPTY(self.titlesArray, NSArray) && self.titlesArray.count >index && VALID_NOTEMPTY([self.titlesArray objectAtIndex:index], NSString)) {
        return [self.titlesArray objectAtIndex:index];
    }
    return nil;
}

- (NSInteger)getIndexForViewController:(UIViewController *)viewController
{
    int i = 0;
    for (Class classKind in self.viewControllersArray) {
        if ([viewController isKindOfClass:classKind]) {
            return i;
        }
        i++;
    }
    return -1;
}

- (NSInteger)getIndexForClass:(Class)classKind
{
    int i = 0;
    for (Class otherClassKind in self.viewControllersArray) {
        if (otherClassKind == classKind) {
            return i;
        }
        i++;
    }
    return -1;
}

- (void)goToIndex:(NSInteger)index
{
}

- (BOOL)ignoreStep:(NSInteger)index
{
    return NO;
}

- (BOOL)isClassBase:(UIViewController *)viewController
{
    return [self.viewControllersArray indexOfObject:viewController.class] != NSNotFound;
}

@end
