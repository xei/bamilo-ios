//
//  JACenterNavigationController.m
//  Jumia
//
//  Created by Miguel Chaves on 31/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACenterNavigationController.h"
#import "JANavigationBarView.h"
#import "JASplashViewController.h"
#import "RICart.h"
#import "JAHomeViewController.h"
#import "JAMyFavouritesViewController.h"
#import "JAChooseCountryViewController.h"
#import "JARecentSearchesViewController.h"
#import "JACatalogViewController.h"
#import "JAPDVViewController.h"
#import "JACategoriesViewController.h"
#import "JARecentlyViewedViewController.h"
#import "JACartViewController.h"
#import "JAForgotPasswordViewController.h"
#import "JALoginViewController.h"
#import "JAAddressesViewController.h"
#import "JASignInViewController.h"
#import "JASignupViewController.h"
#import "RIProduct.h"
#import "RIApi.h"
#import "JANavigationBarLayout.h"

@interface JACenterNavigationController ()

@property (strong, nonatomic) RICart *cart;

@end

@implementation JACenterNavigationController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customizeNavigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectCountry:)
                                                 name:kSelectedCountryNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectRecentSearch:)
                                                 name:kSelectedRecentSearchNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectItemInMenu:)
                                                 name:kMenuDidSelectOptionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectLeafCategoryInMenu:)
                                                 name:kMenuDidSelectLeafCategoryNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openCart)
                                                 name:kOpenCartNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCart:)
                                                 name:kUpdateCartNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeEditButtonState:)
                                                 name:kEditShouldChangeStateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeDoneButtonState:)
                                                 name:kDoneShouldChangeStateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectTeaserWithCatalogUrl:)
                                                 name:kDidSelectTeaserWithCatalogUrlNofication
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectTeaserWithPDVUrl:)
                                                 name:kDidSelectTeaserWithPDVUrlNofication
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectTeaserWithAllCategories)
                                                 name:kDidSelectTeaserWithAllCategoriesNofication
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectCategoryFromCenterPanel:)
                                                 name:kDidSelectCategoryFromCenterPanelNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showHomeScreen)
                                                 name:kShowHomeScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeNavigationWithNotification:)
                                                 name:kChangeNavigationBarNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showForgotPasswordScreen)
                                                 name:kShowForgotPasswordScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutLoginScreen)
                                                 name:kShowCheckoutLoginScreenNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutAddressesScreen)
                                                 name:kShowCheckoutAddressesScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSignUpScreen)
                                                 name:kShowSignUpScreenNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Left Menu Actions

- (void)didSelectItemInMenu:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSDictionary *selectedItem = [notification object];
    
    if ([selectedItem objectForKey:@"index"]) {
        NSNumber *index = [selectedItem objectForKey:@"index"];
        
        if ([index isEqual:@(0)]) {
            [self changeCenterPanel:@"Home"];
            
        } else {
            if ([index isEqual:@(99)])
            {
                // It's to perform a search
                [self pushCatalogToShowSearchResults:[selectedItem objectForKey:@"text"]];
            }
            else
            {
                [self changeCenterPanel:[selectedItem objectForKey:@"name"]];
            }
        }
    }
}

