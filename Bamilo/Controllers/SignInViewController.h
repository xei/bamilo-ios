//
//  SignInViewController.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationBaseViewController.h"
#import "DataServiceProtocol.h"

@protocol SignInViewControllerDelegate
- (void)wantsToContinueWithoutLogin;
- (void)wantsToShowForgetPassword;
@end

@interface SignInViewController : AuthenticationBaseViewController <DataServiceProtocol, UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) id<SignInViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL fromSideMenu;
@property (nonatomic, strong) void(^nextStepBlock)(void);
@property (nonatomic) Boolean showContinueWithoutLogin;

@end
