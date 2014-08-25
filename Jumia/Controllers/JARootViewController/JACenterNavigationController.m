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
#import "JAMyAccountViewController.h"
#import "JARecentlyViewedViewController.h"
#import "JACartViewController.h"
#import "RIProduct.h"
#import "RIApi.h"

@interface JACenterNavigationController ()
<
JAChooseCountryDelegate,
JARecentSearchesDelegate
>

@property (strong, nonatomic) RICart *cart;

@end

@implementation JACenterNavigationController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customizeNavigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectedItemInMenu:)
                                                 name:kMenuDidSelectOptionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectedLeafCategoryInMenu:)
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
                                             selector:@selector(showBackButton)
                                                 name:kShowBackNofication
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeEditButtonState:)
                                                 name:kEditShouldChangeStateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeBackButtonForTitle:)
                                                 name:kShowBackButtonWithTitleNofication
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMainFiltersNavigation)
                                                 name:kShowMainFiltersNavNofication
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpecificFilterNavigation:)
                                                 name:kShowSpecificFilterNavNofication
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Open menus

- (void)openMenu
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenMenuNotification
                                                        object:nil];
}

- (void)openCart
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    if (![[self topViewController] isKindOfClass:[JACartViewController class]])
    {
        
        [self.navigationBarView changeNavigationBarTitle:@"Cart"];
        
        JACartViewController *cartViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"cartViewController"];
        [cartViewController setCart:self.cart];
        
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:cartViewController animated:YES];
    }
}

- (void)updateCart:(NSNotification*) notification
{
    if ([kUpdateCartNotification isEqualToString:notification.name])
    {
        NSDictionary* userInfo = notification.userInfo;
        self.cart = [userInfo objectForKey:kUpdateCartNotificationValue];
        
        [self.navigationBarView updateCartProductCount:self.cart.cartCount];
    }
}

