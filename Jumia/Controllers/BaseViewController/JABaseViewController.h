//
//  JABaseViewController.h
//  Jumia
//
//  Created by Pedro Lopes on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANavigationBarLayout.h"

@interface JABaseViewController : UIViewController

@property (nonatomic, strong)JANavigationBarLayout* navBarLayout;

@property (nonatomic, strong)NSString *screenName;
@property (nonatomic, strong)NSDate *startLoadingTime;
@property (nonatomic, assign)BOOL firstLoading;

/**
 * Method to force Nav bar to reload. This is called in viewWillAppear
 */
- (void)reloadNavBar;

/**
 * Method to show loading
 */
- (void)showLoading;

/**
 * Method to hide loading
 */
- (void)hideLoading;


- (void)showMessage:(NSString*)message success:(BOOL)success;

@end

