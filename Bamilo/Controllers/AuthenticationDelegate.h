//
//  AuthenticationDelegate.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/19/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AuthenticationDelegate <NSObject>

@optional
- (void)wantsToContinueWithoutLogin;
- (void)wantsToShowForgetPassword;

@end
