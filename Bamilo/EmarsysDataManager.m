//
//  EmarsysDataManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysDataManager.h"
#import "EmarsysRequestManager.h"
#import "DeviceManager.h"
#import "AppManager.h"

#define kApplicationId @"application_id"
#define kHardwareId @"hardware_id"
#define kPlatform @"platform"
#define kLanguage @"language"
#define kTimezone @"timezone"
#define kDeviceModel @"device_model"
#define kApplicationVersion @"application_version"
#define kOSVersion @"os_version"
#define kPushToken @"push_token"
#define kContactFieldId @"contact_field_id"
#define kContactFieldValue @"contact_field_value"
#define kSID @"sid"

@implementation EmarsysContactIdentifier

+(instancetype)appId:(NSString *)appId hwid:(NSString *)hwid {
    return [self appId:appId hwid:hwid pushToken:nil];
}

+(instancetype)appId:(NSString *)appId hwid:(NSString *)hwid pushToken:(NSString *)pushToken {
    EmarsysContactIdentifier *emarsysUserIdentifier = [EmarsysContactIdentifier new];
    
    emarsysUserIdentifier.applicationId = appId;
    emarsysUserIdentifier.hardwareId = hwid;
    emarsysUserIdentifier.pushToken = pushToken;
    
    return emarsysUserIdentifier;
}

@end

@implementation EmarsysDataManager

static EmarsysDataManager *instance;

- (instancetype)init {
    if (self = [super init]) {
        self.requestManager = [[EmarsysRequestManager alloc] initWithBaseUrl:@"https://push.eservice.emarsys.net/api/mobileengage/v2/"];
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

#pragma mark - Public Methods
-(void)anonymousLogin:(EmarsysContactIdentifier *)contact completion:(DataCompletion)completion {
    NSMutableDictionary *params = [self commonLoginParams:contact];
    [self executeLogin:params completion:completion];
}

-(void)login:(EmarsysContactIdentifier *)contact contactFieldId:(NSString *)contactFieldId contactFieldValue:(NSString *)contactFieldValue completion:(DataCompletion)completion {
    NSMutableDictionary *params = [self commonLoginParams:contact];
    [params setObject:contactFieldId forKey:kContactFieldId];
    [params setObject:contactFieldValue forKey:kContactFieldValue];
    [self executeLogin:params completion:completion];
}

-(void)openMessage:(EmarsysContactIdentifier *)contact sid:(NSString *)sid completion:(DataCompletion)completion {
    NSMutableDictionary *params = [self commonEventParams:contact];
    [params setObject:sid forKey:kSID];
    [self executeEvent:@"message_open" params:params completion:completion];
}

-(void)event:(EmarsysContactIdentifier *)contact event:(NSString *)event completion:(DataCompletion)completion {
    NSMutableDictionary *params = [self commonEventParams:contact];
    [self executeEvent:event params:params completion:completion];
}

#pragma mark - Private Methods
-(NSMutableDictionary *)commonLoginParams:(EmarsysContactIdentifier *)contact {
    //TEMP: fa - Multi-language app?
    return [NSMutableDictionary
            dictionaryWithObjects:@[ contact.applicationId, contact.hardwareId, @"ios", @"fa",
                                     [DeviceManager getLocalTimeZoneRFC822Formatted],
                                     [DeviceManager getDeviceModel],
                                     [[AppManager sharedInstance] getAppVersionNumber],
                                     [DeviceManager getOSVersionFormatted],
                                     contact.pushToken ?: @"false"]
            forKeys:@[ kApplicationId, kHardwareId, kPlatform, kLanguage, kTimezone, kDeviceModel, kApplicationVersion, kOSVersion, kPushToken]];
}

-(NSMutableDictionary *)commonEventParams:(EmarsysContactIdentifier *)contact {
    return [NSMutableDictionary
            dictionaryWithObjects:@[ contact.applicationId, contact.hardwareId ]
            forKeys:@[ kApplicationId, kHardwareId ]];
}

-(void) executeLogin:(NSDictionary *)params completion:(DataCompletion)completion {
    [self.requestManager asyncPOST:nil path:@"users/login" params:params type:REQUEST_EXEC_IN_BACKGROUND completion:^(int statusCode, id data, NSArray *errorMessages) {
        if(statusCode == SUCCESSFUL) {
            completion(data, nil);
        } else {
            completion(nil, [NSError errorWithDomain:@"com.bamilo.ios" code:statusCode userInfo:@{ NSUnderlyingErrorKey: errorMessages[0] }]);
        }
    }];
}

-(void) executeEvent:(NSString *)event params:(NSDictionary *)params completion:(DataCompletion)completion {
    
}

@end
