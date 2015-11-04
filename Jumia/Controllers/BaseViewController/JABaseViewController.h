//
//  JABaseViewController.h
//  Jumia
//
//  Created by Pedro Lopes on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANavigationBarLayout.h"
#import "JASearchResultsView.h"
#import "JATabBarView.h"

@interface JABaseViewController : UIViewController <UISearchBarDelegate, JASearchResultsViewDelegate>

@property (nonatomic, strong)JANavigationBarLayout* navBarLayout;

@property (nonatomic, strong)NSString *screenName;
@property (nonatomic, strong)NSDate *startLoadingTime;
@property (nonatomic, assign)BOOL firstLoading;
@property (nonatomic, assign)BOOL searchBarIsVisible;
@property (nonatomic, assign)BOOL tabBarIsVisible;
@property (nonatomic, assign)BOOL searchViewAlwaysHidden;

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
 * Method to show loading
 */
- (void)showLoading;

/**
 * Method to hide loading
 */
- (void)hideLoading;

/**
 * Method to show message view under navigation bar
 */
- (void)showMessage:(NSString*)message success:(BOOL)success;

/**
 * Method to remove message view under navigation bar
 */
- (void)removeMessageView;

/**
 * Method to show error view
 */
- (void)showErrorView:(BOOL)isNoInternetConnection startingY:(CGFloat)startingY selector:(SEL)selector objects:(NSArray*)objects;

/**
 * Method to remove error view
 */
- (void)removeErrorView;

/**
 * Method to show maintenance page
 */
- (void)showMaintenancePage:(SEL)selector objects:(NSArray*)objects;

/**
 * Method to remove maintenance page
 */
- (void)removeMaintenancePage;

/**
 * Method to show kickout view
 */
- (void)showKickoutView:(SEL)selector objects:(NSArray*)objects;

/**
 * Method to remove kickout view
 */
- (void)removeKickoutView;

/**
 * Method triggered when app will enter to foreground
 */
- (void)appWillEnterForeground;

/**
 * Method triggered when app did enter to foreground
 */
- (void)appDidEnterBackground;

@end

