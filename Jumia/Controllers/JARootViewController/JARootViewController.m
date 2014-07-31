//
//  JARootViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARootViewController.h"
#import "JAMenuViewController.h"
#import "JAHomeViewController.h"
#import "JANavigationBar.h"
#import "RICart.h"

@interface JARootViewController ()
<
JANavigationBarDelegate
>

@property (strong, nonatomic) JANavigationBar *navBar;
@property (strong, nonatomic) RICart *cart;

@end

@implementation JARootViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldResizeLeftPanel = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectedItemInMenu:)
                                                 name:kMenuDidSelectOptionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openMainMenu)
                                                 name:kOpenMenuNotification
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

-(void)awakeFromNib
{
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"menuViewController"]];
    [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"]];
    
    self.navBar = [[JANavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.navBar.customDelegate = self;
    [(JAHomeViewController *)(((UINavigationController *)self.centerPanel).viewControllers[0]) setNavigationBar:self.navBar];
    
    [self.navBar.navigationBarView.cartButton addTarget:self
                                                 action:@selector(openCart)
                                       forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Menu selected item in menu

- (void)didSelectedItemInMenu:(NSNotification *)notification
{
    [self showCenterPanelAnimated:YES];
    
    NSDictionary *selectedItem = [notification object];
    
    if ([selectedItem objectForKey:@"index"]) {
        NSNumber *index = [selectedItem objectForKey:@"index"];
        
        if ([index isEqual:@(0)]) {
            [self popToHomeViewController];
            
        } else {
            [self pushViewControllerWithName:@"teste"
                              titleForNavBar:[selectedItem objectForKey:@"name"]];
        }
    }
}

- (void)openMainMenu
{
    [self showLeftPanelAnimated:YES];
}

- (void)openCart
{
    [self pushViewControllerWithName:@"teste"
                      titleForNavBar:@"Cart"];

    if(VALID_NOTEMPTY(self.cart, RICart) && 0 < [self.cart cartCount])
    {
        [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"cartViewController"]];
        [self showCenterPanelAnimated:YES];
    }
    else
    {
        [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"emptyCartViewController"]];
        [self showCenterPanelAnimated:YES];        
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

#pragma mark - Custom navigation bar delegates

- (void)customNavigationBarOpenMenu
{
    [self openMainMenu];
}

- (void)customNavigationBarOpenCart
{
    [self openCart];
}

#pragma mark - Push and pop methods

- (void)pushViewControllerWithName:(NSString *)name
                    titleForNavBar:(NSString *)title
{
    [self.navBar changeNavigationBarTitle:title];
}

- (void)popToHomeViewController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.navBar changedToHomeViewController];
}

@end
