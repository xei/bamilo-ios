//
//  RILogin.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RILogin.h"
#import "RICustomer.h"

@interface RILogin ()

@end

@implementation RILogin

static dispatch_once_t pred = 0;
static RILogin *instance = nil;

+ (RILogin *)sharedInstance;
{
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (BOOL)checkIfUserIsLogged
{
    if (self.customer) {
        return YES;
    } else {
        return NO;
    }
}

- (void)autoLoginWithSucess:(void(^)(BOOL success))returnBlock
{
    [RICustomer getCustomerWithSuccessBlock:^(id customer) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                            object:nil];
        
        self.customer = customer;
        
        returnBlock(YES);
        
    } andFailureBlock:^(NSArray *errorMessages) {
        
        returnBlock(NO);
        
    }];
}

- (void)logoutUser:(void(^)(BOOL success))returnBlock
{
    [RICustomer logoutCustomerWithSuccessBlock:^{
        self.customer = nil;
        returnBlock(YES);
    } andFailureBlock:^(NSArray *errorObject) {
        returnBlock(NO);
    }];
}

@end
