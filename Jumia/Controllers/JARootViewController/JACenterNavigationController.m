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
                                             selector:@selector(didSelectedItemInMenu:)
                                                 name:kMenuDidSelectOptionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openCart)
                                                 name:kOpenCartNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCart:)
                                                 name:kUpdateCartNotification
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
        [self pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"cartViewController"]
                        animated:YES];
    }
    else
    {
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
    }
}

- (void)changeCenterPanel:(NSString *)newScreenName
           titleForNavBar:(NSString *)title
{
    if ([newScreenName isEqualToString:@"Home"])
    {
        JAHomeViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
        
        [self pushViewController:home
                        animated:YES];
        [self.navigationBarView changedToHomeViewController];
        
        self.viewControllers = @[home];
    }
    else if ([newScreenName isEqualToString:@"My Favourites"])
    {
        JAMyFavouritesViewController *favourites = [self.storyboard instantiateViewControllerWithIdentifier:@"myFavouritesViewController"];
        
        [self pushViewController:favourites
                        animated:YES];
        
        [self.navigationBarView changeNavigationBarTitle:title];
        
        self.viewControllers = @[favourites];
    }
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

@end