- (void)changeCenterPanel:(NSString *)newScreenName
           titleForNavBar:(NSString *)title
{
    if ([newScreenName isEqualToString:@"Home"])
    {
        if (![self.viewControllers.lastObject isKindOfClass:[JAHomeViewController class]])
        {
            JAHomeViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
            
            [self pushViewController:home
                            animated:YES];
            [self.navigationBarView changedToHomeViewController];
            
            self.viewControllers = @[home];
        }
    }
    else if ([newScreenName isEqualToString:@"My Favourites"])
    {
        if (![self.viewControllers.lastObject isKindOfClass:[JAMyFavouritesViewController class]])
        {
            JAMyFavouritesViewController *favourites = [self.storyboard instantiateViewControllerWithIdentifier:@"myFavouritesViewController"];
            
            [self pushViewController:favourites
                            animated:YES];
            
            [self.navigationBarView changeNavigationBarTitle:title];
            
            self.viewControllers = @[favourites];
        }
    }
    else if ([newScreenName isEqualToString:@"Choose Country"])
    {
        if (![self.viewControllers.lastObject isKindOfClass:[JAChooseCountryViewController class]])
        {
            JAChooseCountryViewController *country = [self.storyboard instantiateViewControllerWithIdentifier:@"chooseCountryViewController"];
            country.delegate = self;
            
            [self pushViewController:country
                            animated:YES];
            
            [self.navigationBarView changeNavigationBarTitle:title];
            [self.navigationBarView changeToChooseCountry];
            
            [self.navigationBarView.applyButton addTarget:self
                                                   action:@selector(sendNotificationToChooseCountry)
                                         forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else if ([newScreenName isEqualToString:@"Recent Searches"])
    {
        if (![self.viewControllers.lastObject isKindOfClass:[JARecentSearchesViewController class]])
        {
            JARecentSearchesViewController *searches = [self.storyboard instantiateViewControllerWithIdentifier:@"recentSearchesViewController"];
            searches.delegate = self;
            
            [self pushViewController:searches
                            animated:YES];
            
            [self.navigationBarView changeNavigationBarTitle:title];
        }
    }
    else if ([newScreenName isEqualToString:@"Sign In"])
    {
        if (![self.viewControllers.lastObject isKindOfClass:[JAMyAccountViewController class]])
        {
            JAMyAccountViewController *myAccount = [self.storyboard instantiateViewControllerWithIdentifier:@"myAccountViewController"];
            
            [self pushViewController:myAccount
                            animated:YES];
            
            [self.navigationBarView changeNavigationBarTitle:title];
            
            self.viewControllers = @[myAccount];
        }
    }
    else if ([newScreenName isEqualToString:@"Recently Viewed"])
    {
        if (![self.viewControllers.lastObject isKindOfClass:[JARecentlyViewedViewController class]])
        {
            JARecentlyViewedViewController *recentlyViewed = [self.storyboard instantiateViewControllerWithIdentifier:@"recentlyViewedViewController"];
            
            [self pushViewController:recentlyViewed
                            animated:YES];
            
            [self.navigationBarView changeNavigationBarTitle:title];
            
            self.viewControllers = @[recentlyViewed];
        }
    }
    
    /*
     * READ
     *
     
     if enter in 1 level:
     
     [self.navigationBarView enteredSecondOrThirdLevelWithBackTitle:@"Electronics"];
     
     if enter in 2 or 3 level:
     
     [self.navigationBarView enteredInFirstLevelWithTitle:@"Electronics"
     andProductCount:@"432"];
     
     and add back action
     
     [self.navigationBarView.backButton addTarget:self
     action:@selector(back)
     forControlEvents:UIControlEventTouchUpInside];
     
     
     */
}

- (void)pushCatalogToShowSearchResults:(NSString *)query
{
    JACatalogViewController *catalog = [self.storyboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
    catalog.searchString = query;
    
    [self pushViewController:catalog
                    animated:YES];
    
    [self.navigationBarView changeNavigationBarTitle:query];
    
    self.viewControllers = @[catalog];
}

- (void)changeCenterPanelToCatalogWithCategory:(RICategory*)category
{
    JACatalogViewController *catalog = [self.storyboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
    
    [self pushViewController:catalog
                    animated:YES];
    
    [self.navigationBarView changeNavigationBarTitle:category.name];
    catalog.category = category;
    
    self.viewControllers = @[catalog];
}

- (void)didSelectedItemInMenu:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSDictionary *selectedItem = [notification object];
    
    if ([selectedItem objectForKey:@"index"]) {
        NSNumber *index = [selectedItem objectForKey:@"index"];
        
        if ([index isEqual:@(0)]) {
            [self changeCenterPanel:@"Home"
                     titleForNavBar:nil];
            
        } else {
            if ([index isEqual:@(99)])
            {
                // It's to perform a search
                [self pushCatalogToShowSearchResults:[selectedItem objectForKey:@"text"]];
            }
            else
            {
                [self changeCenterPanel:[selectedItem objectForKey:@"name"]
                         titleForNavBar:[selectedItem objectForKey:@"name"]];
            }
        }
    }
}

- (void)didSelectTeaserWithCatalogUrl:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSString* url = [notification.userInfo objectForKey:@"url"];
    NSString* title = [notification.userInfo objectForKey:@"title"];
    
    if (VALID_NOTEMPTY(url, NSString)) {
        
        JACatalogViewController *catalog = [self.storyboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
        
        catalog.catalogUrl = url;
        
        [self.navigationBarView changeNavigationBarTitle:title];
        [self showBackButton];
        
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
    
    [self showBackButton];
    [self.navigationBarView changeNavigationBarTitle:@"All Categories"];
    self.navigationBarView.backButton.hidden = NO;
    self.navigationBarView.backImageView.hidden = NO;
    self.navigationBarView.titleLabel.hidden = NO;
    
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
        
        [self showBackButton];
        [self.navigationBarView changeNavigationBarTitle:category.name];
        self.navigationBarView.backButton.hidden = NO;
        self.navigationBarView.backImageView.hidden = NO;
        self.navigationBarView.titleLabel.hidden = NO;
        
        [self pushViewController:catalog
                        animated:YES];
    }
}

- (void)didSelectedLeafCategoryInMenu:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSDictionary *selectedItem = [notification object];
    
    RICategory* category = [selectedItem objectForKey:@"category"];
    if (VALID_NOTEMPTY(category, RICategory)) {
        
        [self changeCenterPanelToCatalogWithCategory:category];
    }
}

- (void) showHomeScreen
{
    [self changeCenterPanel:@"Home"
             titleForNavBar:nil];
}

- (void)back
{
    [self popViewControllerAnimated:YES];
#warning is necessary to check whats the rootview controller and change the bar title
    if (1 == self.viewControllers.count) {
        [self.navigationBarView changedToHomeViewController];
        
        [self.navigationBarView.backButton removeTarget:nil
                                                 action:NULL
                                       forControlEvents:UIControlEventAllEvents];
    }
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

- (void)changeBackButtonForTitle:(NSNotification *)notification
{
    NSDictionary* userInfo = notification.userInfo;
    [self.navigationBarView enteredSecondOrThirdLevelWithBackTitle:[userInfo objectForKey:@"name"]];
    
    [self.navigationBarView.backButton addTarget:self
                                          action:@selector(back)
                                forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Selected country delegate and notification

- (void)sendNotificationToChooseCountry
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidPressApplyNotification
                                                        object:nil];
}

- (void)didSelectedCountry:(RICountry *)country
{
    UINavigationController* rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    JASplashViewController *splash = [self.storyboard instantiateViewControllerWithIdentifier:@"splashViewController"];
    splash.selectedCountry = country;
    rootViewController.viewControllers = @[splash];
    
    [[[UIApplication sharedApplication] delegate] window].rootViewController = rootViewController;
}

#pragma mark - Recent Search delegate

- (void)didSelectedRecentSearch:(RISearchSuggestion *)recentSearch
{
    JACatalogViewController *catalog = [self.storyboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
    catalog.searchString = recentSearch.item;
    
    [self pushViewController:catalog
                    animated:YES];
    
    [self.navigationBarView changeNavigationBarTitle:recentSearch.item];
}

#pragma mark - Customize navigation bar

- (void)customizeNavigationBar
{
    [self.navigationItem setHidesBackButton:YES
                                   animated:NO];
    
    self.navigationBarView = [JANavigationBarView getNewNavBarView];
    
    self.navigationBarView.backgroundColor = JANavBarBackgroundGrey;
    
    [self.navigationBar.viewForBaselineLayout addSubview:self.navigationBarView];
    
    [self.navigationBarView.cartButton addTarget:self
                                          action:@selector(openCart)
                                forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationBarView.leftButton addTarget:self
                                          action:@selector(openMenu)
                                forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Show Back

- (void)showBackButton
{
    [self.navigationBarView enteredSecondOrThirdLevelWithBackTitle:@"Back"];
    [self.navigationBarView.backButton addTarget:self
                                          action:@selector(back)
                                forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Filters

- (void)changeEditButtonState:(NSNotification *)notification
{
    NSNumber* state = [notification.userInfo objectForKey:@"enabled"];
    self.navigationBarView.editButton.enabled = [state boolValue];
}

- (void)showMainFiltersNavigation
{
    [self.navigationBarView changeToMainFilters];
    [self.navigationBarView.doneButton addTarget:self
                                          action:@selector(done)
                                forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView.editButton addTarget:self
                                          action:@selector(edit)
                                forControlEvents:UIControlEventTouchUpInside];
}

- (void)showSpecificFilterNavigation:(NSNotification *)notification
{
    NSDictionary* userInfo = notification.userInfo;
    [self.navigationBarView changeToSpecificFilter:[userInfo objectForKey:@"name"]];
    
    [self.navigationBarView.backButton addTarget:self
                                          action:@selector(back)
                                forControlEvents:UIControlEventTouchUpInside];
}


@end
