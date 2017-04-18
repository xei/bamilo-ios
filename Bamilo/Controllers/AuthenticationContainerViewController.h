//
//  AuthenticationViewController.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationBaseViewController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "AuthenticationDelegate.h"

typedef void(^AuthenticationBlock)(void);

@interface AuthenticationContainerViewController: BaseViewController <AuthenticationDelegate>

@property (nonatomic) BOOL showContinueWithoutLogin;
@property (nonatomic, assign) BOOL fromSideMenu;
@property (nonatomic) NSDictionary *userInfo;

@property (strong, nonatomic) SignInViewController *signInViewController;
@property (strong, nonatomic) SignUpViewController *signUpViewController;
@property (nonatomic) BOOL startWithSignUpViewController;

@end
