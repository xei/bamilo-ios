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
#import "RICustomer.h"

@interface JARootViewController ()

@property (assign, nonatomic) NSInteger requestCount;
@property (strong, nonatomic) RICountry *selectedCountry;
@property (strong, nonatomic) UIStoryboard *mainStoryboard;

@end

@implementation JARootViewController

#pragma mark - View lifecycle

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        }
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(ISEMPTY(self.mainStoryboard))
    {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        }
    }
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCountry:)
                                                 name:kUpdateCountryNotification
                                               object:nil];
    
    if(VALID_NOTEMPTY(self.notification, NSDictionary))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification
                                                            object:self.selectedCountry
                                                          userInfo:self.notification];
    }
    else
    {
        if(VALID_NOTEMPTY(self.selectedCountry, RICountry) || [RIApi checkIfHaveCountrySelected])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification
                                                                object:self.selectedCountry];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowChooseCountryScreenNotification
                                                                object:nil];
        }
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
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    
    [self setLeftPanel:[self.mainStoryboard instantiateViewControllerWithIdentifier:@"menuViewController"]];
    [self setCenterPanel:[self.mainStoryboard instantiateViewControllerWithIdentifier:@"rootNavigationController"]];
}

- (void)updateCountry:(NSNotification*)notification
{
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"menuViewController"]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"first_screen"]];

    if(VALID_NOTEMPTY(notification.userInfo, NSDictionary))
    {
        [[RITrackingWrapper sharedInstance] handlePushNotifcation:[notification.userInfo copy]];
    }
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
