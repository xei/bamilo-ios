//
//  RequestManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "RequestManager.h"
#import "LoadingManager.h"

@implementation RequestManager {
@private
    int _pendingRequestsNumber;
}

+(void) asyncGET:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion {
    [RequestManager asyncRequest:HttpVerbGET path:path params:params type:type target:target completion:completion];
}

+(void) asyncPOST:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion {
    [RequestManager asyncRequest:HttpVerbPOST path:path params:params type:type target:target completion:completion];
}

+(void) asyncPUT:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion {
    [RequestManager asyncRequest:HttpVerbPUT path:path params:params type:type target:target completion:completion];
}

+(void) asyncDELETE:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion {
    [RequestManager asyncRequest:HttpVerbDELETE path:path params:params type:type target:target completion:completion];
}

#pragma mark - Private Methods
+(void)asyncRequest:(HttpVerb)method path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type target:(id<DataServiceProtocol>)target completion:(RequestCompletion)completion {
    switch (type) {
        case REQUEST_EXEC_IN_FOREGROUND:
            [[LoadingManager sharedInstance] showLoadingOn:target];
        break;
            
        default:
            break;
    }
    
    [[RICommunicationWrapper sharedInstance]
     sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, path]]
     parameters:params
     httpMethod:method
     cacheType:RIURLCacheNoCache
     cacheTime:RIURLCacheDefaultTime
     userAgentInjection:[RIApi getCountryUserAgentInjection] successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
        NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
        if (metadata || [jsonObject objectForKey:@"success"]) {
            completion(apiResponse, metadata, nil);
        } else {
            completion(apiResponse, nil, nil);
        }
         
        [[LoadingManager sharedInstance] hideLoading];
         
    } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
        if(errorJsonObject && errorJsonObject.allKeys.count) {
            completion(apiResponse, nil, [RIError getPerfectErrorMessages:errorJsonObject]);
        } else if(errorObject) {
            NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
            completion(apiResponse, nil, errorArray);
        } else {
            completion(apiResponse, nil, nil);
        }
        
        [[LoadingManager sharedInstance] hideLoading];
    }];
}

@end