- (void)changeCenterPanel:(NSString *)newScreenName
{
    if ([newScreenName isEqualToString:@"Home"])
    {
        if (![[self topViewController] isKindOfClass:[JAHomeViewController class]])
        {
            JAHomeViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
            
            [self pushViewController:home
                            animated:YES];
            
            self.viewControllers = @[home];
        }
    }
    else if ([newScreenName isEqualToString:@"My Favourites"])
    {
        if (![[self topViewController] isKindOfClass:[JAMyFavouritesViewController class]])
        {
            JAMyFavouritesViewController *favourites = [self.storyboard instantiateViewControllerWithIdentifier:@"myFavouritesViewController"];
            
            [self pushViewController:favourites
                            animated:YES];
            
            self.viewControllers = @[favourites];
        }
    }
    else if ([newScreenName isEqualToString:@"Choose Country"])
    {
        if (![[self topViewController] isKindOfClass:[JAChooseCountryViewController class]])
        {
            JAChooseCountryViewController *country = [self.storyboard instantiateViewControllerWithIdentifier:@"chooseCountryViewController"];
            
            [self pushViewController:country
                            animated:YES];
        }
    }
    else if ([newScreenName isEqualToString:@"Recent Searches"])
    {
        if (![[self topViewController] isKindOfClass:[JARecentSearchesViewController class]])
        {
            JARecentSearchesViewController *searches = [self.storyboard instantiateViewControllerWithIdentifier:@"recentSearchesViewController"];
            
            [self pushViewController:searches
                            animated:YES];
            
            self.viewControllers = @[searches];
        }
    }
    else if ([newScreenName isEqualToString:@"Sign In"])
    {
        if (![[self topViewController] isKindOfClass:[JASignInViewController class]])
        {
            JASignInViewController *signInViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
            
            [self pushViewController:signInViewController
                            animated:YES];
            
            self.viewControllers = @[signInViewController];
        }
    }
    else if ([newScreenName isEqualToString:@"Recently Viewed"])
    {
        if (![[self topViewController] isKindOfClass:[JARecentlyViewedViewController class]])
        {
            JARecentlyViewedViewController *recentlyViewed = [self.storyboard instantiateViewControllerWithIdentifier:@"recentlyViewedViewController"];
            
            [self pushViewController:recentlyViewed
                            animated:YES];
            
            self.viewControllers = @[recentlyViewed];
        }
    }
}

- (void)pushCatalogToShowSearchResults:(NSString *)query
{
    JACatalogViewController *catalog = [self.storyboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
    catalog.searchString = query;
    
    catalog.navBarLayout.title = query;
    
    [self pushViewController:catalog
                    animated:YES];
    
    self.viewControllers = @[catalog];
}

- (void)didSelectLeafCategoryInMenu:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSDictionary *selectedItem = [notification object];
    
    RICategory* category = [selectedItem objectForKey:@"category"];
    if (VALID_NOTEMPTY(category, RICategory)) {
        
        JACatalogViewController *catalog = [self.storyboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
        
        catalog.navBarLayout.title = category.name;
        catalog.category = category;
        
        [self pushViewController:catalog
                        animated:YES];
        
        self.viewControllers = @[catalog];
    }
}

- (void) showHomeScreen
{
    [self changeCenterPanel:@"Home"];
}

#pragma mark - Teaser Actions

- (void)didSelectTeaserWithCatalogUrl:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSString* url = [notification.userInfo objectForKey:@"url"];
    NSString* title = [notification.userInfo objectForKey:@"title"];
    
    if (VALID_NOTEMPTY(url, NSString)) {
        
        JACatalogViewController *catalog = [self.storyboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
        
        catalog.catalogUrl = url;
        catalog.navBarLayout.title = title;
        catalog.navBarLayout.backButtonTitle = @"Home";
        
        [self pushViewController:catalog
                        animated:YES];
    }
}

- (void)didSelectTeaserWithPDVUrl:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSString* url = [notification.userInfo objectForKey:@"url"];
    
    if (VALID_NOTEMPTY(url, NSString)) {
        
        JAPDVViewController *pdv = [self.storyboard instantiateViewControllerWithIdentifier:@"pdvViewController"];
        pdv.productUrl = url;
        pdv.fromCatalogue = NO;
        pdv.previousCategory = @"Home";
        
        [self pushViewController:pdv
                        animated:YES];
    }
}

- (void)didSelectTeaserWithAllCategories
{
    JACategoriesViewController* categoriesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"categoriesViewController"];
    
    categoriesViewController.navBarLayout.title = @"All Categories";
    categoriesViewController.navBarLayout.backButtonTitle = @"Home";
    
    [self pushViewController:categoriesViewController animated:YES];
}

- (void)didSelectCategoryFromCenterPanel:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSDictionary *selectedItem = [notification object];
    
    RICategory* category = [selectedItem objectForKey:@"category"];
    if (VALID_NOTEMPTY(category, RICategory)) {
        
        JACatalogViewController *catalog = [self.storyboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
        
        catalog.category = category;
        
        catalog.navBarLayout.title = category.name;
        catalog.navBarLayout.backButtonTitle = @"All Categories";
        
        [self pushViewController:catalog
                        animated:YES];
    }
}

