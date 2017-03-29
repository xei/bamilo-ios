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
-(void)sendLogin:(NSString *)applicationId hardwareId:(NSString *)hardwareId pushToken:(NSString *)pushToken completion:(EmarsysMobileEngageResponse)completion {
    
    EmarsysContactIdentifier *contact = [EmarsysContactIdentifier appId:applicationId hwid:hardwareId pushToken:pushToken];
    
    if([RICustomer checkIfUserIsLogged]) {
        /*[[EmarsysDataManager sharedInstance] doLogin:applicationId hardwareId:hardwareId pushToken:pushToken contactFieldId:@"Email" contactFieldValue:[RICustomer getCurrentCustomer].email completion:^(id data, NSError *error) {
            completion(error == nil);
        }];*/
    } else {
        [[EmarsysDataManager sharedInstance] anonymousLogin:contact completion:^(id data, NSError *error) {
            completion(error == nil);
        }];
    }
}

-(void)sendOpen:(NSString *)applicationId hardwareId:(NSString *)hardwareId sid:(NSString *)sid completion:(EmarsysMobileEngageResponse)completion {
    
}

@end
