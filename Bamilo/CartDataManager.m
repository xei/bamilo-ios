//
//  CartDataManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartDataManager.h"

@implementation CartDataManager

#pragma mark - Overrides
static CartDataManager *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CartDataManager new];
    });
    
    return instance;
}

-(void)addProductToCart:(id<DataServiceProtocol>)target simpleSku:(NSString *)simpleSku completion:(DataCompletion)completion {
    NSDictionary *params = @{ @"quantity": @1, @"sku": simpleSku };
    
    [self.requestManager asyncPOST:target path:RI_API_ADD_ORDER params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(int statusCode, Data *data, NSArray *errorMessages) {
        [self processResponse:statusCode ofClass:[RICart class] forData:data errorMessages:errorMessages completion:completion];
    }];
}

@end
