//
//  ProductDataManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ProductDataManager.h"

@implementation ProductDataManager

#pragma mark - Overrides
static ProductDataManager *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ProductDataManager new];
    });
    
    return instance;
}

-(void)addToFavorites:(id<DataServiceProtocol>)target sku:(NSString *)sku completion:(DataCompletion)completion {
    NSDictionary *params = @{ @"sku": sku };
    
    [self.requestManager asyncPOST:target path:RI_API_ADD_TO_WISHLIST params:params type:RequestExecutionTypeForeground completion:^(NSInteger statusCode, ResponseData *data, NSArray *errorMessages) {
        [self processResponse:statusCode ofClass:nil forData:data errorMessages:errorMessages completion:completion];
    }];
}

-(void)removeFromFavorites:(id<DataServiceProtocol>)target sku:(NSString *)sku completion:(DataCompletion)completion {
    NSDictionary *params = @{ @"sku": sku };
    
    [self.requestManager asyncDELETE:target path:RI_API_REMOVE_FOM_WISHLIST params:params type:RequestExecutionTypeForeground completion:^(NSInteger statusCode, ResponseData *data, NSArray *errorMessages) {
        [self processResponse:statusCode ofClass:nil forData:data errorMessages:errorMessages completion:completion];
    }];
}

@end
