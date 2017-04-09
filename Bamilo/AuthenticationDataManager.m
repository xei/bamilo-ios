//
//  AuthenticationDataManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationDataManager.h"

@implementation AuthenticationDataManager

#pragma mark - Overrides
static AuthenticationDataManager *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AuthenticationDataManager new];
    });
    
    return instance;
}

- (void)loginUser:(id<DataServiceProtocol>)target withUsername:(NSString *)username password:(NSString *)password completion:(DataCompletion)completion {
    NSDictionary *params = @{ @"login[email]": username, @"login[password]": password };
    
    [self.requestManager asyncPOST:target path:RI_API_LOGIN_CUSTOMER params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(int response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            [RICustomer parseCustomerWithJson:[data objectForKey:@"customer_entity"] plainPassword:password loginMethod:@"normal"];
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}

- (void)signupUser:(id<DataServiceProtocol>)target withFieldsDictionary:(NSMutableDictionary *)fields completion:(DataCompletion)completion {
    //must be remove from server side!
    fields[@"customer[phone_prefix]"] = @"100";
    [self.requestManager asyncPOST:target path:RI_API_REGISTER_CUSTOMER params:fields type:REQUEST_EXEC_IN_FOREGROUND completion:^(int response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            [RICustomer parseCustomerWithJson:[data objectForKey:@"customer_entity"] plainPassword:fields[@"customer[password]"] loginMethod:@"normal"];
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}

- (void)forgetPassword:(id<DataServiceProtocol>)target withFields:(NSDictionary *)fields completion:(DataCompletion)completion {
    [self.requestManager asyncPOST:target path:RI_API_FORGET_PASS_CUSTOMER params:fields type:REQUEST_EXEC_IN_FOREGROUND completion:^(int response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}

- (void)logoutUser:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [self.requestManager asyncPOST:target path:RI_API_LOGOUT_CUSTOMER params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(int statusCode, id data, NSArray *errorMessages) {
        if(statusCode == RIApiResponseSuccess && data) {
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:statusCode errorMessages:errorMessages]);
        }
        [RICustomer cleanCustomerFromDB];
    }];
}

@end
