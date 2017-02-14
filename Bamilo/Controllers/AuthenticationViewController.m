//
//  AuthenticationViewController.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "CAPSPageMenu.h"
#import "RICustomer.h"

#define cEXTRA_DARK_GRAY_COLOR [UIColor withRGBA:80 green:80 blue:80 alpha:1.0f]
#define cDARK_GRAY_COLOR [UIColor withRGBA:115 green:115 blue:115 alpha:1.0f]
#define cLIGHT_GRAY_COLOR [UIColor withRGBA:146 green:146 blue:146 alpha:1.0f]
#define cEXTRA_ORAGNE_COLOR [UIColor withRGBA:247 green:151 blue:32 alpha:1.0f]

@interface AuthenticationViewController() <SignInViewControllerDelegate>
@property (nonatomic) CAPSPageMenu *pagemenu;
@end

@implementation AuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.screenName = @"Authentication";
    self.navBarLayout.title = STRING_LOGIN_OR_SIGNUP;
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showBackButton = YES;
    
    //Page Menu Regsiteration
    NSMutableArray *controllerArray = [NSMutableArray array];
    SignInViewController *signInCtrl = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
    signInCtrl.title = STRING_LOGIN;
    signInCtrl.nextStepBlock = self.nextStepBlock;
    signInCtrl.fromSideMenu = self.fromSideMenu;
    signInCtrl.delegate = self;
    signInCtrl.showContinueWithoutLogin = self.showContinueWithoutLogin;
    [controllerArray addObject:signInCtrl];
    
    
    
    SignUpViewController *signUpCtrl =   [[SignUpViewController alloc] initWithNibName: @"SignUpViewController" bundle: nil];
    signUpCtrl.title = STRING_SIGNUP;
    [controllerArray addObject:signUpCtrl];
    
    NSDictionary *parameters = @{CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:kFontRegularName size: 14],
                                 CAPSPageMenuOptionSelectionIndicatorColor: cEXTRA_ORAGNE_COLOR,
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionMenuHeight: @40,
                                 CAPSPageMenuOptionBottomMenuHairlineColor:cLIGHT_GRAY_COLOR,
                                 CAPSPageMenuOptionAddBottomMenuHairline: @(YES),
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: cDARK_GRAY_COLOR,
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: cEXTRA_DARK_GRAY_COLOR,
                                 CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap: @(150)
                                 };
    
    self.pagemenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    [self.view addSubview:_pagemenu.view];
}

#pragma mark - Legacy codes
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
}


#pragma mark - SignInViewControllerDelegate
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

@end
