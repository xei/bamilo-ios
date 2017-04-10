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
    
    [self.requestManager asyncPOST:target path:RI_API_ADD_TO_WISHLIST params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(int statusCode, Data *data, NSArray *errorMessages) {
        [self processResponse:statusCode class:nil forData:data errorMessages:errorMessages completion:completion];
    }];
}

@end
