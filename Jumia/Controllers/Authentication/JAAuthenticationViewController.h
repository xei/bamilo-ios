//
//  JAAuthenticationViewController.h
//  Jumia
//
//  Created by Jose Mota on 26/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAAuthenticationViewController : JABaseViewController

@property (nonatomic) BOOL checkout;
@property (nonatomic, assign) BOOL fromSideMenu;
@property (nonatomic, strong) void(^nextStepBlock)(void);
@property (nonatomic) NSDictionary *userInfo;

+ (void)goToCheckoutWithBlock:(void (^)(void))authenticatedBlock;
+ (void)authenticateAndExecuteBlock:(void (^)(void))authenticatedBlock showBackButtonForAuthentication:(BOOL)backButton;

@end
