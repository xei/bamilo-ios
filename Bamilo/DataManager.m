//
//  DataManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"
#import "Models.pch"
#import "RICart.h"
#import "RIForm.h"
#import "RICustomer.h"

@implementation DataManager

static DataManager *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
    });
    
    return instance;
}

//### LOGIN ###
- (void)loginUser:(id<DataServiceProtocol>)target withUsername:(NSString *)username password:(NSString *)password completion:(DataCompletion)completion {
    NSDictionary *params = @{
         @"login[email]": username,
         @"login[password]": password
    };
    [RequestManager asyncPOST:target path:RI_API_LOGIN_CUSTOMER params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            [RICustomer parseCustomerWithJson:[data objectForKey:@"customer_entity"] plainPassword:password loginMethod:@"normal"];
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}

//### FORGET PASSWORD ###
- (void)forgetPassword:(id<DataServiceProtocol>)target withFields:(NSDictionary<NSString *,FormItemModel *> *)fields completion:(DataCompletion)completion {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [fields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, FormItemModel * _Nonnull obj, BOOL * _Nonnull stop) {
        params[key] = obj.titleString;
    }];
    [RequestManager asyncPOST:target path:RI_API_FORGET_PASS_CUSTOMER params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}


//### SIGNUP ###
- (void)signupUser:(id<DataServiceProtocol>)target withFieldsDictionary:(NSDictionary<NSString *,FormItemModel *> *)newUserDictionary completion:(DataCompletion)completion {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [newUserDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, FormItemModel * _Nonnull obj, BOOL * _Nonnull stop) {
        params[key] = obj.titleString;
    }];
    //must be remove from server side!
    params[@"customer[phone_prefix]"] = @"100";
    
    [RequestManager asyncPOST:target path:RI_API_REGISTER_CUSTOMER params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            [RICustomer parseCustomerWithJson:[data objectForKey:@"customer_entity"] plainPassword:newUserDictionary[@"customer[password]"].titleString loginMethod:@"normal"];
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}

//### ADDRESS ###
- (void)getUserAddressList:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [RequestManager asyncPOST:target path:RI_API_GET_CUSTOMER_ADDRESS_LIST params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[AddressList class] response:response errorMessages:errorMessages completion:completion];
    }];
}

- (void)setDefaultAddress:(id<DataServiceProtocol>)target address:(Address *)address isBilling:(BOOL)isBilling completion:(DataCompletion)completion {
    NSDictionary *params = @{
         @"id": address.uid,
         @"type": isBilling ? @"billing" : @"shipping"
    };
    
    [RequestManager asyncPUT:target path:RI_API_GET_CUSTOMER_SELECT_DEFAULT params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[AddressList class] response:response errorMessages:errorMessages completion:completion];
    }];
}

//### CART ###
- (void)getUserCart:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [RequestManager asyncPOST:target path:RI_API_GET_CART_DATA params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[RICart class] response:response errorMessages:errorMessages completion:completion];
    }];
}

//### PAYMENT ###
- (void) getMultistepPayment:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [RequestManager asyncGET:target path:RI_API_MULTISTEP_GET_PAYMENT params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[CartForm class] response:response errorMessages:errorMessages completion:completion];
    }];
}

#pragma mark - Private Methods
- (void)serialize:(id)data into:(Class)aClass response:(RIApiResponse)response errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion {
    if(response == RIApiResponseSuccess && data) {
        id dataModel;
        
        if([aClass conformsToProtocol:@protocol(JSONVerboseModel)]) {
            [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                completion([aClass parseToDataModelWithObjects:@[ data, configuration ]], nil);
            } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                completion(nil, [self getErrorFrom:apiResponse errorMessages:errorMessages]);
            }];
        } else {
            NSError *error;
            dataModel = [[aClass alloc] init];
            [dataModel mergeFromDictionary:data useKeyMapping:YES error:&error];
            
            if(error == nil) {
                completion(dataModel, nil);
            } else {
                completion(nil, error);
            }
        }
        
    } else {
        completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
    }
}

#pragma mark - Helpers
- (NSError *)getErrorFrom:(RIApiResponse)response errorMessages:(NSArray *)errorMessages {
    return [NSError errorWithDomain:@"com.bamilo.ios" code:response userInfo:(errorMessages ? @{ @"errorMessages" : errorMessages } : nil)];
}

@end
