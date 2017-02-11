//
//  DataManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"
#import "Models.pch"

@implementation DataManager {
@private
    RequestCompletion responseProcessor;
}

static DataManager *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        responseProcessor = ^(RIApiResponse response, id data, NSArray* errorMessages) {
            
        };
    }
    return self;
}

- (void)getUserAddressList:(DataCompletion)completion {
    [RequestManager asyncPOST:RI_API_GET_CUSTOMER_ADDRESS_LIST params:nil completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[AddressList class] response:response errorMessages:errorMessages completion:completion];
    }];
}

#pragma mark - Private Methods
- (void)serialize:(id)data into:(Class)aClass response:(RIApiResponse)response errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion {
    if(response == RIApiResponseSuccess && data) {
        NSError *error;
        id dataModel = [MTLJSONAdapter modelOfClass:[aClass class] fromJSONDictionary:data error:&error];
        
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
