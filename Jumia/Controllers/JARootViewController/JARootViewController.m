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
#import "RIApi.h"

@interface JARootViewController ()
<
    JANavigationBarDelegate
>

@property (strong, nonatomic) JANavigationBar *navBar;

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

#pragma mark - Custom navigation bar delegates

- (void)customNavigationBarOpenMenu
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenMenuNotification
                                                        object:nil];
}

#pragma mark - Public methods

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
