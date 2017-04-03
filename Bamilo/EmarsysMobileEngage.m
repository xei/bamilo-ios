//
//  EmarsysMobileEngage.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysMobileEngage.h"
#import "EmarsysDataManager.h"
#import <Pushwoosh/PushNotificationManager.h>
#import "RICustomer.h"
#import "SearchEvent.h"

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
-(void)sendLogin:(NSString *)pushToken completion:(EmarsysMobileEngageResponse)completion {
    if([RICustomer checkIfUserIsLogged]) {
        /*[[EmarsysDataManager sharedInstance] doLogin:applicationId hardwareId:hardwareId pushToken:pushToken contactFieldId:@"Email" contactFieldValue:[RICustomer getCurrentCustomer].email completion:^(id data, NSError *error) {
            completion(error == nil);
        }];*/
    } else {
        [[EmarsysDataManager sharedInstance] anonymousLogin:[self getIdentifier:pushToken] completion:^(id data, NSError *error) {
            [self handleEmarsysMobileEngageResponse:data error:error completion:completion];
        }];
    }
}

-(void)sendOpen:(NSString *)sid completion:(EmarsysMobileEngageResponse)completion {
    [[EmarsysDataManager sharedInstance] openMessageEvent:[self getIdentifier:nil] sid:sid completion:^(id data, NSError *error) {
        [self handleEmarsysMobileEngageResponse:data error:error completion:completion];
    }];
}

7    [[EmarsysDataManager sharedInstance] customEvent:[self getIdentifier:nil] event:event attributes:attributes completion:^(id data, NSError *error) {
        [self handleEmarsysMobileEngageResponse:data error:error completion:completion];
    }];
}

#pragma mark - Private Methods
-(id) getIdentifier:(NSString *)pushToken {
    PushNotificationManager *pushManager = [PushNotificationManager pushManager];
    if(pushToken) {
        return [EmarsysPushIdentifier appId:[pushManager appCode] hwid:[pushManager getHWID] pushToken:pushToken];
    } else {
        return [EmarsysContactIdentifier appId:[pushManager appCode] hwid:[pushManager getHWID]];
    }
}

-(void) handleEmarsysMobileEngageResponse:(id)data error:(NSError *)error completion:(EmarsysMobileEngageResponse)completion {
    if(completion) {
        if(error == nil) {
            completion(YES);
        } else {
            completion(NO);
        }
    }
}

@end
