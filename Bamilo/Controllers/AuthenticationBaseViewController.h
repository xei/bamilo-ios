//
//  AuthenticationBaseViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseViewController.h"
#import "PerformanceTrackerProtocol.h"

typedef NS_ENUM(NSUInteger, AuthenticationStatus) {
    AUTHENTICATION_CANCELLED,
    AUTHENTICATION_FINISHED_WITH_LOGIN,
    AUTHENTICATION_FINISHED_WITH_REGISTER
};

typedef void(^AuthenticationCompletion)(AuthenticationStatus status);

@interface AuthenticationBaseViewController : BaseViewController

@property (copy, nonatomic) AuthenticationCompletion completion;

@end
