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

#define cContactFieldId @"4819" //Field Editor (found in 'Admin') - Emarsys Dashboard

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
        [[EmarsysDataManager sharedInstance] login:[self getPushIdentifier:pushToken] contactFieldId:cContactFieldId contactFieldValue:[RICustomer getCustomerId] completion:^(id data, NSError *error) {
            completion(error == nil);
        }];
    } else {
        [[EmarsysDataManager sharedInstance] anonymousLogin:[self getPushIdentifier:pushToken] completion:^(id data, NSError *error) {
            [self handleEmarsysMobileEngageResponse:data error:error completion:completion];
        }];
    }
}

-(void)sendOpen:(NSString *)sid completion:(EmarsysMobileEngageResponse)completion {
    [[EmarsysDataManager sharedInstance] openMessageEvent:[self getContactIdentifier] sid:sid completion:^(id data, NSError *error) {
        [self handleEmarsysMobileEngageResponse:data error:error completion:completion];
    }];
}

-(void)sendCustomEvent:(NSString *)event attributes:(NSDictionary *)attributes completion:(EmarsysMobileEngageResponse)completion {
    [[EmarsysDataManager sharedInstance] customEvent:[self getContactIdentifier] event:event attributes:attributes completion:^(id data, NSError *error) {
        [self handleEmarsysMobileEngageResponse:data error:error completion:completion];
    }];
}

-(void)sendLogout:(EmarsysMobileEngageResponse)completion {
    [[EmarsysDataManager sharedInstance] logout:[self getContactIdentifier] completion:^(id data, NSError *error) {
        [self handleEmarsysMobileEngageResponse:data error:error completion:completion];
    }];
}

#pragma mark - Private Methods
-(id) getContactIdentifier {
    PushNotificationManager *pushManager = [PushNotificationManager pushManager];
    return [EmarsysContactIdentifier appId:[pushManager appCode] hwid:[pushManager getHWID]];
}

-(id) getPushIdentifier:(NSString *)pushToken {
    PushNotificationManager *pushManager = [PushNotificationManager pushManager];
    return [EmarsysPushIdentifier appId:[pushManager appCode] hwid:[pushManager getHWID] pushToken:pushToken];
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
