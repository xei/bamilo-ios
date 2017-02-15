//
//  AuthenticationBaseViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//
#define cEXTRA_ORAGNE_COLOR [UIColor withRGBA:247 green:151 blue:32 alpha:1.0f]

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, AuthenticationStatus) {
    AUTHENTICATION_CANCELLED,
    AUTHENTICATION_FINISHED_WITH_LOGIN,
    AUTHENTICATION_FINISHED_WITH_REGISTER
};

typedef void(^AuthenticationCompletion)(AuthenticationStatus status);

@interface AuthenticationBaseViewController : UIViewController

@property (copy, nonatomic) AuthenticationCompletion completion;

@end
