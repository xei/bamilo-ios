//
//  JACenterNavigationController.m
//  Jumia
//
//  Created by Miguel Chaves on 31/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACenterNavigationController.h"
#import "JANavigationBarView.h"
#import "RICart.h"
#import "JAHomeViewController.h"
#import "JAMyFavouritesViewController.h"
#import "JAChooseCountryViewController.h"
#import "JARecentSearchesViewController.h"
#import "JACatalogViewController.h"
#import "JAPDVViewController.h"
#import "JAMyAccountViewController.h"
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
    [self.navigationBarView changeNavigationBarTitle:@"Cart"];
    
    if(VALID_NOTEMPTY(self.cart, RICart) && 0 < [self.cart cartCount])
    {
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"cartViewController"]
                        animated:YES];
    }
    else
    {
        [self popToRootViewControllerAnimated:NO];        
        [self pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"emptyCartViewController"]
                        animated:YES];
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
            [self changeCenterPanel:[selectedItem objectForKey:@"name"]
                     titleForNavBar:[selectedItem objectForKey:@"name"]];
        }
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
    [RIApi startApiWithCountry:country
                  successBlock:^(id api) {
                      
                      JAHomeViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
                      
                      [self pushViewController:home
                                      animated:YES];
                      [self.navigationBarView changedToHomeViewController];
                      
                      self.viewControllers = @[home];
                      
                  } andFailureBlock:^(NSArray *errorMessage) {
                      
                      NSLog(@"aqui");
                      
                  }];
}

#pragma mark - Recent Search delegate

- (void)didSelectedRecentSearch:(RIRecentSearch *)recentSearch
{
    JAHomeViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
    
    [self pushViewController:home
                    animated:YES];
    [self.navigationBarView changedToHomeViewController];
    
    self.viewControllers = @[home];
}

#pragma mark - Customize navigation bar

- (void)customizeNavigationBar
{
    [self.navigationItem setHidesBackButton:YES
                                   animated:NO];
    
    self.navigationBarView = [JANavigationBarView getNewNavBarView];
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
