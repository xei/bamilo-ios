//
//  AuthenticationViewController.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationBaseViewController.h"

typedef void(^AuthenticationBlock)(void);

@interface AuthenticationViewController: AuthenticationBaseViewController
@property (nonatomic) BOOL checkout;
@property (nonatomic, assign) BOOL fromSideMenu;
@property (nonatomic, strong) void(^nextStepBlock)(void);
@property (nonatomic) NSDictionary *userInfo;

+ (void)goToCheckoutWithBlock:(AuthenticationBlock)authenticatedBlock;
+ (void)authenticateAndExecuteBlock:(AuthenticationBlock)authenticatedBlock showBackButtonForAuthentication:(BOOL)backButton;

@end
