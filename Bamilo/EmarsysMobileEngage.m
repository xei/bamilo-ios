//
//  EmarsysMobileEngage.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysMobileEngage.h"
#import "EmarsysDataManager.h"
#import "RICustomer.h"

@implementation EmarsysMobileEngage

static EmarsysMobileEngage *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EmarsysMobileEngage alloc] init];
    });
    
    return instance;
}

#pragma mark - Public Methods
-(void)sendUpdate:(NSString *)applicationId hardwareId:(NSString *)hardwareId pushToken:(NSString *)pushToken completion:(EmarsysMobileEngageResponse)completion {
    if([RICustomer checkIfUserIsLogged]) {
        
    } else {
        [[EmarsysDataManager sharedInstance] doAnonymousLogin:nil applicationId:applicationId hardwareId:hardwareId pushToken:pushToken completion:^(id data, NSError *error) {
            completion(error == nil);
        }];
    }
}

@end
