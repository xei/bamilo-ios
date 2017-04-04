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

//### EmarsysContactIdentifier
@implementation EmarsysContactIdentifier

+(instancetype)appId:(NSString *)appId hwid:(NSString *)hwid {
    EmarsysContactIdentifier *emarsysUserIdentifier = [EmarsysContactIdentifier new];
    
    emarsysUserIdentifier.applicationId = appId;
    emarsysUserIdentifier.hardwareId = hwid;
    
    return emarsysUserIdentifier;
}

@end


//### EmarsysPushIdentifier
@implementation EmarsysPushIdentifier

+(instancetype)appId:(NSString *)appId hwid:(NSString *)hwid pushToken:(NSString *)pushToken {
    EmarsysPushIdentifier *emarsysPushIdentifier = [EmarsysPushIdentifier new];
    
    emarsysPushIdentifier.applicationId = appId;
    emarsysPushIdentifier.hardwareId = hwid;
    emarsysPushIdentifier.pushToken = pushToken;
    
    return emarsysPushIdentifier;
}

@end


//### EmarsysDataManager
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
-(void)anonymousLogin:(EmarsysPushIdentifier *)contact completion:(DataCompletion)completion {
    NSMutableDictionary *params = [self commonLoginParams:contact];
    [self executeLogin:params completion:completion];
}

-(void)login:(EmarsysPushIdentifier *)contact contactFieldId:(NSString *)contactFieldId contactFieldValue:(NSString *)contactFieldValue completion:(DataCompletion)completion {
    NSMutableDictionary *params = [self commonLoginParams:contact];
    [params setObject:contactFieldId forKey:kContactFieldId];
    [params setObject:contactFieldValue forKey:kContactFieldValue];
    [self executeLogin:params completion:completion];
}

-(void)openMessageEvent:(EmarsysContactIdentifier *)contact sid:(NSString *)sid completion:(DataCompletion)completion {
    [self customEvent:contact event:@"message_open" attributes:@{ kSID: sid } completion:completion];
}

-(void)customEvent:(EmarsysContactIdentifier *)contact event:(NSString *)event attributes:(NSDictionary *)attributes completion:(DataCompletion)completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[ contact.applicationId, contact.hardwareId ]forKeys:@[ kApplicationId, kHardwareId ]];
    for(id key in attributes) {
        [params setObject:[attributes objectForKey:key] forKey:key];
    }
    
    [self executeEvent:event params:params completion:completion];
}

-(void)logout:(EmarsysPushIdentifier *)contact completion:(DataCompletion)completion {
    NSDictionary *params = @{ kApplicationId: contact.applicationId, kHardwareId: contact.hardwareId };
    [self executeLogout:params completion:completion];
}

#pragma mark - Private Methods
-(NSMutableDictionary *)commonLoginParams:(EmarsysPushIdentifier *)contact {
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

-(void) executeLogin:(NSDictionary *)params completion:(DataCompletion)completion {
    [self.requestManager asyncPOST:nil path:@"users/login" params:params type:REQUEST_EXEC_IN_BACKGROUND completion:^(int statusCode, id data, NSArray *errorMessages) {
        [self handleEmarsysDataManagerResponse:statusCode data:data errorMessages:errorMessages completion:completion];
    }];
}

-(void) executeEvent:(NSString *)event params:(NSDictionary *)params completion:(DataCompletion)completion {
    [self.requestManager asyncPOST:nil path:[NSString stringWithFormat:@"events/%@", event] params:params type:REQUEST_EXEC_IN_BACKGROUND completion:^(int statusCode, id data, NSArray *errorMessages) {
        [self handleEmarsysDataManagerResponse:statusCode data:data errorMessages:errorMessages completion:completion];
    }];
}

-(void) executeLogout:(NSDictionary *)params completion:(DataCompletion)completion {
    [self.requestManager asyncPOST:nil path:@"users/logout" params:params type:REQUEST_EXEC_IN_BACKGROUND completion:^(int statusCode, id data, NSArray *errorMessages) {
        [self handleEmarsysDataManagerResponse:statusCode data:data errorMessages:errorMessages completion:completion];
    }];
}

-(void) handleEmarsysDataManagerResponse:(int)statusCode data:(id)data errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion {
    if(statusCode == CREATED || statusCode == SUCCESSFUL) {
        completion(data, nil);
    } else {
        completion(nil, [NSError errorWithDomain:@"com.bamilo.ios" code:statusCode userInfo:@{ NSUnderlyingErrorKey: errorMessages[0] }]);
    }
}

@end
