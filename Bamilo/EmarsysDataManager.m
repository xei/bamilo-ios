//
//  EmarsysDataManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysDataManager.h"

@implementation EmarsysDataManager

static EmarsysDataManager *instance;

- (instancetype)init {
    if (self = [super init]) {
        self.requestManager = [[RequestManager alloc] initWithBaseUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/"];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EmarsysDataManager alloc] init];
    });
    
    return instance;
}

@end
