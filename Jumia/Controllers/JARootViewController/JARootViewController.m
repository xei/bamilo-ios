//
//  JARootViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARootViewController.h"
#import "JACenterNavigationController.h"

@interface JARootViewController ()

@end

@implementation JARootViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldResizeLeftPanel = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openMainMenu)
                                                 name:kOpenMenuNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCenterViewController)
                                                 name:kOpenCenterPanelNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(turnOffLeftSwipe)
                                                 name:kTurnOffLeftSwipePanelNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(turnOnLeftSwipe)
                                                 name:kTurnOnLeftSwipePanelNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)awakeFromNib
{
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"menuViewController"]];
    [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"rootNavigationController"]];
    
    [(JACenterNavigationController *)self.centerPanel showViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"]
                                                                  sender:nil];
}

- (void)turnOffLeftSwipe
{
    self.allowLeftSwipe = NO;
}

- (void)turnOnLeftSwipe
{
    self.allowLeftSwipe = YES;
}

- (void)openMainMenu
{
    [self showLeftPanelAnimated:YES];
}

- (void)showCenterViewController
{
    [self showCenterPanelAnimated:YES];
}

@end
