//
//  DataManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"
#import "Models.pch"
#import "RIForm.h"

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
-(void)loginUser:(id<DataServiceProtocol>)target withUsername:(NSString *)username password:(NSString *)password completion:(DataCompletion)completion {
    NSDictionary *params = @{
         @"login[email]": username,
         @"login[password]": password
    };

    [RequestManager asyncPOST:target path:RI_API_LOGIN_CUSTOMER params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
        [RIForm parseEntities:data plainPassword:password loginMethod:@"normal"];
            completion(data, nil);
        } else {
            completion(nil, [NSError errorWithDomain:@"com.bamilo.ios" code:response userInfo:(errorMessages ? @{ @"errorMessages" : errorMessages } : nil)]);
        }
    }];
}

//### ADDRESS ###
-(void) getUserAddressList:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [RequestManager asyncPOST:target path:RI_API_GET_CUSTOMER_ADDRESS_LIST params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[AddressList class] response:response errorMessages:errorMessages completion:completion];
    }];
}

-(void) setDefaultAddress:(id<DataServiceProtocol>)target address:(Address *)address isBilling:(BOOL)isBilling completion:(DataCompletion)completion {
    NSDictionary *params = @{
                             @"id": address.uid,
                             @"type": isBilling ? @"billing" : @"shipping"
                             };
    
    [RequestManager asyncPUT:target path:RI_API_GET_CUSTOMER_SELECT_DEFAULT params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[AddressList class] response:response errorMessages:errorMessages completion:completion];
    }];
}

#pragma mark - Private Methods
- (void)serialize:(id)data into:(Class)aClass response:(RIApiResponse)response errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion {
    if(response == RIApiResponseSuccess && data) {
        NSError *error;
        
        id dataModel = [[aClass alloc] init];
        
        [dataModel mergeFromDictionary:data useKeyMapping:YES error:&error];

        if(error == nil) {
            completion(dataModel, nil);
        } else {
            completion(nil, error);
        }
    } else {
        completion(nil, [NSError errorWithDomain:@"com.bamilo.ios" code:response userInfo:(errorMessages ? @{ @"errorMessages" : errorMessages } : nil)]);
    }
}

@end
