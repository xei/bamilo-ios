//
//  JAStepByStepModel.h
//  Jumia
//
//  Created by Jose Mota on 22/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAStepByStepModel : NSObject

@property (nonatomic, strong) NSArray *viewControllersArray;
@property (nonatomic, strong) NSArray *iconsArray;
@property (nonatomic, strong) NSArray *titlesArray;

- (BOOL)isFreeToChoose:(UIViewController *)viewController;
- (NSInteger)getIndexForViewController:(UIViewController *)viewController;
- (NSInteger)getIndexForClass:(Class)classKind;
- (UIImage *)getIconForIndex:(NSInteger)index;
- (NSString *)getTitleForIndex:(NSInteger)index;

- (void)goToIndex:(NSInteger)index;
- (BOOL)ignoreStep:(NSInteger)index;

@end
