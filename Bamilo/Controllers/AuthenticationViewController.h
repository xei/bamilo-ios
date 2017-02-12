//
//  AuthenticationViewController.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AuthenticationViewController: JABaseViewController
@property (nonatomic) BOOL checkout;
@property (nonatomic, assign) BOOL fromSideMenu;
@property (nonatomic, strong) void(^nextStepBlock)(void);
@property (nonatomic) NSDictionary *userInfo;

+ (void)goToCheckoutWithBlock:(void (^)(void))authenticatedBlock;
+ (void)authenticateAndExecuteBlock:(void (^)(void))authenticatedBlock showBackButtonForAuthentication:(BOOL)backButton;
@end
