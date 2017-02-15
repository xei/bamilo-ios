//
//  AuthenticationViewController.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationBaseViewController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"

typedef void(^AuthenticationBlock)(void);

@interface AuthenticationContainerViewController: BaseViewController

@property (nonatomic) BOOL showContinueWithoutLogin;
@property (nonatomic, assign) BOOL fromSideMenu;
//@property (nonatomic, strong) void(^nextStepBlock)(void);
@property (nonatomic) NSDictionary *userInfo;

@property (strong, nonatomic) SignInViewController *signInViewController;
@property (strong, nonatomic) SignUpViewController *signUpViewController;

+ (void)goToCheckoutWithBlock:(AuthenticationBlock)authenticatedBlock;
+ (void)authenticateAndExecuteBlock:(AuthenticationBlock)authenticatedBlock showBackButtonForAuthentication:(BOOL)backButton;

@end
