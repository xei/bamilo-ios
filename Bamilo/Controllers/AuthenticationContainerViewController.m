//
//  AuthenticationViewController.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationContainerViewController.h"
#import "CAPSPageMenu.h"
#import "RICustomer.h"
#import "ViewControllerManager.h"

@interface AuthenticationContainerViewController() <CAPSPageMenuDelegate>
@property (nonatomic) CAPSPageMenu *pagemenu;
@end

@implementation AuthenticationContainerViewController

-(void)awakeFromNib {
    [super awakeFromNib];
    
    //Sign In View Controller
    self.signInViewController = (SignInViewController *)[[ViewControllerManager sharedInstance] loadNib:@"SignInViewController" resetCache:YES];
    self.signInViewController.title = STRING_LOGIN;
    self.signInViewController.fromSideMenu = self.fromSideMenu;
    self.signInViewController.showContinueWithoutLogin = self.showContinueWithoutLogin;
    self.signInViewController.delegate = self;
    
    //Sign Up View Controller
    self.signUpViewController = (SignUpViewController *)[[ViewControllerManager sharedInstance] loadNib:@"SignUpViewController" resetCache:YES];
    self.signUpViewController.title = STRING_SIGNUP;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *parameters = @{CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionSelectionIndicatorHeight: @2,
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:kFontRegularName size: 14],
                                 CAPSPageMenuOptionSelectionIndicatorColor: cORAGNE_COLOR,
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionMenuHeight: @40,
                                 CAPSPageMenuOptionBottomMenuHairlineColor:cLIGHT_GRAY_COLOR,
                                 CAPSPageMenuOptionAddBottomMenuHairline: @(YES),
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: cDARK_GRAY_COLOR,
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: cEXTRA_DARK_GRAY_COLOR,
                                 CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap: @(150)
                                 };
    
    self.pagemenu = [[CAPSPageMenu alloc] initWithViewControllers:@[ self.signUpViewController, self.signInViewController ] frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    self.pagemenu.delegate = self;
    [self.pagemenu moveToPage:1];
    [self.view addSubview:_pagemenu.view];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self publishScreenLoadTime];
}

#pragma mark - Overrides
- (void)updateNavBar {
    [super updateNavBar];

    self.navBarLayout.title = STRING_LOGIN_OR_SIGNUP;
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
}

#pragma mark - Legacy codes
/*
+ (void)goToCheckoutWithBlock:(AuthenticationBlock)authenticatedBlock {
    [self authenticateAndExecuteBlock:authenticatedBlock showBackButtonForAuthentication:YES showContinueWithoutLogin:YES];
}

+ (void)authenticateAndExecuteBlock:(AuthenticationBlock)authenticatedBlock showBackButtonForAuthentication:(BOOL)backButton {
    [self authenticateAndExecuteBlock:authenticatedBlock showBackButtonForAuthentication:backButton showContinueWithoutLogin:NO];
}

+ (void)authenticateAndExecuteBlock:(AuthenticationBlock)authenticatedBlock showBackButtonForAuthentication:(BOOL)backButton showContinueWithoutLogin:(BOOL)continueButton {
    if([RICustomer checkIfUserIsLogged]) {
        authenticatedBlock();
    } else {
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:[NSNumber numberWithBool:continueButton] forKey:@"continue_button"];
        [userInfo setObject:[NSNumber numberWithBool:backButton] forKey:@"shows_back_button"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification object:authenticatedBlock userInfo:userInfo];
    }
}*/

#pragma mark - AuthenticationDelegate
- (void)wantsToContinueWithoutLogin {
    [self performSegueWithIdentifier:@"showContinueWithoutLoginViewCtrl" sender:nil];
}

- (void)wantsToShowForgetPassword {
    [self performSegueWithIdentifier:@"showForgetPasswordViewCtrl" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"showContinueWithoutLoginViewCtrl"]) {
    }
}

#pragma mark - CAPSPageMenuDelegate
- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index {
    [self publishScreenLoadTime];
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    if(self.pagemenu.currentPageIndex == 0) {
        return @"SignUp";
    } else {
        return @"SignIn";
    }
}

-(BOOL)forcePublishScreenLoadTime {
    return YES;
}

@end
