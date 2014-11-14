//
//  JASubFiltersViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 13/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JASubFiltersViewController;

@protocol JASubFiltersViewControllerDelegate <NSObject>

- (void)isClosing:(JASubFiltersViewController*)viewController;

@end

@interface JASubFiltersViewController : JABaseViewController

- (void)doneButtonPressed;
- (void)backButtonPressed;

@property (nonatomic, assign)id<JASubFiltersViewControllerDelegate>delegate;

@end
