//
//  AuthenticationBaseViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, AuthenticationStatus) {
    AuthenticationStatusCanceled,
    AuthenticationStatusSigninFinished,
    AuthenticationStatusSignupFinished
};

typedef void(^AuthenticationCompletion)(AuthenticationStatus status);

@interface AuthenticationBaseViewController : BaseViewController

@property (copy, nonatomic) AuthenticationCompletion completion;

@end
