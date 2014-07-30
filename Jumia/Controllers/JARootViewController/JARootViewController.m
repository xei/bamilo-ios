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
#import "RIApi.h"

@interface JARootViewController ()

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
}

#pragma mark - Menu selected item in menu

- (void)didSelectedItemInMenu:(NSNotification *)notification
{
    NSDictionary *selectedItem = [notification object];
    
    JAHomeViewController *homeVc = [((UINavigationController *)self.centerPanel).viewControllers firstObject];
    [homeVc pushViewControllerWithName:@"teste"
                        titleForNavBar:[selectedItem objectForKey:@"name"]];
    
    [self showCenterPanelAnimated:YES];
}

- (void)openMainMenu
{
    [self showLeftPanelAnimated:YES];
}

@end
