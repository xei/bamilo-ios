//
//  JARootViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARootViewController.h"
#import "JACenterNavigationController.h"
#import "JAMenuViewController.h"

@interface JARootViewController ()

@end

@implementation JARootViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldResizeLeftPanel = YES;

    //we need to allow panning for all view controllers
    //(we will de-activate it in each JABaseViewController
    self.panningLimitedToTopViewController = NO;
    
    //notifications to turn swipe on and off
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(turnOffLeftSwipe)
                                                 name:kTurnOffLeftSwipePanelNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(turnOnLeftSwipe)
                                                 name:kTurnOnLeftSwipePanelNotification
                                               object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openMainMenu:)
                                                 name:kOpenMenuNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCenterViewController)
                                                 name:kOpenCenterPanelNotification
                                               object:nil];
    
    if(VALID_NOTEMPTY(self.notification, NSDictionary))
    {
        [[RITrackingWrapper sharedInstance] applicationDidReceiveRemoteNotification:self.notification];
    }
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
    
    [(JACenterNavigationController *)self.centerPanel pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"] animated:YES];
}

- (void)turnOffLeftSwipe
{
    self.allowLeftSwipe = NO;
}

- (void)turnOnLeftSwipe
{
    self.allowLeftSwipe = YES;
}

- (void)openMainMenu:(NSNotification *)notification
{
    UIViewController *topViewController = [(JACenterNavigationController *)self.centerPanel topViewController];
    if(VALID_NOTEMPTY(topViewController, UIViewController))
    {
        if([topViewController respondsToSelector:@selector(removeMessageView)])
        {
            [topViewController performSelector:@selector(removeMessageView)];
        }
    }
    
    [self showLeftPanelAnimated:YES userInfo:notification.userInfo];
}

- (void)showCenterViewController
{
    [self showCenterPanelAnimated:YES];
}

@end
