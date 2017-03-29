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
-(void)doAnonymousLogin:(id<DataServiceProtocol>)target applicationId:(NSString *)applicationId hardwareId:(NSString *)hardwareId pushToken:(NSString *)pushToken completion:(DataCompletion)completion {
    NSDictionary *params = @{
        kApplicationId: applicationId,
        kHardwareId: hardwareId,
        kPlatform: @"ios",
        kLanguage: @"fa", //TEMP: Multi-language app?
        kTimezone: [DeviceManager getLocalTimeZoneRFC822Formatted],
        kDeviceModel: [DeviceManager getDeviceModel],
        kApplicationVersion: [[AppManager sharedInstance] getAppVersionNumber],
        kOSVersion: [DeviceManager getOSVersionFormatted],
        kPushToken: pushToken ?: @"false"
    };
    
    [self.requestManager asyncPOST:target path:@"users/login" params:params type:REQUEST_EXEC_IN_BACKGROUND completion:^(int statusCode, id data, NSArray *errorMessages) {
        if(statusCode == SUCCESSFUL) {
            completion(data, nil);
        } else {
            completion(nil, [NSError errorWithDomain:@"com.bamilo.ios" code:statusCode userInfo:@{ NSUnderlyingErrorKey: errorMessages[0] }]);
        }
    }];
}

@end
