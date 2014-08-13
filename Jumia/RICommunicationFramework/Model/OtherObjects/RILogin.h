//
//  RILogin.h
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RICustomer.h"

@interface RILogin : NSObject

@property (strong, nonatomic) RICustomer *customer;

+ (RILogin *)sharedInstance;

- (BOOL)checkIfUserIsLogged;

- (void)autoLoginWithSucess:(void(^)(BOOL success))returnBlock;

- (void)logoutUser:(void(^)(BOOL success))returnBlock;

@end