- (void)showForgotPasswordScreen
{
    JAForgotPasswordViewController *forgotVC = [self.storyboard instantiateViewControllerWithIdentifier:@"forgotPasswordViewController"];
    
    [self pushViewController:forgotVC animated:YES];
}

- (void)showCheckoutLoginScreen
{
    JALoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    
    [self pushViewController:loginVC animated:YES];
}

- (void)showCheckoutAddressesScreen
{
    JAAddressesViewController *addressesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesViewController"];
    
    [self pushViewController:addressesVC animated:YES];
}

- (void)showSignUpScreen
{
    JASignupViewController *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"signUpViewController"];
    
    [self pushViewController:signUpVC animated:YES];
}

#pragma mark - Choose Country

- (void)didSelectCountry:(NSNotification*)notification
{
    RICountry *country = notification.object;
    if (VALID_NOTEMPTY(country, RICountry)) {
        UINavigationController* rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
        JASplashViewController *splash = [self.storyboard instantiateViewControllerWithIdentifier:@"splashViewController"];
        splash.selectedCountry = country;
        rootViewController.viewControllers = @[splash];
        
        [[[UIApplication sharedApplication] delegate] window].rootViewController = rootViewController;
    }
}

#pragma mark - Recent Search

- (void)didSelectRecentSearch:(NSNotification*)notification
{
    RISearchSuggestion *recentSearch = notification.object;
    
    if (VALID_NOTEMPTY(recentSearch, RISearchSuggestion)) {
        JACatalogViewController *catalog = [self.storyboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
        catalog.searchString = recentSearch.item;
        
        catalog.navBarLayout.title = recentSearch.item;
        
        [self pushViewController:catalog
                        animated:YES];
    }
}



#pragma mark - Navigation Bar

- (void)customizeNavigationBar
{
    [self.navigationItem setHidesBackButton:YES
                                   animated:NO];
    
    self.navigationBarView = [JANavigationBarView getNewNavBarView];
    [self.navigationBarView initialSetup];
    
    [self.navigationBar.viewForBaselineLayout addSubview:self.navigationBarView];
    
    [self.navigationBarView.cartButton addTarget:self
                                          action:@selector(openCart)
                                forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView.leftButton addTarget:self
                                          action:@selector(openMenu)
                                forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView.doneButton addTarget:self
                                          action:@selector(done)
                                forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView.editButton addTarget:self
                                          action:@selector(edit)
                                forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView.backButton addTarget:self
                                          action:@selector(back)
                                forControlEvents:UIControlEventTouchUpInside];
}

- (void)changeNavigationWithNotification:(NSNotification*)notification
{
    JANavigationBarLayout* layout = notification.object;
    if (VALID_NOTEMPTY(layout, JANavigationBarLayout)) {
        [self.navigationBarView setupWithNavigationBarLayout:layout];
    }
}

- (void)changeEditButtonState:(NSNotification *)notification
{
    NSNumber* state = [notification.userInfo objectForKey:@"enabled"];
    self.navigationBarView.editButton.enabled = [state boolValue];
}

- (void)changeDoneButtonState:(NSNotification *)notification
{
    NSNumber* state = [notification.userInfo objectForKey:@"enabled"];
    self.navigationBarView.doneButton.enabled = [state boolValue];
}

- (void)updateCart:(NSNotification*) notification
{
    NSDictionary* userInfo = notification.userInfo;
    self.cart = [userInfo objectForKey:kUpdateCartNotificationValue];
    
    [self.navigationBarView updateCartProductCount:self.cart.cartCount];
}


#pragma mark - Navbar Button actions

- (void)back
{
    [self popViewControllerAnimated:YES];
}

- (void)done
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidPressDoneNotification
                                                        object:nil];
    [self back];
}

- (void)edit
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidPressEditNotification
                                                        object:nil];
}

- (void)openCart
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    if (![[self topViewController] isKindOfClass:[JACartViewController class]])
    {
        
        JACartViewController *cartViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"cartViewController"];
        [cartViewController setCart:self.cart];
        
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:cartViewController animated:YES];
    }
}

- (void)openMenu
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenMenuNotification
                                                        object:nil];
}

@end
