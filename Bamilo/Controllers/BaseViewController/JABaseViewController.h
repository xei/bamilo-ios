//
//  JABaseViewController.h
//  Jumia
//
//  Created by Pedro Lopes on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMA4SViewController.h"
#import "JANavigationBarLayout.h"
#import "JATabBarView.h"
#import "JAScreenTarget.h"
#import "PerformanceTrackerProtocol.h"

@interface JABaseViewController : BMA4SViewController <PerformanceTrackerProtocol, UISearchBarDelegate>

@property (nonatomic, strong)JANavigationBarLayout* navBarLayout;

//@property (nonatomic, strong)NSString *screenName;
//@property (nonatomic, strong)NSDate *startLoadingTime;
//@property (nonatomic, assign)BOOL firstLoading;
@property (nonatomic, assign)BOOL searchBarIsVisible;
@property (nonatomic, assign)BOOL tabBarIsVisible;

@property (nonatomic, strong) UIImageView *searchIconImageView;

@property (nonatomic, strong) NSString *targetString;

@property (nonatomic) BOOL isIpad;
@property (nonatomic) BOOL isIpadLandscape;

/**
 * This method returns the correct bounds to be used, taking the searchBar positioning into account
 */
- (CGRect)viewBounds;
- (CGRect)bounds;

/**
 * Method to force Nav bar to reload. This is called in viewWillAppear
 */
- (void)reloadNavBar;

/**
 * Method to set SearchBar text
 */
- (void)setSearchBarText:(NSString*)text;

/**
 * Method to show loading
 */
- (void)showLoading;

/**
 * Method to hide loading
 */
- (void)hideLoading;

/**
 * Method to show success message view under navigation bar and to remove error view
 */
- (void)onSuccessResponse:(RIApiResponse)apiResponse messages:(NSArray *)successMessages showMessage:(BOOL)showMessage;

/**
 * Method to show error view or to show error message under navigation bar 
 */
- (void)showMessage:(NSString *)message success:(BOOL)success;
- (void)onErrorResponse:(RIApiResponse)apiResponse messages:(NSArray *)errorMessages showAsMessage:(BOOL)showAsMessage target:(id)target selector:(SEL)selector objects:(NSArray *)objects;
- (void)onErrorResponse:(RIApiResponse)apiResponse messages:(NSArray *)errorMessages showAsMessage:(BOOL)showAsMessage selector:(SEL)selector objects:(NSArray *)objects;

/**
 * Method triggered when app will enter to foreground
 */
- (void)appWillEnterForeground;

/**
 * Method triggered when app did enter to foreground
 */
- (void)appDidEnterBackground;

- (void)onOrientationChanged;

@end

