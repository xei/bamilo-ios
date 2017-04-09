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

@end
